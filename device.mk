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
BOARD_API_LEVEL := 34
BOARD_SHIPPING_API_LEVEL := 34
PRODUCT_SHIPPING_API_LEVEL := 34

# Audio
PRODUCT_PACKAGES += \
    android.hardware.audio.service

PRODUCT_PACKAGES += \
    android.hardware.audio.effect@7.0-impl \
    android.hardware.audio@7.1-impl \
    android.hardware.soundtrigger@2.3-impl

PRODUCT_PACKAGES += \
    audio.bluetooth.default \
    audio.r_submix.default \
    audio.usb.default

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_cliffs/audio_policy_configuration.xml

PRODUCT_COPY_FILES += \
    frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml

# Biometrics
PRODUCT_PACKAGES += \
    android.frameworks.cameraservice.device-V1-ndk.vendor \
    android.frameworks.cameraservice.service-V1-ndk.vendor \
    android.hardware.biometrics.common-V2-ndk.vendor \
    android.hardware.biometrics.common-V3-ndk.vendor \
    android.hardware.biometrics.common.thread \
    android.hardware.biometrics.common.util \
    android.hardware.biometrics.face-V2-ndk.vendor \
    android.hardware.biometrics.face-V3-ndk.vendor \
    android.hardware.biometrics.fingerprint-V3-ndk.vendor

# Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth.audio-V3-ndk.vendor \
    android.hardware.bluetooth.audio-impl \
    android.hardware.bluetooth@1.1.vendor

# Boot control
PRODUCT_PACKAGES += \
    android.hardware.boot-service.qti \
    android.hardware.boot-service.qti.recovery

# Camera
PRODUCT_PACKAGES += \
    android.hardware.camera.common-V1-ndk.vendor \
    android.hardware.camera.device-V2-ndk.vendor \
    android.hardware.camera.metadata-V2-ndk.vendor \
    android.hardware.camera.provider-V2-ndk.vendor

PRODUCT_PACKAGES += \
    libcamera2ndk_vendor

# Contexthub
PRODUCT_PACKAGES += \
    android.hardware.contexthub-V2-ndk.vendor

# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm-service.clearkey

PRODUCT_PACKAGES += \
    libdrm.vendor

# DumpState
PRODUCT_PACKAGES += \
    android.hardware.dumpstate-V1-ndk.vendor

# Fastbootd
PRODUCT_PACKAGES += \
    fastbootd

# Graphics
PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator-V1-ndk.vendor \
    android.hardware.graphics.common-V4-ndk.vendor \
    android.hardware.graphics.composer3-V2-ndk.vendor \
    android.hardware.graphics.composer@2.1.vendor \
    android.hardware.graphics.composer@2.2.vendor \
    android.hardware.graphics.composer@2.3.vendor

# GNSS
PRODUCT_PACKAGES += \
    android.hardware.gnss-V3-ndk.vendor

# Health
PRODUCT_PACKAGES += \
    android.hardware.health@2.1.vendor \
    android.hardware.health-V1-ndk.vendor \
    android.hardware.health-V2-ndk.vendor

# HIDL
PRODUCT_PACKAGES += \
    android.hidl.memory.block@1.0.vendor \
    libhidltransport.vendor \
    libhwbinder.vendor

# IR
PRODUCT_PACKAGES += \
    android.hardware.ir-service.example

# Identity
PRODUCT_PACKAGES += \
    android.hardware.identity-V5-ndk.vendor

# Init
PRODUCT_PACKAGES += \
    fstab.qcom \
    init.peridot.rc \
    init.recovery.qcom.rc

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.qcom:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.qcom

# Keymint
PRODUCT_PACKAGES += \
    android.hardware.authsecret-V1-ndk.vendor \
    android.hardware.authsecret@1.0.vendor \
    android.hardware.gatekeeper-V1-ndk.vendor \
    android.hardware.gatekeeper@1.0.vendor \
    android.hardware.hardware_keystore.xml \
    android.hardware.keymaster-V3-ndk.vendor \
    android.hardware.keymaster-V4-ndk.vendor \
    android.hardware.keymaster@3.0.vendor \
    android.hardware.keymaster@4.1.vendor \
    android.hardware.security.keymint-V1-ndk.vendor \
    android.hardware.security.keymint-V2-ndk.vendor \
    android.hardware.security.keymint-V3-ndk.vendor \
    android.hardware.security.rkp-V3-ndk.vendor \
    android.hardware.security.secureclock-V1-ndk.vendor \
    android.hardware.security.sharedsecret-V1-ndk.vendor \
    android.se.omapi-V1-ndk.vendor \
    android.system.keystore2-V1-ndk.vendor \
    lib_android_keymaster_keymint_utils.vendor

