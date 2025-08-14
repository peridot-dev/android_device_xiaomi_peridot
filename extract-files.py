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
    'hardware/qcom-caf/sm8650',
    'hardware/qcom-caf/wlan',
    'hardware/xiaomi',
    'vendor/qcom/opensource/commonsys/display',
    'vendor/qcom/opensource/commonsys-intf/display',
    'vendor/qcom/opensource/dataservices',
    'vendor/qcom/opensource/display',
]

def lib_fixup_vendor_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_{partition}' if partition == 'vendor' else None

lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    (
        'sqlite3',
        'vendor.qti.imsrtpservice@3.0',
        'vendor.qti.imsrtpservice@3.1',
        'vendor.qti.ImsRtpService-V1-ndk',
        'vendor.qti.diaghal@1.0',
        'vendor.qti.hardware.wifidisplaysession@1.0',
    ): lib_fixup_vendor_suffix,
}

blob_fixups: blob_fixups_user_type = {
    'system_ext/etc/vintf/manifest/vendor.qti.qesdsys.service.xml': blob_fixup()
        .regex_replace(r'(?s)^.*?(?=<manifest)', ''),
    'system_ext/lib64/libwfdnative.so': blob_fixup()
        .remove_needed('android.hidl.base@1.0.so'),
    'system_ext/lib64/libwfdservice.so': blob_fixup()
        .replace_needed(
            'android.media.audio.common.types-V2-cpp.so',
            'android.media.audio.common.types-V4-cpp.so'
        ),
    (
        'odm/etc/camera/enhance_motiontuning.xml',
        'odm/etc/camera/motiontuning.xml',
        'odm/etc/camera/night_motiontuning.xml'
    ): blob_fixup()
        .regex_replace('xml=version', 'xml version'),
    (
        'odm/lib64/libTrueSight.so',
        'odm/lib64/libAncHumanVideoBokehV4.so',
        'odm/lib64/libwa_widelens_undistort.so',
        'vendor/lib64/libMiVideoFilter.so',
        'vendor/lib64/libmorpho_ubwc.so'
    ): blob_fixup()
        .clear_symbol_version('AHardwareBuffer_allocate')
        .clear_symbol_version('AHardwareBuffer_describe')
        .clear_symbol_version('AHardwareBuffer_lock')
        .clear_symbol_version('AHardwareBuffer_lockPlanes')
        .clear_symbol_version('AHardwareBuffer_release')
        .clear_symbol_version('AHardwareBuffer_unlock'),
    'vendor/etc/seccomp_policy/c2audio.vendor.ext-arm64.policy': blob_fixup()
        .add_line_if_missing('setsockopt: 1'),
    (
        'vendor/etc/seccomp_policy/atfwd@2.0.policy',
        'vendor/etc/seccomp_policy/wfdhdcphalservice.policy'
    ): blob_fixup()
        .add_line_if_missing('gettid: 1'),
    ('vendor/bin/pnscr'): blob_fixup()
        .add_needed('libbase_shim.so'),
    (
        'vendor/bin/hw/android.hardware.security.keymint-service.strongbox-nxp',
        'vendor/lib64/libjc_keymint_nxp.so'
    ): blob_fixup()
        .replace_needed(
            'android.hardware.security.keymint-V3-ndk.so',
            'android.hardware.security.keymint-V4-ndk.so'
    ),
    (
        'vendor/lib64/hw/camera.qcom.so',
        'vendor/lib64/hw/camera.xiaomi.so',
        'vendor/lib64/hw/com.qti.chi.override.so',
        'vendor/lib64/libchifeature2.so',
    ): blob_fixup()
        .add_needed('libprocessgroup_shim.so')
        .replace_needed(
            'android.hardware.graphics.allocator-V1-ndk.so',
            'android.hardware.graphics.allocator-V2-ndk.so'
    ),
    (
        'vendor/lib64/libcameraopt.so',
        'vendor/lib64/libcamxcommonutils.so',
        'vendor/lib64/libmialgoengine.so'
    ): blob_fixup()
        .add_needed('libprocessgroup_shim.so'),
    'vendor/lib64/libqcodec2_core.so': blob_fixup()
        .add_needed('libcodec2_shim.so'),
    'vendor/lib64/vendor.libdpmframework.so': blob_fixup()
        .add_needed('libhidlbase_shim.so'),
    (
        'odm/lib64/camera/com.qti.actuator.peridot_aac_imx882_gt9764ber_wide_i_actuator.so',
        'odm/lib64/camera/com.qti.actuator.peridot_ofilm_imx882_aw86016csr_wide_ii_actuator.so',
        'odm/lib64/camera/com.qti.actuator.peridot_ofilm_imx882_gt9764ber_wide_iii_actuator.so',
        'odm/lib64/camera/com.qti.eeprom.peridot_aac_imx355_gt24p64e_ultra_i_eeprom.so',
        'odm/lib64/camera/com.qti.eeprom.peridot_aac_imx882_gt24p128f_wide_i_eeprom.so',
        'odm/lib64/camera/com.qti.eeprom.peridot_aac_ov20b40_gt24p64e_front_ii_eeprom.so',
        'odm/lib64/camera/com.qti.eeprom.peridot_ofilm_imx355_p24c64e_ultra_ii_eeprom.so',
        'odm/lib64/camera/com.qti.eeprom.peridot_ofilm_imx882_bl24sa128b_wide_ii_eeprom.so',
        'odm/lib64/camera/com.qti.eeprom.peridot_ofilm_imx882_gt24p128f_wide_iii_eeprom.so',
        'odm/lib64/camera/com.qti.eeprom.peridot_ofilm_ov20b40_p24c64e_front_eeprom.so',
        'odm/lib64/camera/com.qti.sensor.peridot_aac_imx355_ultra_i.so',
        'odm/lib64/camera/com.qti.sensor.peridot_aac_imx882_wide_i.so',
        'odm/lib64/camera/com.qti.sensor.peridot_ofilm_ov20b40_front.so',
        'odm/lib64/camera/components/com.jigan.node.videobokeh.so',
        'odm/lib64/camera/components/com.mi.node.aiasd.so',
        'odm/lib64/camera/components/com.mi.node.skinbeautifier.so',
        'odm/lib64/camera/components/com.mi.node.videonight.so',
        'odm/lib64/camera/libchxlogicalcameratable.so',
        'vendor/lib64/camera/components/com.mi.node.dlengine.so',
        'vendor/lib64/camera/components/com.mi.node.mawsaliency.so',
        'vendor/lib64/camera/components/com.mi.node.videobokeh.so',
        'vendor/lib64/camera/components/com.mi.node.videofilter.so',
        'vendor/lib64/camera/components/com.qti.hwcfg.bps.so',
        'vendor/lib64/camera/components/com.qti.hwcfg.ife.so',
        'vendor/lib64/camera/components/com.qti.hwcfg.ipe.so',
        'vendor/lib64/camera/components/com.qti.node.aon.so',
        'vendor/lib64/camera/components/com.qti.node.depth.so',
        'vendor/lib64/camera/components/com.qti.node.depthprovider.so',
        'vendor/lib64/camera/components/com.qti.node.dewarp.so',
        'vendor/lib64/camera/components/com.qti.node.eisv2.so',
        'vendor/lib64/camera/components/com.qti.node.eisv3.so',
        'vendor/lib64/camera/components/com.qti.node.evadepth.so',
        'vendor/lib64/camera/components/com.qti.node.gme.so',
        'vendor/lib64/camera/components/com.qti.node.gyrornn.so',
        'vendor/lib64/camera/components/com.qti.node.hdr10pgen.so',
        'vendor/lib64/camera/components/com.qti.node.hdr10phist.so',
        'vendor/lib64/camera/components/com.qti.node.itofpreprocess.so',
        'vendor/lib64/camera/components/com.qti.node.ml.so',
        'vendor/lib64/camera/components/com.qti.node.mlinference.so',
        'vendor/lib64/camera/components/com.qti.node.pixelstats.so',
        'vendor/lib64/camera/components/com.qti.node.seg.so',
        'vendor/lib64/camera/components/com.qti.node.swec.so',
        'vendor/lib64/camera/components/com.qti.node.swregistration.so',
        'vendor/lib64/camera/components/com.qti.stats.cnndriver.so',
        'vendor/lib64/camera/components/libcamxevainterface.so',
        'vendor/lib64/camera/components/libdepthmapwrapper_itof.so',
        'vendor/lib64/camera/components/libdepthmapwrapper_secure.so',
        'vendor/lib64/com.qti.camx.chiiqutils.so',
        'vendor/lib64/com.qti.chiusecaseselector.so',
        'vendor/lib64/com.qti.feature2.afbrckt.so',
        'vendor/lib64/com.qti.feature2.anchorsync.so',
        'vendor/lib64/com.qti.feature2.demux.so',
        'vendor/lib64/com.qti.feature2.derivedoffline.so',
        'vendor/lib64/com.qti.feature2.fusion.so',
        'vendor/lib64/com.qti.feature2.generic.so',
        'vendor/lib64/com.qti.feature2.gs.sm8650.so',
        'vendor/lib64/com.qti.feature2.hdr.so',
        'vendor/lib64/com.qti.feature2.mcreprocrt.so',
        'vendor/lib64/com.qti.feature2.memcpy.so',
        'vendor/lib64/com.qti.feature2.metadataserializer.so',
        'vendor/lib64/com.qti.feature2.mfsr.so',
        'vendor/lib64/com.qti.feature2.ml.so',
        'vendor/lib64/com.qti.feature2.mux.so',
        'vendor/lib64/com.qti.feature2.offlinestatsregeneration.so',
        'vendor/lib64/com.qti.feature2.qcfa.so',
        'vendor/lib64/com.qti.feature2.rawhdr.so',
        'vendor/lib64/com.qti.feature2.realtimeserializer.so',
        'vendor/lib64/com.qti.feature2.rt.so',
        'vendor/lib64/com.qti.feature2.rtmcx.so',
        'vendor/lib64/com.qti.feature2.serializer.so',
        'vendor/lib64/com.qti.feature2.statsregeneration.so',
        'vendor/lib64/com.qti.feature2.stub.so',
        'vendor/lib64/com.qti.feature2.swmf.so',
        'vendor/lib64/com.qti.qseeutils.so',
        'vendor/lib64/com.qualcomm.mcx.distortionmapper.so',
        'vendor/lib64/com.qualcomm.mcx.linearmapper.so',
        'vendor/lib64/com.qualcomm.mcx.nonlinearmapper.so',
        'vendor/lib64/com.qualcomm.mcx.policy.mfl.so',
        'vendor/lib64/com.qualcomm.qti.mcx.usecase.extension.so',
        'vendor/lib64/com.xiaomi.camx.hook.so',
        'vendor/lib64/com.xiaomi.chi.hook.so',
        'vendor/lib64/hw/camera.qcom.sm8650.so',
        'vendor/lib64/hw/com.qti.chi.offline.so',
        'vendor/lib64/libcamerapostproc.so',
        'vendor/lib64/libcamxhwnodecontext.so',
        'vendor/lib64/libcamxifestriping.so',
        'vendor/lib64/libcamximageformatutils.so',
        'vendor/lib64/libcamxncsdatafactory.so',
        'vendor/lib64/libcom.xiaomi.mawutilsold.so',
        'vendor/lib64/libcommonchiutils.so',
        'vendor/lib64/libfastmessage.so',
        'vendor/lib64/libhme.so',
        'vendor/lib64/libipebpsstriping.so',
        'vendor/lib64/libipebpsstriping170.so',
        'vendor/lib64/libipebpsstriping480.so',
        'vendor/lib64/libisphwsetting.so',
        'vendor/lib64/libjpege.so',
        'vendor/lib64/libmctfengine_stub.so',
        'vendor/lib64/libmfec.so',
        'vendor/lib64/libmmcamera_bestats.so',
        'vendor/lib64/libmmcamera_cac.so',
        'vendor/lib64/libmmcamera_lscv35.so',
        'vendor/lib64/libmmcamera_pdpc.so',
        'vendor/lib64/libofflinefeatureintf.so',
        'vendor/lib64/libopestriping.so',
        'vendor/lib64/libtfestriping.so',
        'vendor/lib64/libubifocus.so',
        'vendor/lib64/vendor.qti.hardware.camera.aon-service-impl.so',
        'vendor/lib64/vendor.qti.hardware.camera.offlinecamera-service-impl.so',
        'vendor/lib64/vendor.qti.hardware.camera.postproc@1.0-service-impl.so',
    ): blob_fixup()
        .replace_needed(
            'android.hardware.graphics.allocator-V1-ndk.so',
            'android.hardware.graphics.allocator-V2-ndk.so'
    ),
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
