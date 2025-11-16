#!/bin/bash

# Define colour codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

fatal() {
    echo -e "${RED}[FATAL] $1${NC}"
    return 1
}

info() {
    echo -e "${CYAN}$1${NC}"
}

success() {
    echo -e "${GREEN}$1${NC}"
}

warn() {
    echo -e "${YELLOW}$1${NC}"
}

info "Cloning All resources"

# Vendor
info "Cloning vendor tree"
git clone -b lineage-23.0 --depth 1 https://github.com/powerhouse1997/proprietary_vendor_xiaomi_peridot.git vendor/xiaomi/peridot || fatal "Vendor tree clone failed!"

# Kernel sources
info "Cloning Kernel sources"
git clone -b lineage-23.0 --depth 1 https://github.com/powerhouse1997/android_kernel_xiaomi_sm8635.git kernel/xiaomi/sm8635 || fatal "Kernel source clone failed!"

warn "Cleaning kernel modules directory (if exists)"
rm -rf kernel/xiaomi/sm8635-modules
info "Cloning kernel modules"
git clone -b lineage-23.0 https://github.com/powerhouse1997/android_kernel_xiaomi_sm8635-modules.git kernel/xiaomi/sm8635-modules || fatal "Kernel modules clone failed!"

warn "Cleaning kernel devicetrees directory (if exists)"
rm -rf kernel/xiaomi/sm8635-devicetrees
info "Cloning kernel devicetrees"
git clone -b lineage-23.0 https://github.com/powerhouse1997/android_kernel_xiaomi_sm8635-devicetrees.git kernel/xiaomi/sm8635-devicetrees || fatal "Kernel devicetrees clone failed!"

# Hardware xiaomi
info "Cloning hardware xiaomi test branch"
warn "Cleaning hardware/xiaomi directory (if exists)"
rm -rf hardware/xiaomi
git clone -b lineage-23.0 https://github.com/powerhouse1997/android_hardware_xiaomi.git hardware/xiaomi || fatal "Hardware xiaomi clone failed!"

# Dolby
info "Cloning XiaomiDolby"
git clone -b lineage-23.0 https://github.com/powerhouse1997/android_packages_apps_XiaomiDolby.git packages/apps/XiaomiDolby || fatal "XiaomiDolby clone failed!"

success "All resources cloned successfully!"

return 0
