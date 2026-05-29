#!/bin/bash

# ==============================================================================
# Project: Waydroid-On-WSL2 Wi-Fi Emulation Bypass Engine
# Author: Super-Linux
# Repository: https://github.com
# Description: Overrides Android container system properties to fake a persistent 
#              Wi-Fi connectivity state for target applications.
# ==============================================================================

# Custom layout banner
echo "======================================================================"
echo "      ⚡ Waydroid-On-WSL2: Automated Wi-Fi Bypass Engine ⚡           "
echo "======================================================================"

# 1. Validation Check: Ensure Waydroid is locally provisioned
if ! command -v waydroid &> /dev/null; then
    echo "[-] [CRITICAL ERROR] Waydroid binary not found on this system path."
    echo "    Please run your base installation script before executing this hook."
    exit 1
fi

# 2. Validation Check: Ensure script has root privileges for the daemon bounce
if [ "$EUID" -ne 0 ]; then
    echo "[-] [ACCESS DENIED] Please execute this script using administrative rights:"
    echo "    sudo ./bypass-wifi.sh"
    exit 1
fi

echo "[+] Injecting wildcard Android System Wi-Fi spoofing layer..."
# Force Android to intercept all app calls and report a connected Wi-Fi state
waydroid prop set persist.waydroid.fake_wifi "*"

echo "[+] Forcing unmetered network path definitions..."
# Prevents Android background sync flags from freezing asset downloads
waydroid prop set persist.waydroid.unmetered true

echo "[+] Validating Linux host firewall packet forwarding..."
# Resolves potential container isolation path blocking rules 
sysctl -w net.ipv4.ip_forward=1 > /dev/null

echo "[+] Toggling background container service routines..."
# Shut down the operational runtime instances safely
waydroid session stop &> /dev/null
waydroid container stop &> /dev/null

# Trigger a systemd hypervisor refresh step
systemctl restart waydroid-container

echo "======================================================================"
echo " ✅ SUCCESS: Wi-Fi software bypass applied seamlessly!"
echo "    - Picky apps and games will now detect a valid Wi-Fi link."
echo "    - Note: Android Settings will still show Wi-Fi disabled/greyed out."
echo "======================================================================"