# Lights
PRODUCT_PACKAGES += \
    android.hardware.light-V2-ndk.vendor

# Linker
PRODUCT_VENDOR_LINKER_CONFIG_FRAGMENTS += \
    $(LOCAL_PATH)/configs/linker.config.json

# Media
PRODUCT_PACKAGES += \
    android.hardware.media.c2@1.2.vendor \
    libOmxCore \
    libavservices_minijail \
    libcodec2_hidl@1.0.vendor \
    libcodec2_hidl@1.1.vendor \
    libcodec2_hidl@1.2.vendor \
    libcodec2_soft_common.vendor \
    libcodec2_vndk.vendor

PRODUCT_PACKAGES += \
    android.hardware.media.bufferpool2-V1-ndk.vendor

# Network
PRODUCT_PACKAGES += \
    android.system.net.netd-V1-ndk.vendor \
    android.hardware.tetheroffload-V1-ndk.vendor

# NFC
PRODUCT_PACKAGES += \
    android.hardware.nfc-V1-ndk.vendor \
    android.hardware.nfc@1.2.vendor \
    android.hardware.secure_element-V1-ndk.vendor \
    android.hardware.secure_element@1.2.vendor

# Overlays
PRODUCT_PACKAGES += \
    CarrierConfigOverlayPeridot \
    FrameworkOverlayPeridot \
    SecureElementOverlayPeridot \
    SettingsOverlayPeridot \
    SystemUIOverlayGarnet \
    TelephonyOverlayPeridot \
    WifiOverlayPeridot

# Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Power
PRODUCT_PACKAGES += \
    android.hardware.power@1.2.vendor \
    android.hardware.power-V4-ndk.vendor

# Radio
PRODUCT_PACKAGES += \
    android.hardware.radio-V2-ndk.vendor \
    android.hardware.radio.config-V2-ndk.vendor \
    android.hardware.radio.data-V2-ndk.vendor \
    android.hardware.radio.messaging-V2-ndk.vendor \
    android.hardware.radio.modem-V2-ndk.vendor \
    android.hardware.radio.network-V2-ndk.vendor \
    android.hardware.radio.sap-V1-ndk.vendor \
    android.hardware.radio.sim-V2-ndk.vendor \
    android.hardware.radio.voice-V2-ndk.vendor \
    android.hardware.radio@1.6.vendor

# RenderScript
PRODUCT_PACKAGES += \
    android.hardware.renderscript@1.0-impl

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Sensors
PRODUCT_PACKAGES += \
    android.hardware.sensors-service.multihal

PRODUCT_PACKAGES += \
    sensors.dynamic_sensor_hal \
    android.frameworks.sensorservice-V1-ndk.vendor \
    android.frameworks.sensorservice@1.0.vendor

# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal-V1-ndk.vendor \
    android.hardware.thermal@1.0.vendor \
    android.hardware.thermal@2.0.vendor

# Update engine
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

# USB
PRODUCT_PACKAGES += \
    android.hardware.usb-V1-ndk.vendor \
    android.hardware.usb.gadget-V1-ndk.vendor \
    android.hardware.usb.gadget@1.1.vendor

# Vendor service manager
PRODUCT_PACKAGES += \
    vndservice \
    vndservicemanager

# Vibrator
PRODUCT_PACKAGES += \
    vendor.qti.hardware.vibrator.service

PRODUCT_COPY_FILES += \
    vendor/qcom/opensource/vibrator/excluded-input-devices.xml:$(TARGET_COPY_OUT_VENDOR)/etc/excluded-input-devices.xml

# Weaver
PRODUCT_PACKAGES += \
    android.hardware.weaver-V2-ndk.vendor

# WiFi
PRODUCT_PACKAGES += \
    android.hardware.wifi-service \
    android.hardware.wifi.hostapd@1.0.vendor \
    hostapd \
    hostapd_cli \
    libkeystore-engine-wifi-hidl \
    libkeystore-wifi-hidl \
    libwifi-hal \
    libwifi-hal-ctrl \
    libwifi-hal-qcom \
    libwpa_client \
    wpa_cli \
    wpa_supplicant \
    wpa_supplicant.conf

PRODUCT_PACKAGES += \
    android.hardware.wifi.supplicant-V1-ndk.vendor \
    android.hardware.wifi.supplicant-V2-ndk.vendor \
    android.hardware.wifi.hostapd-V1-ndk.vendor

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/wifi/WCNSS_qcom_cfg.ini:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/qca6750/WCNSS_qcom_cfg.ini \
    $(LOCAL_PATH)/configs/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    $(LOCAL_PATH)/configs/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf

# Vendor
$(call inherit-product, vendor/xiaomi/peridot/peridot-vendor.mk)
