echo "Welcome!"

# Clone the WSL2 kernel repo
git clone --depth=1 https://github.com/microsoft/WSL2-Linux-Kernel.git
cd WSL2-Linux-Kernel

echo "Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y build-essential ncurses-dev bison flex libssl-dev libelf-dev
# entering the folder
cd WSL2-Linux-Kernel
# Copy default WSL config
cp Microsoft/config-wsl .config

# Apply your custom kernel options
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

# Generate defaults for missing options
make olddefconfig

clear
echo "Building kernel..."
# build the kernel
make -j2 bzImage
echo "Build complete!"

# Copy kernel to Windows
mkdir -p /mnt/c/wsl-kernel
cp arch/x86/boot/bzImage /mnt/c/wsl-kernel/

echo "Your kernel is located at: C:/wsl-kernel/bzImage"

echo "If binderfs is missing, run:"
echo "sudo mkdir -p /dev/binderfs"
echo "sudo mount -t binder binder /dev/binderfs"
echo thank you for much for choosing Super-Linux/Waydroid-On-WSL2!


