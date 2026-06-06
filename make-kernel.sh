#!/bin/bash
set -e # Stops the script immediately if any command fails

echo "Welcome!"
echo ""

# 1. Clone the WSL2 kernel repo
if [ ! -d "WSL2-Linux-Kernel" ]; then
    git clone --depth=1 https://github.com/microsoft/WSL2-Linux-Kernel.git
fi
cd WSL2-Linux-Kernel

# 2. Installing comprehensive build dependencies
echo "Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y build-essential flex bison dwarves libssl-dev libelf-dev cpio qemu-utils bc rsync libncurses-dev

# 3. Copy default WSL config & apply custom options for Waydroid / Android Binder
echo "Applying kernel configuration updates..."
cp Microsoft/config-wsl .config

# Reduce build size
./scripts/config --disable CONFIG_DEBUG_INFO
./scripts/config --disable CONFIG_DEBUG_INFO_DWARF4
./scripts/config --disable CONFIG_DEBUG_INFO_DWARF5
./scripts/config --disable CONFIG_DEBUG_INFO_BTF
./scripts/config --disable CONFIG_DEBUG_INFO_REDUCED
./scripts/config --disable CONFIG_DEBUG_INFO_SPLIT

# Android / Waydroid
./scripts/config --enable CONFIG_ANDROID
./scripts/config --enable CONFIG_ANDROID_BINDER_IPC
./scripts/config --enable CONFIG_ANDROID_BINDERFS
./scripts/config --set-str CONFIG_ANDROID_BINDER_DEVICES "binder,hwbinder,vndbinder"

# Container support
./scripts/config --enable CONFIG_POSIX_MQUEUE
./scripts/config --enable CONFIG_STAGING

# Networking
./scripts/config --enable CONFIG_NETFILTER
./scripts/config --enable CONFIG_NF_CONNTRACK
./scripts/config --enable CONFIG_NF_NAT

# nftables (modern stack)
./scripts/config --enable CONFIG_NF_TABLES
./scripts/config --enable CONFIG_NF_TABLES_INET
./scripts/config --enable CONFIG_NFT_NAT
./scripts/config --enable CONFIG_NFT_MASQ
./scripts/config --enable CONFIG_NFT_COMPAT

# Compatibility for software that still uses iptables commands
./scripts/config --enable CONFIG_IP_NF_IPTABLES
./scripts/config --enable CONFIG_IP_NF_FILTER
./scripts/config --enable CONFIG_NETFILTER_XT_MATCH_CONNTRACK
./scripts/config --enable CONFIG_NETFILTER_XT_MATCH_STATE
./scripts/config --enable CONFIG_NETFILTER_XT_TARGET_MASQUERADE

# Virtual networking
./scripts/config --enable CONFIG_BRIDGE
./scripts/config --enable CONFIG_BRIDGE_NETFILTER
./scripts/config --enable CONFIG_VETH
./scripts/config --enable CONFIG_TUN

# SquashFS (Waydroid images)
./scripts/config --enable CONFIG_SQUASHFS
./scripts/config --enable CONFIG_SQUASHFS_XATTR
./scripts/config --enable CONFIG_SQUASHFS_ZLIB
./scripts/config --enable CONFIG_SQUASHFS_LZ4
./scripts/config --enable CONFIG_SQUASHFS_LZO
./scripts/config --enable CONFIG_SQUASHFS_XZ

# Resolve dependencies automatically
make olddefconfig

clear
# Core selection logic
echo "--------------------------------------------------"
echo "How many CPU cores would you like to use to build?"
echo "1) Use 1 core (Slower, keeps system responsive)"
echo "4) Use 4 cores (Faster compilation)"
echo "--------------------------------------------------"
read -p "Enter your choice [1 or 4]: " CORE_CHOICE

if [ "$CORE_CHOICE" = "4" ]; then
    CORES=4
    echo "Configured to use 4 cores."
else
    CORES=1
    echo "Configured to use 1 core (Default)."
fi

echo "Building kernel..."
# Build the kernel using the selected choice
make -j$CORES vmlinux
echo "Build complete!"

# 6. Copy kernel to Windows C: Drive
mkdir -p /mnt/c/wsl-kernel
cp vmlinux /mnt/c/wsl-kernel/wsl-kernel

echo "Your kernel is located at: C:\\wsl-kernel\\wsl-kernel"
echo ""
echo "Next Steps:"
echo "1. Create or edit your 'C:\\Users\\<YourUsername>\\.wslconfig' file."
echo "2. Add these lines to it:"
echo "   [wsl2]"
echo "   kernel=C:\\\\wsl-kernel\\\\wsl-kernel"
echo "3. Run 'wsl --shutdown' in Windows PowerShell to apply."
echo ""
echo "If binderfs is missing after reboot, run:"
echo "sudo mkdir -p /dev/binderfs"
