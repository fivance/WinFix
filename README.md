The idea is to collect good optimization scripts and combine them in a single ps1 script.

Use at your own risk, if anything breaks it's on you.

Must be run in powershell as admin and with Set-ExecutionPolicy Unrestricted

some of the scripts are made by me and some are from @fr33thyfr33thy and @zoicware -> amazing guys defintely go and check their work

------------------------------------------

Can also be run by running this command in Admin p$ window:

```iwr franivancevic.com/winfix | iex```



-------------------------------------------
Every option is self-explanatory except Optimization script and Advanced tweaks which contains:


                                                                                ::OPTIMIZATION SCRIPT::

-  Installs dependencis -> C++, DirectX
-  Disables bacground apps
-  Enables MSI Mode for GPU
-  Cleans Taskbar and Start Menu
-  Shows all Taskbar icons
-  Disables gamebar and XBOX apps
-  Installs proper Power plan
-  Disables hibernate
-  Installs Set Timer Resolution Service
-  Registry optimizations
-  Sets black lockscreen
-  Enables compact mode in Windows explorer
-  Sets small icons on Desktop
-  Removes OneDrive and cleans File Explorer sidebar from Onedrive and Gallery entries
-  Uninstalls UWP applications except Calculator, Notepad, Paint, Photos, Store and SMB support
-  Uninstalls all features except SMB
-  Sets Network adapters to IPv4 only
-  Sets DNS servers to Cloudflare
-  Updates hosts file (blocks some microsoft sites not working properly and Store installs!) -> workaround is to rename hosts file, download/install what you need and rename hosts file back
-  Added custom Context Menu entries -> adds SystemShortcuts and SystemTools to right click on the Desktop
-  Added Take Ownership ContextMenu to take control of your own files
-  Removes useless Scheduled Tasks
-  Sets all Services to Manual where applicable
-  Cleans temporary files at the end of the script



                                                                                ::ADVANCED TWEAKS::

-  Enabled Numlock everywhere
-  Automatic discovery IE11 proxy
-  Removes any leftover background apps
-  Cleans Onedrive leftover files and telemetry after Office install
-  Set solid wallpaper color
-  Disables automatic folder type discovery
-  Enables DNS over HTTPS (DoH)
-  Removes Auto run Defender
-  Disables autologger telemetry: CloudExperienceHostOobe.etl, Cellcore.etl, WinPhoneCritical.etl
-  Disables updates for Microsoft Office
-  Disables activity log and clipboard history
-  Disables telemetry
-  Disables integrity checks for installing unsigned drivers
-  Passwords never expire
-  Sysmain optimizations
-  Disables telemetry for Microsoft Office 2016/2019+