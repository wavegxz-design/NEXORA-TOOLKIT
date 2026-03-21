# NEXORA-TOOLKIT

<div align="center">

```
  ███╗   ██╗███████╗██╗  ██╗ ██████╗ ██████╗  █████╗
  ████╗  ██║██╔════╝╚██╗██╔╝██╔═══██╗██╔══██╗██╔══██╗
  ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║██████╔╝███████║
  ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║██╔══██╗██╔══██║
  ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝██║  ██║██║  ██║
  ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
```

**v1.0** — Advanced ADB Toolkit for Android device management

![Platform](https://img.shields.io/badge/platform-Linux-blue)
![Shell](https://img.shields.io/badge/shell-bash-green)
![License](https://img.shields.io/badge/license-MIT-purple)

</div>

---

## Overview

NEXORA-TOOLKIT is a modular ADB toolkit built for Linux, designed for Android
device management, data extraction, diagnostics, and network operations.
It features a clean sectioned menu, full logging, unlimited device support,
and zero code duplication through a shared core library.

---

## Requirements

| Dependency  | Purpose                        |
|-------------|-------------------------------|
| `adb`       | Android Debug Bridge (core)   |
| `fastboot`  | Bootloader operations         |
| `bash 4.0+` | Script execution              |
| `curl`      | Version check                 |
| `bc`        | Battery temperature display   |

Root access is **not required** for most functions. Some advanced features
(tcpdump, persist ADB over reboot) may require root on the device.

---

## Installation

```bash
git clone https://github.com/wavegxz-design/NEXORA-TOOLKIT
cd NEXORA-TOOLKIT
sudo bash install.sh -i
```

### Supported distros

| Distro family              | Package manager |
|----------------------------|-----------------|
| Kali / Debian / Ubuntu     | `apt`           |
| Arch / Manjaro             | `pacman`        |
| Fedora / RHEL              | `dnf`           |
| openSUSE                   | `zypper`        |

---

## Usage

```bash
# Direct
sudo bash ADB-Toolkit.sh

# Via alias (after install)
nexora

# Repair / regenerate modules
sudo bash install.sh -r

# Check dependencies
bash install.sh -c
```

---

## Features

### 1. Device Management
- List all connected devices with Android version and brand
- Full device property dump (model, chipset, SDK, encryption, serial)
- Reboot: system / recovery / fastboot
- Interactive ADB shell
- Root detection (su + Magisk check)
- ADB server restart

### 2. Diagnostics & Logs
- System dump (`dumpsys`)
- CPU info (`/proc/cpuinfo`)
- Memory info (`/proc/meminfo`)
- Full bug report (`.zip`)
- Live logcat with level filter (V/D/I/W/E)
- Real-time battery monitor with visual bar
- Active process list

### 3. Application Management
- Install APK with options: standard / reinstall / test / external storage
- Uninstall with paginated app list
- List apps by filter: all / third-party / system / enabled / disabled
- Launch app by package name
- Grant / revoke runtime permissions

### 4. Data Extraction
- DCIM (photos and videos)
- Downloads folder
- **Social & messaging apps** — auto-detects installed apps:
  - WhatsApp, WhatsApp Business
  - Telegram, Signal
  - Instagram, Facebook, TikTok
  - Snapchat, LINE, Viber, Discord, Twitter/X, Messenger
- Full storage copy (`/sdcard/`)
- Custom path extraction
- Push files to device

### 5. Network & Connectivity
- ADB over WiFi setup (USB to wireless)
- **WiFi connection persistence** — saves last device config for quick reconnect
- Full network info: interfaces, routes, active connections, DNS, WiFi SSID
- Port forwarding and reverse tunneling

### 6. Multimedia
- Screenshot (silent, no notification)
- Screen recording with configurable duration

### 7. Backup & System
- Full ADB backup (apps + shared storage)
- Restore from `.ab` backup files
- Send SMS from device
- Network traffic capture via tcpdump (requires tcpdump on device)

---

## Project Structure

```
NEXORA-TOOLKIT/
├── ADB-Toolkit.sh          # Main script + menu + dispatcher
├── install.sh              # Multi-distro installer
├── generate_modules.sh     # Module generator
├── version                 # Current version string
├── lib/
│   └── core.sh             # Shared library (colors, logging, device detection)
├── modules/
│   ├── d_*.sh              # Device section
│   ├── i_*.sh              # Info/diagnostics section
│   ├── a_*.sh              # Apps section
│   ├── e_*.sh              # Extraction section
│   ├── n_*.sh              # Network section
│   ├── m_*.sh              # Multimedia section
│   ├── b_*.sh              # Backup section
│   └── x_*.sh              # Extra section
├── logs/                   # Operation logs (nexora.log)
├── device-pull/            # Extracted device data
├── backups/                # ADB backup files (.ab)
├── screenshots/            # Captured screenshots
└── screenrecords/          # Screen recordings
```

---

## Connecting a device

1. Enable **Developer Options** on the device (tap Build Number 7 times)
2. Enable **USB Debugging** in Developer Options
3. Connect via USB
4. Accept the authorization dialog on the device
5. Run `nexora` and select option `11` to verify detection

For WiFi connection:
1. Connect device via USB first
2. Select option `51` — ADB WiFi Setup
3. Disconnect USB — the device stays connected over WiFi
4. Use option `52` to reconnect later without USB

---

## Logging

All operations are logged with timestamps to `logs/nexora.log`.

```
[2026-03-20 14:32:11] [ACTION] adb -s R3CN704XXXXX pull /sdcard/DCIM/
[2026-03-20 14:32:45] [OK]     DCIM extraction complete
```

---

## Legal & Ethics

> **This tool is intended for use exclusively on devices you own or have
> explicit written authorization to access.**

- Do not use on devices you do not own or have permission to access
- All ADB operations require physical USB access or prior WiFi pairing
- Data extracted belongs to the device owner
- The author assumes no responsibility for misuse
- Unauthorized access to electronic devices may violate local and
  international laws including the Computer Fraud and Abuse Act (US),
  Computer Misuse Act (UK), and equivalent legislation in other jurisdictions

---

## Author

<div align="center">

**[github.com/wavegxz-design](https://github.com/wavegxz-design)**

*Based on ADB-Toolkit by ASHWINI SAHU — fully refactored*

</div>
