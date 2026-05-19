echo welecome!
git clone --depth=1 https://github.com/microsoft/WSL2-Linux-Kernel.git
echo installing 

cp Microsoft/config-wsl .config
sudo apt-get install build-essential ncurses-dev bison flex libssl-dev libelf-dev

./scripts/config --file .config \
  --enable CONFIG_ANDROID \
  --enable CONFIG_ANDROID_BINDER_IPC \
  --enable CONFIG_ANDROID_BINDERFS \
  --set-str CONFIG_ANDROID_BINDER_DEVICES "binder,hwbinder,vndbinder" \
  \
  --enable CONFIG_ASHMEM \
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
  --enable CONFIG_NETFILTER \
  --enable CONFIG_NF_NAT \
  --enable CONFIG_IP_NF_IPTABLES \
  --enable CONFIG_IP_NF_FILTER \
  --enable CONFIG_IP_NF_NAT \
  --enable CONFIG_IP_NF_TARGET_MASQUERADE \
  --enable CONFIG_BRIDGE \
  --enable CONFIG_VETH \
  \
  --enable CONFIG_WIRELESS \
  --enable CONFIG_WLAN \
  --enable CONFIG_FW_LOADER \
  --enable CONFIG_CFG80211 \
  --enable CONFIG_MAC80211 \
  \
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
--enable CONFIG_EXT4_FS_SECURITY
clear 

make -j2 bzImage
echo All Done!
mkdir -p /mnt/c/wsl-kernel
cp arch/x86/boot/bzImage /mnt/c/wsl-kernel/
echo your kernel is at C:/wsl-kernel

your kernel is now loacted at C:/wsl-kernel
echo type  these commads after you change your kernel only if you cant find binders
sudo mkdir -p /dev/binderfs
sudo mount -t binder binder /dev/binderfs

