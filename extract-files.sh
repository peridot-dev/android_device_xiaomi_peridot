#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=peridot
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

# Define the default patchelf version used to patch blobs
# This will also be used for utility functions like FIX_SONAME
# Older versions break some camera blobs for us
export PATCHELF_VERSION=0_17_2

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
            CLEAN_VENDOR=false
            ;;
        -k | --kang )
            KANG="--kang"
            ;;
        -s | --section )
            SECTION="${2}"; shift
            CLEAN_VENDOR=false
            ;;
        * )
            SRC="${1}"
            ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        odm/etc/camera/enhance_motiontuning.xml|odm/etc/camera/motiontuning.xml|odm/etc/camera/night_motiontuning.xml)
            [ "$2" = "" ] && return 0
            sed -i 's/xml=version/xml version/g' "${2}"
            ;;
        system_ext/etc/vintf/manifest/vendor.qti.qesdsys.service.xml)
            [ "$2" = "" ] && return 0
            sed -i '1,6d' "${2}"
            ;;
        system_ext/lib64/libwfdnative.so)
            [ "$2" = "" ] && return 0
            ${PATCHELF} --remove-needed "android.hidl.base@1.0.so" "${2}"
            ;;
        vendor/bin/init.qcom.usb.sh)
            [ "$2" = "" ] && return 0
            sed -i 's/ro.product.marketname/ro.product.odm.marketname/g' "${2}"
            ;;
        # MiuiCamera
        system/lib64/libgui-xiaomi.so)
            [ "$2" = "" ] && return 0
            ${PATCHELF} --set-soname libgui-xiaomi.so "${2}"
            ;;
        system/lib64/libcamera_algoup_jni.xiaomi.so|system/lib64/libcamera_mianode_jni.xiaomi.so)
            [ "$2" = "" ] && return 0
            ${PATCHELF} --replace-needed libgui.so libgui-xiaomi.so "${2}"
            ;;
        system/priv-app/MiuiCamera/MiuiCamera.apk)
            [ "$2" = "" ] && return 0
            tmp_dir="${EXTRACT_TMP_DIR}/MiuiCamera"
            apktool d -q "${2}" -o "${tmp_dir}" -f
            grep -rl "com.miui.gallery" "${tmp_dir}" | xargs sed -i 's|"com.miui.gallery"|"com.google.android.apps.photos"|g'
            apktool b -q "${tmp_dir}" -o "${2}"
            rm -rf "${tmp_dir}"
            split --bytes=20M -d "${2}" "${2}".part
            ;;
        vendor/lib64/vendor.libdpmframework.so)
	    [ "$2" = "" ] && return 0
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/etc/media_codecs.xml|vendor/etc/media_codecs_cliffs_v0.xml|vendor/etc/media_codecs_performance_cliffs_v0.xml)
            [ "$2" = "" ] && return 0
            sed -i -E '/media_codecs_(google_audio|google_c2|google_telephony|vendor_audio)/d' "${2}"
            ;;
        vendor/etc/seccomp_policy/atfwd@2.0.policy)
            [ "$2" = "" ] && return 0
            grep -q "gettid: 1" "${2}" || echo "gettid: 1" >> "${2}"
            ;;
        vendor/etc/seccomp_policy/c2audio.vendor.ext-arm64.policy)
            [ "$2" = "" ] && return 0
            grep -q "setsockopt: 1" "${2}" || echo "setsockopt: 1" >> "${2}"
            ;;
        vendor/etc/seccomp_policy/wfdhdcphalservice.policy)
            [ "$2" = "" ] && return 0
            grep -q "gettid: 1" "${2}" || echo "gettid: 1" >> "${2}"
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}

function blob_fixup_dry() {
    blob_fixup "$1" ""
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
