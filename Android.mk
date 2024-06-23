#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),peridot)
include $(call all-subdir-makefiles,$(LOCAL_PATH))

include $(CLEAR_VARS)

# A/B builds require us to create the mount points at compile time.
# Just creating it for all cases since it does not hurt.
FIRMWARE_MOUNT_POINT := $(TARGET_OUT_VENDOR)/firmware_mnt
$(FIRMWARE_MOUNT_POINT): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating $(FIRMWARE_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/firmware_mnt

BT_FIRMWARE_MOUNT_POINT := $(TARGET_OUT_VENDOR)/bt_firmware
$(BT_FIRMWARE_MOUNT_POINT): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating $(BT_FIRMWARE_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/bt_firmware

DSP_MOUNT_POINT := $(TARGET_OUT_VENDOR)/dsp
$(DSP_MOUNT_POINT): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating $(DSP_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/dsp

MODEM_FIRMWARE_MOUNT_POINT := $(TARGET_OUT_VENDOR)/modem_firmware
$(MODEM_FIRMWARE_MOUNT_POINT): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating $(FIRMWARE_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/modem_firmware

ALL_DEFAULT_INSTALLED_MODULES += $(FIRMWARE_MOUNT_POINT) $(BT_FIRMWARE_MOUNT_POINT) $(DSP_MOUNT_POINT) $(MODEM_FIRMWARE_MOUNT_POINT)

FIRMWARE_WLAN_SYMLINKS := $(TARGET_OUT_VENDOR)/firmware/
$(FIRMWARE_WLAN_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating wlan firmware symlinks: $@"
	@rm -rf $@/*
	@mkdir -p $@
	$(hide) ln -sf /data/vendor/firmware/wlanmdsp.mbn $@/wlanmdsp.otaupdate

FIRMWARE_WLAN_QCA_CLD_QCA6750_SYMLINKS := $(TARGET_OUT_VENDOR)/firmware/wlan/qca_cld/qca6750/
$(FIRMWARE_WLAN_QCA_CLD_QCA6750_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating qca6750 qca_cld wlan firmware symlinks: $@"
	@rm -rf $@/*
	@mkdir -p $@
	$(hide) ln -sf /vendor/etc/wifi/qca6750/WCNSS_qcom_cfg.ini $@/WCNSS_qcom_cfg.ini
	$(hide) ln -sf /mnt/vendor/persist/wlan/wlan_mac.bin $@/wlan_mac.bin

ALL_DEFAULT_INSTALLED_MODULES += $(FIRMWARE_WLAN_SYMLINKS) $(FIRMWARE_WLAN_QCA_CLD_QCA6750_SYMLINKS)

EGL_LIBS_SYMLINKS := $(TARGET_OUT_VENDOR)/lib64/
$(EGL_LIBS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating EGL symlinks: $@"
	@mkdir -p $@
	$(hide) ln -sf egl/libEGL_adreno.so $@libEGL_adreno.so
	$(hide) ln -sf egl/libGLESv2_adreno.so $@libGLESv2_adreno.so
	$(hide) ln -sf egl/libq3dtools_adreno.so $@libq3dtools_adreno.so

ALL_DEFAULT_INSTALLED_MODULES += $(EGL_LIBS_SYMLINKS)

CNE_LIBS_SYMLINKS := $(TARGET_OUT_VENDOR)/app/CneApp/lib/arm64
$(CNE_LIBS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating CneApp symlinks: $@"
	@mkdir -p $@
	$(hide) ln -sf /vendor/lib64/libvndfwk_detect_jni.qti_vendor.so $@/libvndfwk_detect_jni.qti_vendor.so

ALL_DEFAULT_INSTALLED_MODULES += $(CNE_LIBS_SYMLINKS)

endif
