#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Generic ramdisk allow list
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)

# Project ID Quota
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Virtual A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Dalvik vm configs
$(call inherit-product, frameworks/native/build/phone-xhdpi-6144-dalvik-heap.mk)

# pKVM
$(call inherit-product, packages/modules/Virtualization/apex/product_packages.mk)

# Qualcomm
$(call soong_config_set,rfs,mpss_firmware_symlink_target,modem_firmware)
$(call inherit-product, hardware/qcom-caf/common/common.mk)

# A/B
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=ext4 \
    POSTINSTALL_OPTIONAL_vendor=true

PRODUCT_PACKAGES += \
    checkpoint_gc \
    otapreopt_script

# API
BOARD_SHIPPING_API_LEVEL := 34
PRODUCT_SHIPPING_API_LEVEL := $(BOARD_SHIPPING_API_LEVEL)

# Audio
$(call soong_config_set_bool, android_hardware_audio, skip_speaker_layout_channel_mask_field, true)

PRODUCT_PACKAGES += \
    android.hardware.audio.service

PRODUCT_PACKAGES += \
    android.hardware.audio.effect@7.0-impl \
    android.hardware.audio@7.1-impl \
    android.hardware.soundtrigger@2.3-impl

PRODUCT_PACKAGES += \
    audioadsprpcd \
    audio.bluetooth.default \
    audio.r_submix.default \
    audio.usb.default

PRODUCT_PACKAGES += \
    lib_bt_aptx \
    lib_bt_ble \
    lib_bt_bundle \
    libagm_compress_plugin \
    libagm_mixer_plugin \
    libagm_pcm_plugin \
    libagmclient \
    libaudiochargerlistener \
    libbatterylistener \
    libfmpal \
    libhfp_pal \
    libqcompostprocbundle \
    libqcomvisualizer \
    libqcomvoiceprocessing \
    libsndcardparser \
    libvolumelistener

AUDIO_HAL_DIR := hardware/qcom-caf/sm8650/audio/primary-hal

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_cliffs/audio_effects.xml \
    $(LOCAL_PATH)/configs/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_cliffs/audio_policy_configuration.xml

PRODUCT_COPY_FILES += \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.audio.pro.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.pro.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

# Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth.audio-impl

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml

# Boot control
PRODUCT_PACKAGES += \
    android.hardware.boot-service.qti \
    android.hardware.boot-service.qti.recovery

# Camera
PRODUCT_PACKAGES += \
    libcamera2ndk_vendor

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.full.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.full.xml \
    frameworks/native/data/etc/android.hardware.camera.raw.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.raw.xml

# Contexthub
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.context_hub.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.context_hub.xml

# Display
PRODUCT_PACKAGES += \
    android.hardware.graphics.mapper@4.0-impl-qti-display \
    vendor.qti.hardware.display.allocator-service \
    vendor.qti.hardware.display.demura-service

PRODUCT_PACKAGES += \
    vendor.qti.hardware.display.composer3-V1-ndk.vendor \
    vendor.qti.hardware.display.config-V11-ndk.vendor

PRODUCT_PACKAGES += \
    init.qti.display_boot.rc \
    init.qti.display_boot.sh

$(foreach display_id, 4630947195234848131 4630947033261136259 4630946545580055171, \
    $(eval PRODUCT_COPY_FILES += \
        $(LOCAL_PATH)/configs/display/displayconfig.xml:$(TARGET_COPY_OUT_VENDOR)/etc/displayconfig/display_id_$(display_id).xml \
    ))

# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm-service.clearkey

# Fastbootd
PRODUCT_PACKAGES += \
    fastbootd

# Fingerprint
$(call soong_config_set,XIAOMI_BIOMETRICS_FINGERPRINT,USE_NEW_IMPL,true)
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint-service.xiaomi \
    libudfpshandler

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml

# Graphics
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer3-V2-ndk.vendor

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-1.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_1.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_3.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2023-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2023-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level.xml

# GNSS
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml

# Health
PRODUCT_PACKAGES += \
    android.hardware.health-service.qti \
    android.hardware.health-service.qti_recovery

# IPACM
PRODUCT_PACKAGES += \
    ipacm \
    IPACM_cfg.xml \
    IPACM_Filter_cfg.xml

# IR
PRODUCT_PACKAGES += \
    android.hardware.ir-service.lineage

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.consumerir.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.consumerir.xml

# Init
PRODUCT_PACKAGES += \
    charger_fw_fstab.qti \
    fstab.qcom

