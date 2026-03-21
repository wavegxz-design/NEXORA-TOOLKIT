<div align="center">

```
  ███╗   ██╗███████╗██╗  ██╗ ██████╗ ██████╗  █████╗
  ████╗  ██║██╔════╝╚██╗██╔╝██╔═══██╗██╔══██╗██╔══██╗
  ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║██████╔╝███████║
  ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║██╔══██╗██╔══██║
  ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝██║  ██║██║  ██║
  ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
```

### Advanced ADB Toolkit for Android Device Management

[![Version](https://img.shields.io/badge/version-1.0-blueviolet?style=flat-square)](https://github.com/wavegxz-design/NEXORA-TOOLKIT/releases)
[![Platform](https://img.shields.io/badge/platform-Linux-blue?style=flat-square&logo=linux)](https://github.com/wavegxz-design/NEXORA-TOOLKIT)
[![Shell](https://img.shields.io/badge/shell-bash-green?style=flat-square&logo=gnubash)](https://github.com/wavegxz-design/NEXORA-TOOLKIT)
[![License](https://img.shields.io/badge/license-MIT-orange?style=flat-square)](LICENSE)
[![Author](https://img.shields.io/badge/author-krypthane-9cf?style=flat-square)](https://github.com/wavegxz-design)

</div>

---

## What is NEXORA-TOOLKIT?

NEXORA-TOOLKIT is a modular, color-coded ADB toolkit built entirely in Bash for Linux.
It provides a structured menu interface to manage Android devices over USB or WiFi,
extract data, run diagnostics, handle apps, and automate common ADB workflows —
without writing a single command manually.

Built with a shared core library (`lib/core.sh`) that eliminates code duplication,
full operation logging, unlimited device support, and automatic distro detection on install.

---

## Features

<details>
<summary><b>Device Management</b></summary>

- List all connected devices with Android version, brand and serial
- Full device property export (chipset, SDK, encryption state, bootloader)
- Reboot to system / recovery / fastboot
- Interactive ADB shell
- Root detection — checks for `su` binary and Magisk
- ADB server restart

</details>

<details>
<summary><b>Diagnostics & Logs</b></summary>

- System dump via `dumpsys`
- CPU and memory info from `/proc`
- Full bug report export (`.zip`)
- Live logcat with level filter (V / D / I / W / E)
- Real-time battery monitor with visual progress bar
- Active process list

</details>

<details>
<summary><b>Application Management</b></summary>

- Install APK — standard, reinstall, test mode, external storage
- Uninstall with paginated searchable app list
- Filter apps: all / third-party / system / enabled / disabled
- Launch any app by package name
- Grant and revoke runtime permissions per app

</details>

<details>
<summary><b>Data Extraction</b></summary>

- DCIM — photos and videos
- Downloads folder
- Full storage copy (`/sdcard/`)
- Custom path extraction
- Push files to device
- **Social & Messaging** — auto-detects installed apps and extracts media:

| App | Package |
|-----|---------|
| WhatsApp | `com.whatsapp` |
| WhatsApp Business | `com.whatsapp.w4b` |
| Telegram | `org.telegram.messenger` |
| Signal | `org.thoughtcrime.securesms` |
| Instagram | `com.instagram.android` |
| Facebook | `com.facebook.katana` |
| TikTok | `com.zhiliaoapp.musically` |
| Snapchat | `com.snapchat.android` |
| LINE | `jp.naver.line.android` |
| Viber | `com.viber.voip` |
| Discord | `com.discord` |
| Twitter / X | `com.twitter.android` |
| Messenger | `com.facebook.orca` |

</details>

<details>
<summary><b>Network & Connectivity</b></summary>

- ADB over WiFi setup — switch from USB to wireless in one step
- WiFi persistence — saves device config for reconnect without USB
- Full network info: interfaces, routes, active connections, DNS, SSID
- Port forwarding and reverse tunneling with port validation

</details>

<details>
<summary><b>Multimedia</b></summary>

- Silent screenshot — no notification on device
- Screen recording with configurable duration (up to 180s)

</details>

<details>
<summary><b>Backup & System</b></summary>

- Full ADB backup — apps, data and shared storage
- Restore from `.ab` backup with file picker
- Send SMS from device via ADB intent
- Network traffic capture via `tcpdump` (requires tcpdump on device)

</details>

---

## Requirements

| Dependency | Purpose |
|------------|---------|
| `adb` | Android Debug Bridge — core requirement |
| `fastboot` | Bootloader operations |
| `bash 4.0+` | Script runtime |
| `curl` | Remote version check |
| `bc` | Battery temperature calculation |

> Root access is **not required** on the host machine.
> Some advanced device-side features may require root on the Android device.

---

## Installation

```bash
git clone https://github.com/wavegxz-design/NEXORA-TOOLKIT
cd NEXORA-TOOLKIT
sudo bash install.sh -i
```

### Supported Linux distributions

| Family | Distros | Package manager |
|--------|---------|-----------------|
| Debian | Kali, Ubuntu, Mint, Pop!\_OS | `apt` |
| Arch | Arch, Manjaro, EndeavourOS | `pacman` |
| RHEL | Fedora, CentOS | `dnf` |
| SUSE | openSUSE Leap / Tumbleweed | `zypper` |

### Installer options

```bash
sudo bash install.sh -i    # Full install
sudo bash install.sh -u    # Update modules
sudo bash install.sh -c    # Check dependencies
sudo bash install.sh -r    # Repair permissions
```

---

## Usage

```bash
# Run directly
sudo bash ADB-Toolkit.sh

# Run via alias (available after install)
nexora
```

---

## Connecting a device

1. Enable **Developer Options** — go to Settings → About phone → tap **Build number** 7 times
2. Enable **USB Debugging** inside Developer Options
3. Connect via USB cable
4. Accept the authorization dialog that appears on the device
5. Run `nexora` — option `11` lists all detected devices

**WiFi connection (no USB after setup):**

1. Connect device via USB
2. Select option `51` — WiFi ADB Setup
3. Disconnect the USB cable — the device stays connected over WiFi
4. Use option `52` to reconnect later with one command

---

## Project structure

```
NEXORA-TOOLKIT/
├── ADB-Toolkit.sh          # Entry point — menu and dispatcher
├── install.sh              # Multi-distro installer
├── generate_modules.sh     # Generates all module files
├── version                 # Version string
├── lib/
│   └── core.sh             # Shared library: colors, logging, device detection
├── modules/
│   ├── d_*.sh              # Device section
│   ├── i_*.sh              # Diagnostics section
│   ├── a_*.sh              # Applications section
│   ├── e_*.sh              # Extraction section
│   ├── n_*.sh              # Network section
│   ├── m_*.sh              # Multimedia section
│   ├── b_*.sh              # Backup section
│   └── x_*.sh              # Extra / misc
├── logs/                   # nexora.log — timestamped operation log
├── device-pull/            # All extracted device data
├── backups/                # ADB backup files (.ab)
├── screenshots/            # Captured screenshots (.png)
└── screenrecords/          # Screen recordings (.mp4)
```

---

## Logging

Every operation is logged with timestamps to `logs/nexora.log`.

```
[2026-03-20 14:32:11] [ACTION] adb -s R3CN704XXXXX pull /sdcard/DCIM/
[2026-03-20 14:32:45] [OK]     DCIM extraction complete → device-pull/Pixel_7/DCIM_20260320
[2026-03-20 14:33:02] [WARN]   Returned code 1
```

---

## Legal & Ethics

> **Use this tool exclusively on devices you own or have explicit written authorization to access.**

- Requires physical USB access or prior device authorization for WiFi pairing
- All extracted data belongs to the device owner
- The author is not responsible for any misuse of this tool
- Unauthorized access to electronic devices may violate applicable laws including
  the Computer Fraud and Abuse Act (US), the Computer Misuse Act (UK),
  and equivalent legislation in other jurisdictions

---

<div align="center">

Made with focus by **[github.com/wavegxz-design](https://github.com/wavegxz-design)**

</div>
