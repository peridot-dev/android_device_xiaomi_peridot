#=============================================================================
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# All rights reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.
#=============================================================================

enable_thp()
{
	# THP enablement settings
	echo always > /sys/kernel/mm/transparent_hugepage/enabled

	#Enable the PASR support
	ddr_type=`od -An -tx /proc/device-tree/memory/ddr_device_type`
	ddr_type5="08"

	if [ -d /sys/kernel/mem-offline ]; then
		#only LPDDR5 supports PAAR
		if [ ${ddr_type:4:2} != $ddr_type5 ]; then
			setprop vendor.pasr.activemode.enabled false
		fi
		setprop vendor.pasr.enabled true
	else
		setprop vendor.pasr.enabled false
	fi
}

enable_thp
