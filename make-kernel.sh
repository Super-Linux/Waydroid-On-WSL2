#!/bin/bash
set -e # Stops the script immediately if any command fails

echo "=================================================="
echo "   WSL2 Kernel Builder for Waydroid & Android    "
echo "=================================================="
echo ""

# 1. Clone the WSL2 kernel repo
if [ ! -d "WSL2-Linux-Kernel" ]; then
    echo "Cloning WSL2 kernel repository..."
    git clone https://github.com/microsoft/WSL2-Linux-Kernel.git
fi
cd WSL2-Linux-Kernel

# 2. Installing comprehensive build dependencies
echo "Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y build-essential flex bison dwarves libssl-dev libelf-dev cpio qemu-utils bc rsync libncurses-dev

# 3. Copy default WSL config & apply custom options for Waydroid / Android Binder
echo "Applying kernel configuration updates..."
cp Microsoft/config-wsl .config

# 2. disable debugging 
./scripts/config --disable CONFIG_DEBUG_INFO
./scripts/config --disable CONFIG_DEBUG_INFO_DWARF4
./scripts/config --disable CONFIG_DEBUG_INFO_DWARF5
./scripts/config --disable CONFIG_DEBUG_INFO_BTF
./scripts/config --disable CONFIG_DEBUG_INFO_REDUCED
./scripts/config --disable CONFIG_DEBUG_INFO_SPLIT

# 3. Mandatory Android Communication Pipes
./scripts/config --enable CONFIG_ANDROID
./scripts/config --enable CONFIG_ANDROID_BINDER_IPC
./scripts/config --enable CONFIG_ANDROID_BINDERFS
./scripts/config --set-str CONFIG_ANDROID_BINDER_DEVICES "binder,hwbinder,vndbinder"
./scripts/config --enable CONFIG_STAGING

# 4. Minimum Networking Required for Waydroid Wifi
./scripts/config --enable CONFIG_IP_NF_IPTABLES
./scripts/config --enable CONFIG_IP_NF_FILTER
./scripts/config --enable CONFIG_NETFILTER_XT_TARGET_MASQUERADE
./scripts/config --enable CONFIG_BRIDGE
./scripts/config --enable CONFIG_VETH

# 5. Mandatory to mount Waydroid's Android OS files
./scripts/config --enable CONFIG_SQUASHFS
./scripts/config --enable CONFIG_SQUASHFS_XZ

# Resolve dependencies automatically
make olddefconfig

clear
# Detect total available CPU cores dynamically
MAX_CORES=$(nproc)

echo "--------------------------------------------------"
echo "How many CPU cores would you like to use to build?"
echo "1) Use 1 core (Slower, keeps system responsive)"
echo "2) Use maximum speed ($MAX_CORES cores available)"
echo "--------------------------------------------------"
read -p "Enter your choice [1 or 2]: " CORE_CHOICE

if [ "$CORE_CHOICE" = "2" ]; then
    CORES=$MAX_CORES
    echo "Configured to use maximum speed ($CORES cores)."
else
    CORES=1
    echo "Configured to use 1 core (Default)."
fi

echo "Building kernel..."
# Build the kernel using the selected choice
make -j$CORES vmlinux
echo "Build complete!"

# 6. Copy kernel to Windows C: Drive
echo "Deploying kernel to your Windows host..."
mkdir -p /mnt/c/wsl-kernel
cp vmlinux /mnt/c/wsl-kernel/wsl-kernel

echo "--------------------------------------------------"
echo "Your kernel is located at: C:\\wsl-kernel\\wsl-kernel"
echo ""
echo "Next Steps:"
echo "1. Create or edit your 'C:\\Users\\<YourUsername>\\.wslconfig' file."
echo "2. Add these lines to it:"
echo "   [wsl2]"
echo "   kernel=C:\\\\wsl-kernel\\\\wsl-kernel"
echo "3. Run 'wsl --shutdown' in Windows PowerShell to apply."
echo "--------------------------------------------------"
