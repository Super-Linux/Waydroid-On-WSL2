#!/bin/bash
set -e # Stops the script immediately if any command fails

echo "Welcome!"

# 1. Clone the WSL2 kernel repo
git clone --depth=1 https://github.com/microsoft/wsl2-linux-kernel
cd WSL2-Linux-Kernel

# 2. Installing build dependencies
echo "Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y build-essential ncurses-dev bison flex libssl-dev libelf-dev

# 3. Copy default WSL config
cp Microsoft/config-wsl .config

# 4. Apply custom kernel options for Waydroid / Android Binder
./scripts/config --file .config \
  --enable CONFIG_ANDROID \
  --enable CONFIG_ANDROID_BINDER_IPC \
  --enable CONFIG_ANDROID_BINDERFS \
  --set-str CONFIG_ANDROID_BINDER_DEVICES "binder,hwbinder,vndbinder" \
  \
  --enable CONFIG_STAGING \
  --enable CONFIG_PSI \
  \
  --enable CONFIG_CGROUPS \
  --enable CONFIG_MEMCG \
  --enable CONFIG_CGROUP_BPF \
  --enable CONFIG_NAMESPACES \
  --enable CONFIG_USER_NS \
  --enable CONFIG_PID_NS \
  --enable CONFIG_NET_NS \
  --enable CONFIG_IPC_NS \
  --enable CONFIG_UTS_NS \
  \
  --enable CONFIG_OVERLAY_FS \
  --enable CONFIG_TMPFS \
  --enable CONFIG_TMPFS_XATTR \
  --enable CONFIG_EXT4_FS \
  --enable CONFIG_FUSE_FS \
  \
  --enable CONFIG_SQUASHFS \
  --enable CONFIG_SQUASHFS_XZ \
  --enable CONFIG_SQUASHFS_ZSTD \
  --enable CONFIG_SQUASHFS_LZ4 \
  \
  --enable CONFIG_NET \
  --enable CONFIG_NETFILTER \
  --enable CONFIG_NF_NAT \
  --enable CONFIG_IP_NF_IPTABLES \
  --enable CONFIG_IP_NF_FILTER \
  --enable CONFIG_IP_NF_NAT \
  --enable CONFIG_IP_NF_TARGET_MASQUERADE \
  --enable CONFIG_BRIDGE \
  --enable CONFIG_VETH \
  --enable CONFIG_TUN \
  --enable CONFIG_MACVLAN \
  --enable CONFIG_IPVLAN \
  --enable CONFIG_DNS_RESOLVER \
  --enable CONFIG_PACKET \
  \
  --enable CONFIG_BPF \
  --enable CONFIG_BPF_SYSCALL \
  --enable CONFIG_NET_ACT_BPF \
  \
  --enable CONFIG_UCLAMP_TASK \
  --enable CONFIG_FAIR_GROUP_SCHED \
  \
  --enable CONFIG_QUOTA \
  --enable CONFIG_EXT4_FS_POSIX_ACL \
  --enable CONFIG_EXT4_FS_SECURITY \
  \
  --enable CONFIG_HYPERV \
  --enable CONFIG_HYPERV_UTILS \
  --enable CONFIG_HYPERV_BALLOON \
  --enable CONFIG_HYPERV_STORAGE \
  --enable CONFIG_HYPERV_NET \
  \
  --disable CONFIG_INFINIBAND \
  --disable CONFIG_CHELSIO_T3 \
  --disable CONFIG_CHELSIO_T4 \
  --disable CONFIG_MEGARAID_NEWGEN \
  --disable CONFIG_MEGARAID_SAS \
  \
  --disable CONFIG_DRM_AMDGPU \
  --disable CONFIG_DRM_NOUVEAU \
  --disable CONFIG_DRM_RADEON \
  \
  --disable CONFIG_SOUND \
  --disable CONFIG_SND \
  --disable CONFIG_MEDIA_SUPPORT \
  --disable CONFIG_RC_CORE \
  --disable CONFIG_FIREWIRE \
  --disable CONFIG_THUNDERBOLT

# 5. Generate defaults for missing options
make olddefconfig

clear
# [NEW] Core selection logic
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

echo "Your kernel is located at: C:\wsl-kernel\wsl-kernel"
echo ""
echo "Next Steps:"
echo "1. Create or edit your 'C:\Users\<YourUsername>\.wslconfig' file."
echo "2. Add these lines to it:"
echo "   [wsl2]"
echo "   kernel=C:\\\\wsl-kernel\\\\wsl-kernel"
echo "3. Run 'wsl --shutdown' in Windows PowerShell to apply."
echo ""
echo "If binderfs is missing after reboot, run:"
echo "sudo mkdir -p /dev/binderfs"
echo "sudo mount -t binder binder /dev/binderfs"
echo "Thank you for choosing Super-Linux/Waydroid-On-WSL2!"