PRODUCT_PACKAGES += \
    init.class_main.sh \
    init.kernel.post_boot-cliffs_2_2_1.sh \
    init.kernel.post_boot-cliffs_2_3_0.sh \
    init.kernel.post_boot-cliffs_3_3_1.sh \
    init.kernel.post_boot-cliffs_default_3_4_1.sh \
    init.kernel.post_boot-cliffs.sh \
    init.kernel.post_boot-memory.sh \
    init.kernel.post_boot.sh \
    init.qcom.early_boot.sh \
    init.qcom.post_boot.sh \
    init.qcom.sh

PRODUCT_PACKAGES += \
    init.qcom.factory.rc \
    init.peridot.rc \
    init.qcom.rc \
    init.recovery.qcom.rc \
    init.target.rc

PRODUCT_PACKAGES += \
    ueventd-odm.rc \
    ueventd.qcom.rc

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.qcom:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.qcom

# Keymint
PRODUCT_PACKAGES += \
    android.hardware.authsecret-service.nxp

PRODUCT_PACKAGES += \
    android.hardware.hardware_keystore.xml

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/hal_uuid_map.xml:$(TARGET_COPY_OUT_VENDOR)/etc/hal_uuid_map_peridot.xml

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.device_id_attestation.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_id_attestation.xml \
    frameworks/native/data/etc/android.hardware.keystore.app_attest_key.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.keystore.app_attest_key.xml

# Lineage Health
PRODUCT_PACKAGES += \
    vendor.lineage.health-service.default

$(call soong_config_set_bool,lineage_health,charging_control_supports_bypass,false)
$(call soong_config_set,lineage_health,fast_charge_node,/sys/class/qcom-battery/fastcharge_enable)
$(call soong_config_set,lineage_health,fast_charge_value_none,0)
$(call soong_config_set,lineage_health,fast_charge_value_fast_charge,1)
$(call soong_config_set,lineage_health,fast_charge_value_super_fast_charge,2)

# Media
PRODUCT_COPY_FILES += \
    $(AUDIO_HAL_DIR)/configs/common/codec2/media_codecs_c2_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_c2_audio.xml

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/media/media_codecs_cliffs_v0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_cliffs_v0.xml \
    $(LOCAL_PATH)/configs/media/media_codecs_performance_cliffs_v0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance_cliffs_v0.xml \
    $(LOCAL_PATH)/configs/media/media_profiles_cliffs_v0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_cliffs_v0.xml \
    $(LOCAL_PATH)/configs/media/video_system_specs.json:$(TARGET_COPY_OUT_VENDOR)/etc/media_cliffs_v0/video_system_specs.json \

# Memtrack
PRODUCT_PACKAGES += \
    vendor.qti.hardware.memtrack-service

# Network
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml

# NFC
PRODUCT_PACKAGES += \
    android.hardware.nfc-service.nxp \
    com.android.nfc_extras

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.nfc.ese.xml \
    frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.nfc.hce.xml \
    frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.nfc.hcef.xml \
    frameworks/native/data/etc/android.hardware.nfc.uicc.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.nfc.uicc.xml \
    frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.nfc.xml \
    frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.se.omapi.ese.xml \
    frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.se.omapi.uicc.xml \
    frameworks/native/data/etc/com.android.nfc_extras.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/com.android.nfc_extras.xml \
    frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/com.nxp.mifare.xml

# Overlays
PRODUCT_PACKAGES += \
    ApertureOverlayPeridot \
    CarrierConfigOverlayPeridot \
    FrameworkOverlayPeridot \
    LineageDialerOverlayPeridot \
    LineageSDKOverlayPeridot \
    LineageSettingsOverlayPeridot \
    NfcOverlayPeridot \
    SecureElementOverlayPeridot \
    SettingsOverlayPeridot \
    SettingsProviderOverlayPeridotPOCO \
    SettingsProviderOverlayPeridotRedmi \
    SystemUIOverlayPeridot \
    TelephonyOverlayPeridot \
    WifiOverlayPeridot \
    WifiOverlayPeridotPOCO \
    WifiOverlayPeridotRedmi

PRODUCT_PACKAGES += \
    NcmTetheringOverlay

# Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

PRODUCT_PACKAGES += \
    vendor_bt_firmware_mountpoint \
    vendor_dsp_mountpoint \
    vendor_firmware_mnt_mountpoint \
    vendor_modem_firmware_mountpoint

# Power
PRODUCT_PACKAGES += \
    android.hardware.power-service.lineage-libperfmgr \
    libqti-perfd-client

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/power/powerhint.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json

