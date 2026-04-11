/*
 * Copyright (C) 2025 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include "SensorsSubHal.h"

#include <android-base/logging.h>
#include <android-base/unique_fd.h>
#include <display/drm/mi_disp.h>
#include <dlfcn.h>
#include <poll.h>

using ::android::hardware::sensors::V2_0::implementation::ScopedWakelock;
using ::android::hardware::sensors::V2_1::implementation::ISensorsSubHal;

namespace android {
namespace hardware {
namespace sensors {
namespace V2_1 {
namespace subhal {
namespace implementation {
namespace qsh_wrapper {

namespace {
constexpr auto kLibName = "sensors.qsh.so";
constexpr int32_t kTsl2522FbRawType = 33171111;

// This is larger than any sensor handle returned by the HAL
constexpr auto kWrappedSensorHandleBase = 0x10000;
inline int32_t IsWrappedHandle(int32_t sensor_handle) {
    return sensor_handle >= kWrappedSensorHandleBase;
}
inline int32_t ToWrappedHandle(int32_t sensor_handle) {
    return IsWrappedHandle(sensor_handle) ? sensor_handle
                                          : sensor_handle + kWrappedSensorHandleBase;
}

bool IsRawAmbientLightSensor(const android::hardware::sensors::V2_1::SensorInfo& sensor) {
    return static_cast<int32_t>(sensor.type) == kTsl2522FbRawType;
}

static constexpr char kDispFeatureDevice[] = "/dev/mi_display/disp_feature";

bool IsDefaultLightSensor(const android::hardware::sensors::V2_1::SensorInfo& sensor) {
    return sensor.type == SensorType::LIGHT && !IsRawAmbientLightSensor(sensor);
}

disp_event_resp* parseDispEvent(int fd) {
    disp_event header;
    ssize_t headerSize = read(fd, &header, sizeof(header));
    if (headerSize < static_cast<ssize_t>(sizeof(header))) {
        LOG(ERROR) << "unexpected display event header size: " << headerSize;
        return nullptr;
    }

    struct disp_event_resp* response =
            reinterpret_cast<struct disp_event_resp*>(malloc(header.length));
    response->base = header;

    int dataLength = response->base.length - static_cast<int>(sizeof(response->base));
    if (dataLength < 0) {
        LOG(ERROR) << "invalid data length: " << response->base.length;
        free(response);
        return nullptr;
    }

    ssize_t dataSize = read(fd, &response->data, dataLength);
    if (dataSize < dataLength) {
        LOG(ERROR) << "unexpected display event data size: " << dataSize;
        free(response);
        return nullptr;
    }

    return response;
}
};  // anonymous namespace

SensorsSubHal::SensorsSubHal()
    : lib_handle_(dlopen(kLibName, RTLD_NOW), [](void* p) {
          if (p) dlclose(p);
      }) {
    if (!lib_handle_) {
        LOG(FATAL) << __func__ << ": dlopen " << kLibName << " failed, exiting";
    }

    auto get_sub_hal = reinterpret_cast<ISensorsSubHal* (*)(uint32_t*)>(
            dlsym(lib_handle_.get(), "sensorsHalGetSubHal_2_1"));
    uint32_t version;
    impl_ = get_sub_hal(&version);

    disp_thread_ = std::thread(&SensorsSubHal::displayMonitorThread, this);
}

SensorsSubHal::~SensorsSubHal() {
    stop_disp_thread_.store(true);
    if (disp_thread_.joinable()) {
        disp_thread_.join();
    }
}

Return<Result> SensorsSubHal::setOperationMode(OperationMode mode) {
    return impl_->setOperationMode(mode);
}

int32_t SensorsSubHal::getRealHandle(int32_t sensor_handle) const {
    auto it = alias_handle_to_raw_handle_.find(sensor_handle);
    return it != alias_handle_to_raw_handle_.end() ? it->second : sensor_handle;
}

int32_t SensorsSubHal::getAliasHandle(int32_t raw_sensor_handle) const {
    auto it = raw_handle_to_alias_handle_.find(raw_sensor_handle);
    return it != raw_handle_to_alias_handle_.end() ? it->second : raw_sensor_handle;
}

Return<Result> SensorsSubHal::activate(int32_t sensor_handle, bool enabled) {
    const auto real_handle = getRealHandle(sensor_handle);

    bool is_raw_light = false;
    auto it = handle_type_.find(sensor_handle);
    if (it != handle_type_.end() && static_cast<int32_t>(it->second) == kTsl2522FbRawType) {
        is_raw_light = true;
    } else if (raw_handle_to_alias_handle_.count(real_handle) > 0) {
        is_raw_light = true;
    }

    if (is_raw_light) {
        std::lock_guard<std::mutex> lock(display_mutex_);
        gated_raw_handle_ = real_handle;
        requested_enabled_.store(enabled);

        if (enabled && display_on_.load()) {
            sensor_currently_enabled_.store(true);
            return impl_->activate(real_handle, enabled);
        }

        if (!enabled && sensor_currently_enabled_.load()) {
            sensor_currently_enabled_.store(false);
            return impl_->activate(real_handle, false);
        }

        return Result::OK;
    }

    return impl_->activate(real_handle, enabled);
}

Return<Result> SensorsSubHal::batch(int32_t sensor_handle, int64_t sampling_period_ns,
                                    int64_t max_report_latency_ns) {
    const auto real_handle = getRealHandle(sensor_handle);
    return impl_->batch(real_handle, sampling_period_ns, max_report_latency_ns);
}

Return<Result> SensorsSubHal::flush(int32_t sensor_handle) {
    const auto real_handle = getRealHandle(sensor_handle);
    return impl_->flush(real_handle);
}

Return<void> SensorsSubHal::registerDirectChannel(const SharedMemInfo& mem,
                                                  ISensors::registerDirectChannel_cb _hidl_cb) {
    return impl_->registerDirectChannel(mem, _hidl_cb);
}

Return<Result> SensorsSubHal::unregisterDirectChannel(int32_t channel_handle) {
    return impl_->unregisterDirectChannel(channel_handle);
}

Return<void> SensorsSubHal::configDirectReport(int32_t sensor_handle, int32_t channel_handle,
                                               RateLevel rate,
                                               ISensors::configDirectReport_cb _hidl_cb) {
    const auto real_handle = getRealHandle(sensor_handle);
    return impl_->configDirectReport(real_handle, channel_handle, rate, _hidl_cb);
}

Return<void> SensorsSubHal::getSensorsList_2_1(ISensors::getSensorsList_2_1_cb _hidl_cb) {
    return impl_->getSensorsList_2_1([&](const auto& _hidl_out_list) {
        auto sensors = hidl_vec<SensorInfo>(_hidl_out_list.size());
        std::copy(_hidl_out_list.begin(), _hidl_out_list.end(), sensors.begin());

        auto raw_it = std::find_if(sensors.begin(), sensors.end(),
                                   [](auto&& sensor) { return IsRawAmbientLightSensor(sensor); });

        if (raw_it != sensors.end()) {
            auto raw_sensor = *raw_it;
            auto default_light_it = std::find_if(sensors.begin(), sensors.end(), [](auto&& sensor) {
                return IsDefaultLightSensor(sensor);
            });

            std::vector<SensorInfo> filtered;
            filtered.reserve(sensors.size());

            for (auto& sensor : sensors) {
                if (!IsDefaultLightSensor(sensor)) {
                    filtered.emplace_back(sensor);
                } else {
                }
            }

            SensorInfo alias = raw_sensor;
            const int32_t alias_handle = default_light_it != sensors.end()
                                                 ? default_light_it->sensorHandle
                                                 : ToWrappedHandle(raw_sensor.sensorHandle);
            alias.sensorHandle = alias_handle;
            alias.name = "Ambient Light Sensor";
            alias.type = SensorType::LIGHT;
            alias.typeAsString = "android.sensor.light";
            handle_type_[alias.sensorHandle] = raw_sensor.type;
            alias_handle_to_raw_handle_[alias.sensorHandle] = raw_sensor.sensorHandle;
            raw_handle_to_alias_handle_[raw_sensor.sensorHandle] = alias.sensorHandle;
            filtered.emplace_back(std::move(alias));

            auto aliased_sensors = hidl_vec<SensorInfo>(filtered.size());
            std::copy(filtered.begin(), filtered.end(), aliased_sensors.begin());
            _hidl_cb(aliased_sensors);
        } else {
            _hidl_cb(sensors);
        }
    });
}

Return<Result> SensorsSubHal::injectSensorData_2_1(const Event& event) {
    const auto real_handle = getRealHandle(event.sensorHandle);
    if (real_handle != event.sensorHandle) {
        auto event_copy = event;
        event_copy.sensorHandle = real_handle;
        event_copy.sensorType = handle_type_[event.sensorHandle];
        return impl_->injectSensorData_2_1(event_copy);
    }
    return impl_->injectSensorData_2_1(event);
}

void SensorsSubHal::displayMonitorThread() {
    android::base::unique_fd disp_fd(open(kDispFeatureDevice, O_RDWR));
    if (disp_fd.get() == -1) {
        LOG(ERROR) << "failed to open " << kDispFeatureDevice;
        return;
    }

    disp_event_req req = {};
    req.base.flag = 0;
    req.base.disp_id = MI_DISP_PRIMARY;
    req.type = MI_DISP_EVENT_POWER;
    if (ioctl(disp_fd.get(), MI_DISP_IOCTL_REGISTER_EVENT, &req) < 0) {
        LOG(ERROR) << "failed to register display event";
        return;
    }

    struct pollfd dispEventPoll = {
            .fd = disp_fd.get(),
            .events = POLLIN,
    };

    while (!stop_disp_thread_.load()) {
        int rc = poll(&dispEventPoll, 1, -1);
        if (rc < 0) {
            if (errno == EINTR) {
                continue;
            }
            LOG(ERROR) << "failed to poll " << kDispFeatureDevice << ", err: " << rc;
            continue;
        }

        std::unique_ptr<disp_event_resp, decltype(&free)> response(parseDispEvent(disp_fd.get()),
                                                                   &free);
        if (!response) {
            continue;
        }

        if (response->base.type != MI_DISP_EVENT_POWER) {
            LOG(ERROR) << "unexpected display event: " << response->base.type;
            continue;
        }

        const bool on = response->data[0] == MI_DISP_POWER_ON;
        const bool previous = display_on_.exchange(on);
        if (on == previous) {
            continue;
        }

        std::lock_guard<std::mutex> lock(display_mutex_);
        if (on && requested_enabled_.load() && gated_raw_handle_ != -1) {
            impl_->activate(gated_raw_handle_, true);
            sensor_currently_enabled_.store(true);
        } else if (!on && sensor_currently_enabled_.load() && gated_raw_handle_ != -1) {
            impl_->activate(gated_raw_handle_, false);
            sensor_currently_enabled_.store(false);
        }
    }
}

Return<void> SensorsSubHal::debug(const hidl_handle& fd, const hidl_vec<hidl_string>& args) {
    return impl_->debug(fd, args);
}

const std::string SensorsSubHal::getName() {
    return impl_->getName();
}

Return<Result> SensorsSubHal::initialize(const sp<IHalProxyCallback>& hal_proxy_callback) {
    hal_proxy_callback_ = hal_proxy_callback;
    return impl_->initialize(this);
}

Return<void> SensorsSubHal::onDynamicSensorsConnected(
        const hidl_vec<V1_0::SensorInfo>& sensor_infos) {
    return hal_proxy_callback_->onDynamicSensorsConnected(sensor_infos);
}

Return<void> SensorsSubHal::onDynamicSensorsDisconnected(const hidl_vec<int32_t>& sensor_handles) {
    return hal_proxy_callback_->onDynamicSensorsDisconnected(sensor_handles);
}

Return<void> SensorsSubHal::onDynamicSensorsConnected_2_1(
        const hidl_vec<V2_1::SensorInfo>& sensor_infos) {
    return hal_proxy_callback_->onDynamicSensorsConnected_2_1(sensor_infos);
}

void SensorsSubHal::postEvents(const std::vector<Event>& events, ScopedWakelock wakelock) {
    std::vector<Event> forwarded_events;
    forwarded_events.reserve(events.size() * 2);

    for (auto&& e : events) {
        forwarded_events.emplace_back(e);
        if (static_cast<int32_t>(e.sensorType) == kTsl2522FbRawType) {
            const auto alias_handle = getAliasHandle(e.sensorHandle);
            if (alias_handle != e.sensorHandle) {
                auto event_copy = e;
                event_copy.sensorHandle = alias_handle;
                event_copy.sensorType = SensorType::LIGHT;
                event_copy.u.scalar = e.u.vec4.y;
                forwarded_events.emplace_back(std::move(event_copy));
            }
        }
    }

    hal_proxy_callback_->postEvents(forwarded_events, std::move(wakelock));
}

ScopedWakelock SensorsSubHal::createScopedWakelock(bool lock) {
    return hal_proxy_callback_->createScopedWakelock(lock);
}

}  // namespace qsh_wrapper
}  // namespace implementation
}  // namespace subhal
}  // namespace V2_1
}  // namespace sensors
}  // namespace hardware
}  // namespace android

ISensorsSubHal* sensorsHalGetSubHal_2_1(uint32_t* version) {
    static ::android::hardware::sensors::V2_1::subhal::implementation::qsh_wrapper::SensorsSubHal
            sub_hal;
    *version = SUB_HAL_2_1_VERSION;
    return &sub_hal;
}
