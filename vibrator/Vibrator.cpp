/*
 * Copyright (C) 2019 The Android Open Source Project
 * Copyright (C) 2023 StatiXOS
 * SPDX-License-Identifer: Apache-2.0
 */

#include "vibrator-impl/Vibrator.h"

#include <android-base/logging.h>
#include <thread>
#include <map>
#include <fstream>
#include <string.h>

namespace aidl {
namespace android {
namespace hardware {
namespace vibrator {

std::map<int, std::string> haptic_nodes = {
    {1, "/sys/bus/i2c/drivers/awinic_haptic/2-005a/"},
};

// Common haptic nodes
static std::string HAPTIC_NODE;
static std::string ACTIVATE_NODE = "activate";
static std::string ACTIVATE_MODE_NODE = "activate_mode";
static std::string EFFECT_ID_NODE = "effect_id";
static std::string INDEX_NODE = "index";
static std::string DURATION_NODE = "duration";

struct HapticConfig {
    int mode;
    int effect_id;
    int index;
    int duration;
};

std::map<Effect, HapticConfig> effectConfig = {
    //   Effect              activate_mode, effect_id, index, duration(ms)
    {Effect::TICK,          {0,             2,         0,      30}},
    {Effect::TEXTURE_TICK,  {0,             2,         0,      30}},
    {Effect::CLICK,         {0,             0,         0,      50}},
    {Effect::HEAVY_CLICK,   {0,             5,         0,      70}},
    {Effect::DOUBLE_CLICK,  {0,             1,         0,      50}},
    {Effect::THUD,          {0,             3,         0,      70}},
    {Effect::POP,           {0,             4,         0,      30}}
};

template <typename T>
static void write_haptic_node(const std::string& path, const T& value) {
    std::ofstream file(path);
    file << value;
}

template <typename T>
static bool openNoCreate(const std::string &file, T *outStream) {
    auto mode = std::is_base_of_v<std::ostream, T> ? std::ios_base::out : std::ios_base::in;
    // Force 'in' mode to prevent file creation
    outStream->open(file, mode | std::ios_base::in);
    if (!*outStream) {
        LOG(ERROR) << "Failed to open %s (%d): %s" << file.c_str(), errno, strerror(errno);
        return false;
    }
    return true;
}

ndk::ScopedAStatus Vibrator::getCapabilities(int32_t* _aidl_return) {
    LOG(VERBOSE) << "Vibrator reporting capabilities";
    *_aidl_return = IVibrator::CAP_ON_CALLBACK | IVibrator::CAP_PERFORM_CALLBACK;
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Vibrator::off() {
    LOG(VERBOSE) << "Vibrator off";
    /* Reset index before triggering another set of haptics */
    write_haptic_node(HAPTIC_NODE + INDEX_NODE, 0);
    /* Reset mode before triggering another set of haptics */
    write_haptic_node(HAPTIC_NODE + ACTIVATE_MODE_NODE, 1);
    write_haptic_node(HAPTIC_NODE + ACTIVATE_NODE, 0);
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Vibrator::on(int32_t timeoutMs,
                                const std::shared_ptr<IVibratorCallback>& callback) {
    write_haptic_node(HAPTIC_NODE + DURATION_NODE, timeoutMs);
    write_haptic_node(HAPTIC_NODE + ACTIVATE_NODE, 1);

    if (callback != nullptr) {
        // Note that thread lambdas aren't using implicit capture [=], to avoid capturing "this",
        // which may be asynchronously destructed.
        // If "this" is needed, use [sharedThis = this->ref<Vibrator>()].
        std::thread([timeoutMs, callback] {
            usleep(timeoutMs * 1000);
        }).detach();
    }
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Vibrator::perform(Effect effect, EffectStrength strength,
                                     const std::shared_ptr<IVibratorCallback>& callback,
                                     int32_t* _aidl_return) {
    ndk::ScopedAStatus status;
    uint32_t index = 0;
    uint32_t timeMs = 0;
    uint32_t activate_mode = 1;
    uint32_t effect_id = 0;
    std::ofstream stream;

    for (auto& i: haptic_nodes) {
        std::string triggerNode = i.second + ACTIVATE_NODE;
        if (!openNoCreate(triggerNode, &stream))
            continue;
        else
            HAPTIC_NODE = i.second;
            break;
    }

    LOG(INFO) << "Vibrator perform";

    auto it = effectConfig.find(effect);
    if (it == effectConfig.end()) {
        return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    }

    const HapticConfig& config = it->second;
    activate_mode = config.mode;
    effect_id = config.effect_id;
    index = config.index;
    timeMs = config.duration;

    if (effect == Effect::DOUBLE_CLICK) {
        // double click isn't mapped as an effect_id in most awinic drivers, so
        // run the effect twice to get the effect.
        write_haptic_node(HAPTIC_NODE + ACTIVATE_MODE_NODE, activate_mode);
        write_haptic_node(HAPTIC_NODE + EFFECT_ID_NODE, effect_id);
        write_haptic_node(HAPTIC_NODE + INDEX_NODE, index);
        on(timeMs, nullptr);
        usleep(timeMs * 1000);
        // set values again, as Vibrator::on() may trigger Vibrator::off() after playing the first
        // set of haptics, leading to reset of index, effect_id and activate_mode.
        activate_mode = effectConfig.at(Effect::TICK).mode;  // change to tick for better differentiated haptic
        effect_id = effectConfig.at(Effect::TICK).effect_id;
        index = config.index;
        timeMs = config.duration;
    }

    /* Setup mode */
    write_haptic_node(HAPTIC_NODE + ACTIVATE_MODE_NODE, activate_mode);

    /* Setup effect id */
    write_haptic_node(HAPTIC_NODE + EFFECT_ID_NODE, effect_id);

    /* Setup effect index */
    write_haptic_node(HAPTIC_NODE + INDEX_NODE, index);

    if (callback != nullptr) {
        std::thread([callback, timeMs] {
            usleep(timeMs * 1000);
            callback->onComplete();
        }).detach();
    }

    status = on(timeMs, nullptr);
    if (!status.isOk()) {
        return status;
    } else {
        *_aidl_return = timeMs;
        return ndk::ScopedAStatus::ok();
    }
}

ndk::ScopedAStatus Vibrator::getSupportedEffects(std::vector<Effect>* _aidl_return) {
    *_aidl_return = {
        Effect::TICK,
        Effect::TEXTURE_TICK,
        Effect::CLICK,
        Effect::HEAVY_CLICK,
        Effect::DOUBLE_CLICK,
        Effect::THUD,
        Effect::POP
    };

    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Vibrator::setAmplitude(float amplitude) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::setExternalControl(bool enabled) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::getCompositionDelayMax(int32_t* maxDelayMs) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::getCompositionSizeMax(int32_t* maxSize) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::getSupportedPrimitives(std::vector<CompositePrimitive>* supported) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::getPrimitiveDuration(CompositePrimitive primitive,
                                                  int32_t* durationMs) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::compose(const std::vector<CompositeEffect>& composite,
                                     const std::shared_ptr<IVibratorCallback>& callback) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::getSupportedAlwaysOnEffects(std::vector<Effect>* _aidl_return) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::alwaysOnEnable(int32_t id, Effect effect, EffectStrength strength) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::alwaysOnDisable(int32_t id) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::getResonantFrequency(float *resonantFreqHz) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::getQFactor(float *qFactor) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::getFrequencyResolution(float *freqResolutionHz) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::getFrequencyMinimum(float *freqMinimumHz) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::getBandwidthAmplitudeMap(std::vector<float> *_aidl_return) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::getPwlePrimitiveDurationMax(int32_t *durationMs) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::getPwleCompositionSizeMax(int32_t *maxSize) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::getSupportedBraking(std::vector<Braking> *supported) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

ndk::ScopedAStatus Vibrator::composePwle(const std::vector<PrimitivePwle> &composite,
                                         const std::shared_ptr<IVibratorCallback> &callback) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

}  // namespace vibrator
}  // namespace hardware
}  // namespace android
}  // namespace aidl
