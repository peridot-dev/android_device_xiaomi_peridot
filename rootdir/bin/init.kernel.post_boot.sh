#=============================================================================
# Copyright (c) 2022-2023 Qualcomm Technologies, Inc.
# All Rights Reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.
#
# Copyright (c) 2009-2012, 2014-2019, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

# Configure Zram parameters
MemTotalStr=`cat /proc/meminfo | grep MemTotal`
MemTotal=${MemTotalStr:16:8}

let RamSizeGB="( $MemTotal / 1048576 ) + 1"
diskSizeUnit=M

# Zram disk - 75%
let zRamSizeMB="( $RamSizeGB * 1024 ) * 3 / 4"

# Use MB avoid 32 bit overflow
if [ $zRamSizeMB -gt 6144 ]; then
    let zRamSizeMB=6144
fi

echo "$zRamSizeMB""$diskSizeUnit" > /sys/block/zram0/disksize

# ZRAM may use more memory than it saves if SLAB_STORE_USER
# debug option is enabled.
echo 0 > /sys/kernel/slab/zs_handle/store_user
echo 0 > /sys/kernel/slab/zspage/store_user

mkswap /dev/block/zram0
swapon /dev/block/zram0 -p 32758

# Configure read ahead kb values
dmpts=$(ls /sys/block/*/queue/read_ahead_kb | grep -e dm -e mmc -e sd)

# Set 512 read ahead kb for all targets.
ra_kb=512
for dm in $dmpts; do
    if [ `cat $(dirname $dm)/../removable` -eq 0 ]; then
        echo $ra_kb > $dm
    fi
done

# Configure memory parameters
echo 100 > /proc/sys/vm/swappiness

# Disable periodic kcompactd wakeups. We do not use THP, so having many
# huge pages is not as necessary.
echo 0 > /proc/sys/vm/compaction_proactiveness

# THP enablement settings
echo always > /sys/kernel/mm/transparent_hugepage/enabled

# Prevent page faults on THP-elgible VMAs from causing reclaim or compaction
echo never > /sys/kernel/mm/transparent_hugepage/defrag

## Goal is to make khugepaged as inert as possible using the below settings
# Prevent khugepaged from doing reclaim or compaction
echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag

# Minimize the number of pages that khugepaged will scan
echo 1 > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan

# Maximize the amount of time that khugepaged is asleep for
echo 4294967295 > /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs
echo 4294967295 > /sys/kernel/mm/transparent_hugepage/khugepaged/alloc_sleep_millisecs

# Restrict khugepaged promotions as much as possible. Only allow khugepaged to promote
# if all pages in a VMA are (1) not invalid PTEs, (2) not swapped out PTEs, (3) not
# shared PTEs.
echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none
echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap
echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_shared

# Set the min_free_kbytes to standard kernel value
# We store min_free_kbytes into a vendor property so that the PASR
# HAL can read and set the value for it.
echo 11584 > /proc/sys/vm/min_free_kbytes
setprop vendor.memory.min_free_kbytes 11584

# Enable the PASR support
setprop vendor.pasr.enabled true

# Set per-app max kgsl reclaim limit and per shrinker call limit
echo 38400 > /sys/class/kgsl/kgsl/page_reclaim_per_call
echo 51200 > /sys/class/kgsl/kgsl/max_reclaim_limit

# Configure RT parameters:
# Long running RT task detection is confined to consolidated builds.
# Set RT throttle runtime to 50ms more than long running RT
# task detection time.
# Set RT throttle period to 100ms more than RT throttle runtime.
echo 1350000 > /proc/sys/kernel/sched_rt_period_us
echo 1250000 > /proc/sys/kernel/sched_rt_runtime_us

# Configure maximum frequency when CPUs are partially halted
echo 1190400 > /proc/sys/walt/sched_max_freq_partial_halt

# Core Control Paramters for Silvers
echo 0xFF > /sys/devices/system/cpu/cpu0/core_ctl/nrrun_cpu_mask
echo 0x00 > /sys/devices/system/cpu/cpu0/core_ctl/nrrun_cpu_misfit_mask
echo 0x00 > /sys/devices/system/cpu/cpu0/core_ctl/assist_cpu_mask
echo 0x00 > /sys/devices/system/cpu/cpu0/core_ctl/assist_cpu_misfit_mask

# Core control parameters for gold
echo 3 > /sys/devices/system/cpu/cpu3/core_ctl/min_cpus
echo 60 > /sys/devices/system/cpu/cpu3/core_ctl/busy_up_thres
echo 30 > /sys/devices/system/cpu/cpu3/core_ctl/busy_down_thres
echo 100 > /sys/devices/system/cpu/cpu3/core_ctl/offline_delay_ms
echo 3 > /sys/devices/system/cpu/cpu3/core_ctl/task_thres
echo 0 0 0 > /sys/devices/system/cpu/cpu3/core_ctl/not_preferred
echo 0xF8 > /sys/devices/system/cpu/cpu3/core_ctl/nrrun_cpu_mask
echo 0x07 > /sys/devices/system/cpu/cpu3/core_ctl/nrrun_cpu_misfit_mask
echo 0x00 > /sys/devices/system/cpu/cpu3/core_ctl/assist_cpu_mask
echo 0x00 > /sys/devices/system/cpu/cpu3/core_ctl/assist_cpu_misfit_mask

# Core control parameters for gold+
echo 0 > /sys/devices/system/cpu/cpu7/core_ctl/min_cpus
echo 60 > /sys/devices/system/cpu/cpu7/core_ctl/busy_up_thres
echo 30 > /sys/devices/system/cpu/cpu7/core_ctl/busy_down_thres
echo 100 > /sys/devices/system/cpu/cpu7/core_ctl/offline_delay_ms
echo 1 > /sys/devices/system/cpu/cpu7/core_ctl/task_thres
echo 1 > /sys/devices/system/cpu/cpu7/core_ctl/not_preferred
echo 0x80 > /sys/devices/system/cpu/cpu7/core_ctl/nrrun_cpu_mask
echo 0x78 > /sys/devices/system/cpu/cpu7/core_ctl/nrrun_cpu_misfit_mask
echo 0x78 > /sys/devices/system/cpu/cpu7/core_ctl/assist_cpu_mask
echo 0x07 > /sys/devices/system/cpu/cpu7/core_ctl/assist_cpu_misfit_mask

echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/enable
echo 1 > /sys/devices/system/cpu/cpu3/core_ctl/enable
echo 1 > /sys/devices/system/cpu/cpu7/core_ctl/enable

# Setting b.L scheduler parameters
echo 71 95 > /proc/sys/walt/sched_upmigrate
echo 65 85 > /proc/sys/walt/sched_downmigrate
echo 85 > /proc/sys/walt/sched_group_downmigrate
echo 100 > /proc/sys/walt/sched_group_upmigrate
echo 1 > /proc/sys/walt/sched_walt_rotate_big_tasks
echo 51 > /proc/sys/walt/sched_min_task_util_for_boost
echo 35 > /proc/sys/walt/sched_min_task_util_for_colocation
echo 20000000 > /proc/sys/walt/sched_coloc_downmigrate_ns
echo 0 > /proc/sys/walt/sched_coloc_busy_hysteresis_enable_cpus
echo 8500000 8500000 8500000 5000000 5000000 5000000 5000000 2000000 > /proc/sys/walt/sched_util_busy_hyst_cpu_ns
echo 255 > /proc/sys/walt/sched_util_busy_hysteresis_enable_cpus
echo 1 1 1 15 15 15 15 15 > /proc/sys/walt/sched_util_busy_hyst_cpu_util
echo 40 > /proc/sys/walt/sched_cluster_util_thres_pct
echo 30 > /proc/sys/walt/sched_idle_enough
echo 10 > /proc/sys/walt/sched_ed_boost

# Set early upmigrate tunables
echo 2009 1575 > /proc/sys/walt/sched_early_downmigrate
echo 1680 1077 > /proc/sys/walt/sched_early_upmigrate

# Enable Gold CPUs for pipeline
echo 120 > /proc/sys/walt/sched_pipeline_cpus

# set the threshold for low latency task boost feature which prioritize
# binder activity tasks
echo 325 > /proc/sys/walt/walt_low_latency_task_threshold

# Configure maximum frequency of silver cluster when load is not detected and ensure that
# other clusters' fmax remains uncapped by setting the frequency to S32_MAX
echo 1708800 2707200 2147483647 > /proc/sys/walt/sched_fmax_cap

# Turn off scheduler boost at the end
echo 0 > /proc/sys/walt/sched_boost

# Configure input boost settings
echo 1113600 0 0 0 0 0 0 0 > /proc/sys/walt/input_boost/input_boost_freq
echo 120 > /proc/sys/walt/input_boost/input_boost_ms

# Configure powerkey input boost settings
echo 1804800 0  0 2572800 0 0 0 2457600 > /proc/sys/walt/input_boost/powerkey_input_boost_freq
echo 400 > /proc/sys/walt/input_boost/powerkey_input_boost_ms

echo "walt" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
echo "walt" > /sys/devices/system/cpu/cpufreq/policy3/scaling_governor
echo "walt" > /sys/devices/system/cpu/cpufreq/policy7/scaling_governor

echo 0 > /sys/devices/system/cpu/cpufreq/policy0/walt/down_rate_limit_us
echo 0 > /sys/devices/system/cpu/cpufreq/policy0/walt/up_rate_limit_us
echo 0 > /sys/devices/system/cpu/cpufreq/policy3/walt/down_rate_limit_us
echo 0 > /sys/devices/system/cpu/cpufreq/policy3/walt/up_rate_limit_us
echo 0 > /sys/devices/system/cpu/cpufreq/policy7/walt/down_rate_limit_us
echo 0 > /sys/devices/system/cpu/cpufreq/policy7/walt/up_rate_limit_us

echo 0 > /sys/devices/system/cpu/cpufreq/policy0/walt/pl
echo 0 > /sys/devices/system/cpu/cpufreq/policy3/walt/pl
echo 0 > /sys/devices/system/cpu/cpufreq/policy7/walt/pl
echo 1 > /proc/sys/walt/sched_conservative_pl

echo 595200 > /sys/devices/system/cpu/cpufreq/policy0/walt/rtg_boost_freq

echo 1113600 > /sys/devices/system/cpu/cpufreq/policy0/walt/hispeed_freq
echo 1190400 > /sys/devices/system/cpu/cpufreq/policy3/walt/hispeed_freq
echo 1459200 > /sys/devices/system/cpu/cpufreq/policy7/walt/hispeed_freq

echo 85 > /sys/devices/system/cpu/cpufreq/policy3/walt/hispeed_load
echo 85 > /sys/devices/system/cpu/cpufreq/policy7/walt/hispeed_load

echo 595200 > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
echo 633600 > /sys/devices/system/cpu/cpufreq/policy3/scaling_min_freq
echo 633600 > /sys/devices/system/cpu/cpufreq/policy7/scaling_min_freq
echo "0:595200 3:633600 7:633600" > /data/vendor/perfd/default_scaling_min_freq

# Reset the RT boost, which is 1024 (max) by default.
echo 0 > /proc/sys/kernel/sched_util_clamp_min_rt_default

# Cpuset parameters
echo 0-2 > /dev/cpuset/background/cpus
echo 0-2 > /dev/cpuset/system-background/cpus
echo 0-7 > /dev/cpuset/top-app/cpus

# Configure bus-dcvs
bus_dcvs="/sys/devices/system/cpu/bus_dcvs"

for device in $bus_dcvs/*
do
    cat $device/hw_min_freq > $device/boost_freq
done

for llccbw in $bus_dcvs/LLCC/*bwmon-llcc
do
    echo "4577 7110 9155 12298 14236 16265" > $llccbw/mbps_zones
    echo 4 > $llccbw/sample_ms
    echo 80 > $llccbw/io_percent
    echo 20 > $llccbw/hist_memory
    echo 30 > $llccbw/down_thres
    echo 0 > $llccbw/guard_band_mbps
    echo 250 > $llccbw/up_scale
    echo 1600 > $llccbw/idle_mbps
    echo 40 > $llccbw/window_ms
done

for ddrbw in $bus_dcvs/DDR/*bwmon-ddr
do
    echo "2086 5931 7980 10437 12157 14060 16113" > $ddrbw/mbps_zones
    echo 4 > $ddrbw/sample_ms
    echo 80 > $ddrbw/io_percent
    echo 20 > $ddrbw/hist_memory
    echo 30 > $ddrbw/down_thres
    echo 0 > $ddrbw/guard_band_mbps
    echo 250 > $ddrbw/up_scale
    echo 1600 > $ddrbw/idle_mbps
    echo 40 > $ddrbw/window_ms
done

for latfloor in $bus_dcvs/*/*latfloor
do
    echo 25000 > $latfloor/ipm_ceil
done

for l3gold in $bus_dcvs/L3/*gold
do
    echo 4000 > $l3gold/ipm_ceil
done

for l3prime in $bus_dcvs/L3/*prime
do
    echo 20000 > $l3prime/ipm_ceil
done

for qosgold in $bus_dcvs/DDRQOS/*gold
do
    echo 50 > $qosgold/ipm_ceil
done

for qosprime in $bus_dcvs/DDRQOS/*prime
do
    echo 100 > $qosprime/ipm_ceil
done

for ddrprime in $bus_dcvs/DDR/*prime
do
    echo 25 > $ddrprime/freq_scale_pct
    echo 1500 > $ddrprime/freq_scale_floor_mhz
    echo 2726 > $ddrprime/freq_scale_ceil_mhz
done

for qosprimelatflr in $bus_dcvs/DDRQOS/*prime-latfloor
do
    echo 6000 > $qosprimelatflr/ipm_ceil
done

echo s2idle > /sys/power/mem_sleep
echo N > /sys/devices/system/cpu/qcom_lpm/parameters/sleep_disabled
echo 0 > /proc/sys/vm/page-cluster

setprop vendor.post_boot.parsed 1