# QMI
PRODUCT_PACKAGES += \
    libvndfwk_detect_jni.qti_vendor # Needed by CNE app

# QSPA
PRODUCT_PACKAGES += \
    vendor.qti.qspa-service \
    qspa_vendor.rc

# SKU
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/props/odm_CN.prop:$(TARGET_COPY_OUT_ODM)/etc/odm_CN.prop \
    $(LOCAL_PATH)/props/odm_GL.prop:$(TARGET_COPY_OUT_ODM)/etc/odm_GL.prop \
    $(LOCAL_PATH)/props/odm_IN.prop:$(TARGET_COPY_OUT_ODM)/etc/odm_IN.prop

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH) \
    hardware/google/interfaces \
    hardware/google/pixel \
    hardware/lineage/interfaces/power-libperfmgr \
    hardware/qcom-caf/common/libqti-perfd-client \
    hardware/xiaomi \
    vendor/qcom/opensource/usb/etc

# Sensors
PRODUCT_PACKAGES += \
    android.hardware.sensors-service.xiaomi-multihal

PRODUCT_PACKAGES += \
    sensors.dynamic_sensor_hal \
    sensors.xiaomi.v2

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/sensors/hals.conf:$(TARGET_COPY_OUT_VENDOR)/etc/sensors/hals.conf \

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.dynamic.head_tracker.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.dynamic.head_tracker.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml

# Telephony
PRODUCT_PACKAGES += \
    extphonelib \
    extphonelib-product \
    extphonelib.xml \
    extphonelib_product.xml \
    ims-ext-common \
    ims_ext_common.xml \
    qti-telephony-hidl-wrapper \
    qti-telephony-hidl-wrapper-prd \
    qti_telephony_hidl_wrapper.xml \
    qti_telephony_hidl_wrapper_prd.xml \
    qti-telephony-utils \
    qti-telephony-utils-prd \
    qti_telephony_utils.xml \
    qti_telephony_utils_prd.xml \
    telephony-ext

PRODUCT_PACKAGES += \
    qcrilNrDb_vendor

PRODUCT_PACKAGES += \
    xiaomi-telephony-stub

PRODUCT_BOOT_JARS += \
    telephony-ext \
    xiaomi-telephony-stub

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.telephony.cdma.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.cdma.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.telephony.ims.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.ims.xml \
    frameworks/native/data/etc/android.hardware.telephony.mbms.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.mbms.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml

# Touchscreen
PRODUCT_PACKAGES += \
    vendor.lineage.touch-service.xiaomi

$(call soong_config_set, XIAOMI_TOUCH, HIGH_TOUCH_POLLING_PATH, /sys/devices/virtual/touch/touch_dev/bump_sample_rate)

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml

# Update engine
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

# USB
PRODUCT_PACKAGES += \
    android.hardware.usb-service.qti \
    android.hardware.usb.gadget-service.qti

PRODUCT_PACKAGES += \
    init.qcom.usb.rc \
    init.qcom.usb.sh \
    usb_compositions.conf

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml

# Vendor service manager
PRODUCT_PACKAGES += \
    vndservice \
    vndservicemanager

# Vibrator
PRODUCT_PACKAGES += \
    vendor.qti.hardware.vibrator.service

PRODUCT_COPY_FILES += \
    vendor/qcom/opensource/vibrator/excluded-input-devices.xml:$(TARGET_COPY_OUT_VENDOR)/etc/excluded-input-devices.xml

# Verified boot
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml

# WiFi
PRODUCT_PACKAGES += \
    android.hardware.wifi-service \
    hostapd \
    hostapd_cli \
    libkeystore-engine-wifi-hidl \
    libkeystore-wifi-hidl \
    libwifi-hal \
    libwifi-hal-ctrl \
    libwifi-hal-qcom \
    wpa_cli \
    wpa_supplicant \
    wpa_supplicant.conf

PRODUCT_PACKAGES += \
    firmware_wlanmdsp.otaupdate_symlink \
    firmware_wlan_mac.bin_symlink \
    firmware_WCNSS_qcom_cfg.ini_symlink

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/wifi/WCNSS_qcom_cfg.ini:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/qca6750/WCNSS_qcom_cfg.ini \
    $(LOCAL_PATH)/configs/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    $(LOCAL_PATH)/configs/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.aware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.aware.xml

# Vendor
$(call inherit-product, vendor/xiaomi/peridot/peridot-vendor.mk)
