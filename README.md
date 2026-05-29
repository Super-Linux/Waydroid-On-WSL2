# Waydroid on WSL2: Custom Kernel Compiler

[![GitHub license](https://shields.io)](https://github.com)
[![GitHub stars](https://shields.io)](https://github.com)
[![GitHub forks](https://shields.io)](https://github.com)
[![Platform](https://shields.io)](https://microsoft.com)

An automated shell compilation utility to configure and build a custom **WSL2 Linux Kernel** optimized explicitly for **Waydroid (Android Container)** execution. This automation injects missing modules like Android Binder and Ashmem directly into your WSL framework.

> [!IMPORTANT]
> **Kernel Interception:** This script requires a Linux terminal running inside WSL2 (such as Ubuntu or Debian) to compile the necessary kernel binaries.

---

## 🚀 Key Features

* **One-Command Compilation:** Automates the complete kernel setup layer via a single shell script wrapper (`make-kernel.sh`).
* **Android Binder Provisioning:** Configures `CONFIG_ANDROID_BINDER_IPC` and memory hooks required to boot an internal Android OS.
* **Streamlined Deployment:** Safely exports a compiled kernel ready to be loaded by Windows.

---

## 📋 Prerequisites

Before running the compiler tool, ensure your base Linux distribution has the essential build dependencies:

### For Ubuntu / Debian Systems:
```bash
sudo apt update && sudo apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev bc git
```

---

## 🛠️ Installation & Execution

Follow these rapid steps inside your active WSL2 terminal session to build and extract your specialized kernel modules:

### 1️⃣ Run the Automated Compiler
```bash
# Clone the repository
git clone https://github.com
cd Waydroid-On-WSL2

# Grant execution rights and run the builder script
chmod +x make-kernel.sh
./make-kernel.sh
```

### 2️⃣ Register the Kernel in Windows
After compiling, copy your output kernel image (typically `vmlinux` or `bzImage`) to a static location on your Windows computer host (for example: `C:\WaydroidKernel\`).

Create or append the target file path mapping inside your Windows host system directory profile `C:\Users\<YourUsername>\.wslconfig`:

```ini
[wsl2]
kernel=C:\\WaydroidKernel\\vmlinux
```

### 3️⃣ Cold Reboot the Subsystem
Save your modified configuration. Shut down the virtualization hypervisor completely from a Windows Command Prompt terminal to trigger a system swap:
```cmd
wsl --shutdown
```

---

## 🗂️ Project Repository Map

```text
├── make-kernel.sh   # Core automation logic: downloads kernel sources and patches configuration configs
└── README.md        # Technical project documentation storefront
```

---

## 🤝 Contributing

Contributions to make the compilation matrix more robust are highly appreciated! 

1. **Fork** the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingUpgrade`)
3. **Commit** your Changes (`git commit -m 'Add some AmazingUpgrade'`)
4. **Push** to the Branch (`git push origin feature/AmazingUpgrade`)
5. Open a **Pull Request**

## 📝 License

Distributed under the MIT License. See `LICENSE` for more details.
