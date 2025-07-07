<div id="top" align="center">

<h2 align="center">🛠️ WinFix Script</h2>
<p align="center"><em>A post-install PowerShell toolkit for Windows</em><br>
Automation • Hardening • Customization • Performance<br>
Built for sysadmins, developers, and power users</p>

</div>

---

## 📑 Table of Contents

<details open>
  <summary><strong>Click to expand/collapse</strong></summary>
  <ol>
    <li><a href="#-about">📖 About</a></li>
    <li><a href="#-features">✨ Features</a></li>
    <li><a href="#-installation">📥 Installation</a></li>
    <li><a href="#-usage">🚀 Usage</a></li>
  </ol>
</details>

---

## 📖 About

**WinFix** is a comprehensive PowerShell script that automates post-installation configuration for Windows systems. It’s designed to help power users, sysadmins, and developers achieve a clean, hardened, and optimized system — **without tedious manual tweaks**.

It leans heavily on native PowerShell, making it compatible with a wide range of modern Windows versions.

> ⚠️ **Note**: This script is under active development. It's a strong baseline, but not yet production-grade.

---

## ✨ Features

A quick overview of what WinFix does:

### 🔧 System Tweaks & Optimizations

- Disable telemetry & background services
- Clean bloatware & UWP apps
- Performance tuning (NTFS, power plans, GPU MSI mode)
- Privacy enhancements
- Desktop & Explorer UI customizations
- DNS over HTTPS & hardened networking
- Context menu enhancements (e.g., "Open PowerShell as Admin", "Take Ownership")
- Custom host file entries (blocks Microsoft Store domains)

### 🛡 Security Hardening

- Disable legacy services & scheduled tasks (e.g., CEIP, SmartScreen, Xbox)
- Remove pre-installed junk (Candy Crush, OneConnect, etc.)
- Disable optional features (e.g., Internet Printing, SMB Direct, WorkFolders)
- Office telemetry removal & update block
- Disables unsigned driver enforcement

### ✅ Bonus Tweaks

- IPv4 only network config
- Disable Xbox/GameBar
- Set system-wide 24h clock
- Enable NumLock by default
- Disable clipboard history, activity logging, and hibernation
- Clean leftover OneDrive/Office junk
- Set solid wallpaper & compact Explorer mode
- Clean temp files on finish

> All settings aim for **speed, privacy, and simplicity**.

<p align="right">(<a href="#top">🔼 Back to top</a>)</p>

---

## 📥 Installation

### Option 1: Download Manually

1. Go to this GitHub repo
2. Click `<> Code` → `Download ZIP`
3. Extract the archive anywhere you like

### Option 2: Git Clone

```bash
git clone https://github.com/your-username/WinFix
