
#!/usr/bin/env bash
set -Eeuo pipefail

# ==========================================================
# WSL2 Waydroid Kernel Builder
# Target: x86_64
# Output: C:\wsl-kernel\wsl-kernel
# ==========================================================

REPO_URL="https://github.com/microsoft/WSL2-Linux-Kernel.git"
KERNEL_DIR="$HOME/WSL2-Linux-Kernel"
CONFIG="$KERNEL_DIR/Microsoft/config-wsl-waydroid"
OUT_DIR="/mnt/c/wsl-kernel"
OUTPUT_KERNEL="$OUT_DIR/wsl-kernel"

echo "WSL2 Waydroid Kernel Builder"
echo

# Check the build environment.
if ! grep -qi microsoft /proc/sys/kernel/osrelease; then
    echo "Error: Run this script inside Ubuntu on WSL2."
    exit 1
fi

if [[ "$(uname -m)" != "x86_64" ]]; then
    echo "Error: This build requires x86_64."
    exit 1
fi

# Install build dependencies.
echo "Installing build dependencies..."

sudo apt-get update
sudo apt-get install -y \
    git build-essential flex bison dwarves \
    libssl-dev libelf-dev libncurses-dev \
    cpio bc rsync python3

# Download the kernel source if it is not already present.
if [[ ! -d "$KERNEL_DIR/.git" ]]; then
    if [[ -e "$KERNEL_DIR" ]]; then
        echo "Error: $KERNEL_DIR exists but is not a Git repository."
        exit 1
    fi

    echo "Downloading the WSL2 kernel source..."
    git clone --depth=1 "$REPO_URL" "$KERNEL_DIR"
fi

cd "$KERNEL_DIR"

# Start with Microsoft's WSL2 configuration.
echo "Preparing kernel configuration..."

cp Microsoft/config-wsl "$CONFIG"

# Disable optional kernel debug information.
./scripts/config --file "$CONFIG" --disable DEBUG_INFO
./scripts/config --file "$CONFIG" --disable DEBUG_INFO_DWARF4
./scripts/config --file "$CONFIG" --disable DEBUG_INFO_DWARF5
./scripts/config --file "$CONFIG" --disable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
./scripts/config --file "$CONFIG" --disable DEBUG_INFO_REDUCED
./scripts/config --file "$CONFIG" --disable DEBUG_INFO_SPLIT
./scripts/config --file "$CONFIG" --disable DEBUG_INFO_COMPRESSED
./scripts/config --file "$CONFIG" --disable DEBUG_INFO_BTF
./scripts/config --file "$CONFIG" --disable DEBUG_INFO_BTF_MODULES
./scripts/config --file "$CONFIG" --disable GDB_SCRIPTS

# Android Binder support.
./scripts/config --file "$CONFIG" --enable ANDROID
./scripts/config --file "$CONFIG" --enable ANDROID_BINDER_IPC
./scripts/config --file "$CONFIG" --enable ANDROID_BINDERFS
./scripts/config --file "$CONFIG" \
    --set-str ANDROID_BINDER_DEVICES "binder,hwbinder,vndbinder"

# Container namespaces.
./scripts/config --file "$CONFIG" --enable NAMESPACES
./scripts/config --file "$CONFIG" --enable UTS_NS
./scripts/config --file "$CONFIG" --enable IPC_NS
./scripts/config --file "$CONFIG" --enable USER_NS
./scripts/config --file "$CONFIG" --enable PID_NS
./scripts/config --file "$CONFIG" --enable NET_NS

# Container resource management and security.
./scripts/config --file "$CONFIG" --enable CGROUPS
./scripts/config --file "$CONFIG" --enable CGROUP_PIDS
./scripts/config --file "$CONFIG" --enable CGROUP_SCHED
./scripts/config --file "$CONFIG" --enable CPUSETS
./scripts/config --file "$CONFIG" --enable MEMCG
./scripts/config --file "$CONFIG" --enable SECCOMP
./scripts/config --file "$CONFIG" --enable SECCOMP_FILTER

