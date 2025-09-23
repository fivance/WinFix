spec.md

Windows Activation --> Runs massgravel script for Windows/Office activation (https://github.com/massgravel/Microsoft-Activation-Scripts)

Run CTT WinUtil --> Opens ChrisTitusTech's winutil (https://github.com/ChrisTitusTech/winutil)

Install DDU --> Installs Display Driver Uninstaller used for completely and cleanly removal of GPU drivers

Install NVIDIA driver --> Installs latest NVIDIA driver and applies custom config for high performance

Install dependencies --> Installs C++ and DirectX packages needed for many apps/games to work properly

Run basic tweaks --> Disables apps running in the background; Enables MSI mode for GPU; Cleans Start menu and taskbar; Disables Xbox Gamebar and Xbox packages

Optimize power plan --> Removes default power plans and installs High Performance power plan

Optimize Registry --> Applies comprehensive registry tweaks to make Windows actually usable

Remove UWP apps --> Removes all UWP apps except for: Paint, Photos, Notepad, Store, Calculator

Remove UWP features --> Removes all UWP features Windows Hello, Steps Recorder, Iexplorer, Wordpad, Wallpapers and so on.. (you can always reenable what you need)

Remove Legacy features --> Removes: WCF, Printing, SMB1, Powershell2 (you can always reenable what you need)

Remove Legacy apps --> Microsoft Update Health tools, One Drive, Snipping Tool, 

Optimize network --> Disables all adapter settings keeps IPv4, applies CloudFlare DNS settings for current adapter, applies optimizes settings to lower latency

Update hosts file --> adds additional sites to hosts file effectively blocking added sites from sending your info to Microsoft/Google/Mozilla etc.
                                             (BE CAREFUL! Blocks Store downloads/installs and some Microsoft sites)- If you need Store, rename hosts file, install apps, rename hosts file back

Install context menus --> adds System Tools/ System Shortcuts group, Copy as Path, Run pwsh as admin, Take Ownership to context menus
 ->more on SystemTools context menu on https://github.com/fivance/ContextMenu

Remove scheduled tasks --> self explanatory

Advanced tweaks --> 
-adds Start menu folders to Start
-shows all apps on taskbar
-disables bacground apps
-disables telemetry
-disables encryption, not needed services and sets needed services for Manual start
-removes all bloatware packages
-NTFS memory usage to 1
-NTFS disablelastaccess to 1
-MFT zone reservation to level 2
-shrinks NTFS transaction logs on mounted volumes

Enable WSL --> Installs Microsoft-Windows-Subsystem-Linux", "VirtualMachinePlatform"

Remove AI/Recall --> Removes all currently known bloatware AI/Recall/Copilot settings, keys, packages

Hardening - Virtualisation Security Features --> Enables DeviceGuard, CredentialGuard, Memory/Core Integrity in Windows Security

Hardening - Defender configuration -> applies optimal Defender/Security configuration

Disable Defender/Security --> completely removes Defender from system in 2 steps (Normal and in safe mode) - completely reversible

Remove Edge --> Removes Edge, all its background tasks, services aswell as webview in Windows Search - completely reversible

Disk Cleanup --> Comprehensive disk cleanup after you're done