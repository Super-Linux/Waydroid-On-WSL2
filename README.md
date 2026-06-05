
# Waydroid on WSL2: Custom Kernel Builder

An automated build utility for compiling a custom **WSL2 Linux kernel** with the Android-specific features required by **Waydroid**. The script enables and configures kernel options such as Android Binder IPC and BinderFS, producing a kernel image that can be used with WSL2.

> [!IMPORTANT]
> This project must be run from a Linux distribution inside **WSL2** (for example, Ubuntu or Debian). Building the kernel requires standard Linux development tools and may take some time depending on your system.

---

## Features

* **Automated Kernel Build** – Compiles a WSL2-compatible kernel using a single script (`make-kernel.sh`).
* **Configurable Build Performance** – Allows selection of the number of CPU cores used during compilation.
* **Waydroid Support** – Enables Android Binder IPC, BinderFS, and other required kernel options.
* **Ready for WSL2 Deployment** – Produces an uncompressed `vmlinux` image suitable for use as a custom WSL2 kernel.

---

## Prerequisites

Install the required build dependencies before running the script.

### Ubuntu / Debian

```bash
sudo apt update
sudo apt install -y \
    build-essential \
    libncurses-dev \
    bison \
    flex \
    libssl-dev \
    libelf-dev \
    bc \
    git
```

---

## Installation and Usage

### Clone the Repository

```bash
git clone https://github.com/Super-Linux/Waydroid-On-WSL2
cd Waydroid-On-WSL2
```

### Run the Builder

```bash
chmod +x make-kernel.sh
./make-kernel.sh
```

The script downloads the required kernel sources, applies the necessary configuration changes, and builds the kernel.

---

## Configure WSL2

After compilation, copy the generated `vmlinux` file to a location accessible from Windows, for example:

```text
C:\wsl-kernel\vmlinux
```

Create or edit the file:

```text
C:\Users\<YourUsername>\.wslconfig
```

Add the following configuration:

```ini
[wsl2]
kernel=C:\\wsl-kernel\\vmlinux
```

Apply the changes by shutting down WSL:

```powershell
wsl --shutdown
```

Then start your WSL distribution again.

---

## Project Structure

```text
.
├── make-kernel.sh   # Downloads, configures, and builds the kernel
└── README.md
```

---

## Credits

* Inspired by SouNux and other community efforts to run Waydroid on WSL2.
* Kernel sources are based on the official Microsoft WSL2 Linux kernel.

---

## Contributing

Contributions are welcome.

1. Fork the repository

2. Create a feature branch

   ```bash
   git checkout -b feature/my-feature
   ```

3. Commit your changes

   ```bash
   git commit -m "Add new feature"
   ```

4. Push to your branch

   ```bash
   git push origin feature/my-feature
   ```

5. Open a Pull Request

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