# Filesystems.
./scripts/config --file "$CONFIG" --enable DEVTMPFS
./scripts/config --file "$CONFIG" --enable TMPFS
./scripts/config --file "$CONFIG" --enable EXT4_FS
./scripts/config --file "$CONFIG" --enable OVERLAY_FS
./scripts/config --file "$CONFIG" --enable SQUASHFS
./scripts/config --file "$CONFIG" --enable SQUASHFS_XZ
./scripts/config --file "$CONFIG" --enable BLK_DEV_LOOP
./scripts/config --file "$CONFIG" --enable FUSE_FS

# Container networking.
./scripts/config --file "$CONFIG" --enable BRIDGE
./scripts/config --file "$CONFIG" --enable VETH
./scripts/config --file "$CONFIG" --enable TUN
./scripts/config --file "$CONFIG" --enable NETFILTER
./scripts/config --file "$CONFIG" --enable NF_TABLES
./scripts/config --file "$CONFIG" --enable NF_NAT
./scripts/config --file "$CONFIG" --enable NETFILTER_XT_TARGET_MASQUERADE
./scripts/config --file "$CONFIG" --enable IP_NF_IPTABLES
./scripts/config --file "$CONFIG" --enable IP_NF_FILTER
./scripts/config --file "$CONFIG" --enable IP_NF_NAT
./scripts/config --file "$CONFIG" --enable IP_NF_TARGET_MASQUERADE
./scripts/config --file "$CONFIG" --enable BRIDGE_NETFILTER

# Resolve configuration dependencies.
echo "Checking kernel configuration..."

make KCONFIG_CONFIG="$CONFIG" olddefconfig

# Ensure essential Android Binder options are built in.
for option in ANDROID_BINDER_IPC ANDROID_BINDERFS; do
    if ! grep -q "^CONFIG_${option}=y$" "$CONFIG"; then
        echo "Error: $option is not enabled in the final configuration."
        echo "Check whether this kernel version supports the option."
        exit 1
    fi
done

# Select the build parallelism.
MAX_CORES="$(nproc)"

echo
echo "Available CPU cores: $MAX_CORES"
read -r -p "Use all available cores? [y/N]: " ANSWER

if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
    JOBS="$MAX_CORES"
else
    read -r -p "Number of build jobs [1]: " JOBS
    JOBS="${JOBS:-1}"

    if ! [[ "$JOBS" =~ ^[1-9][0-9]*$ ]] ||
       (( JOBS > MAX_CORES )); then
        echo "Error: Enter a number from 1 to $MAX_CORES."
        exit 1
    fi
fi

# Compile the kernel.
echo
echo "Building the kernel..."
echo "Build jobs: $JOBS"

make KCONFIG_CONFIG="$CONFIG" -j"$JOBS"

# Check the generated kernel image.
KERNEL_IMAGE="$KERNEL_DIR/arch/x86/boot/bzImage"

if [[ ! -s "$KERNEL_IMAGE" ]]; then
    echo "Error: The kernel image was not generated."
    exit 1
fi

# Copy the completed kernel to the Windows filesystem.
mkdir -p "$OUT_DIR"

# Preserve the previous kernel before replacing it.
if [[ -f "$OUTPUT_KERNEL" ]]; then
    BACKUP="$OUTPUT_KERNEL.backup-$(date +%Y%m%d-%H%M%S)"
    cp "$OUTPUT_KERNEL" "$BACKUP"
    echo "Previous kernel backed up to: $BACKUP"
fi

cp "$KERNEL_IMAGE" "$OUTPUT_KERNEL"

echo
echo "=========================================="
echo "          BUILD SUCCESSFUL"
echo "=========================================="
echo
echo "Kernel image:"
echo "C:\wsl-kernel\wsl-kernel"
echo
echo "To use the kernel, add this to your Windows"
echo ".wslconfig file under the [wsl2] section:"
echo
echo 'kernel=C:\\wsl-kernel\\wsl-kernel'
echo
echo "Then run this command in PowerShell:"
echo "wsl --shutdown"
echo
echo "Restart Ubuntu to load the custom kernel."
