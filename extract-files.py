#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixups,
    lib_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
]

def lib_fixup_vendor_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_{partition}' if partition == 'vendor' else None

lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    (
        'vendor.qti.imsrtpservice@3.0',
        'vendor.qti.imsrtpservice@3.1',
        'vendor.qti.ImsRtpService-V1-ndk',
        'vendor.qti.diaghal@1.0',
    ): lib_fixup_vendor_suffix,
}

blob_fixups: blob_fixups_user_type = {
    'system_ext/etc/vintf/manifest/vendor.qti.qesdsys.service.xml': blob_fixup()
        .regex_replace(r'(?s)^.*?(?=<manifest)', ''),
    'system_ext/lib64/libwfdnative.so': blob_fixup()
        .remove_needed('android.hidl.base@1.0.so'),
    (
        'odm/etc/camera/enhance_motiontuning.xml',
        'odm/etc/camera/motiontuning.xml',
        'odm/etc/camera/night_motiontuning.xml'
    ): blob_fixup()
        .regex_replace('xml=version', 'xml version'),
    'vendor/etc/seccomp_policy/c2audio.vendor.ext-arm64.policy': blob_fixup()
        .add_line_if_missing('setsockopt: 1'),
    (
        'vendor/etc/seccomp_policy/atfwd@2.0.policy',
        'vendor/etc/seccomp_policy/wfdhdcphalservice.policy'
    ): blob_fixup()
        .add_line_if_missing('gettid: 1'),
    (
        'vendor/lib64/hw/com.qti.chi.override.so',
        'vendor/lib64/hw/camera.xiaomi.so',
        'vendor/lib64/hw/camera.qcom.so',
        'vendor/lib64/libcameraopt.so',
        'vendor/lib64/libcamxcommonutils.so',
        'vendor/lib64/libchifeature2.so',
        'vendor/lib64/libmialgoengine.so'
    ): blob_fixup()
        .add_needed('libprocessgroup_shim.so'),
    'vendor/lib64/libqcodec2_core.so': blob_fixup()
        .add_needed('libcodec2_shim.so'),
    'vendor/lib64/vendor.libdpmframework.so': blob_fixup()
        .add_needed('libhidlbase_shim.so'),
}  # fmt: skip

module = ExtractUtilsModule(
    'peridot',
    'xiaomi',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
