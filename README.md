# my-dots

My YASB dotfiles for Windows, tested with YASB 2.0.7.

A full-width dark bar with a lavender outline, Windows virtual desktop buttons,
a centered Windows Start icon, and compact connectivity, volume, brightness,
battery, clock, notification, and power controls. The bar stays above apps and
reserves space for maximized windows.

## Setup

Install YASB and JetBrainsMono Nerd Font, then copy the files:

```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE\.config\yasb" -Force
Copy-Item .\yasb\config.yaml,.\yasb\styles.css "$env:USERPROFILE\.config\yasb\"
yasbc start
```

If YASB is already running, use `yasbc reload`.

Autostart is disabled on my machine. To keep it disabled:

```powershell
yasbc disable-autostart
```

Windows desktop buttons show existing desktops. No GlazeWM or Komorebi is needed
for the active layout. Brightness and battery depend on supported hardware.
Unused optional widget definitions are retained in the config; Cava is only
needed if its widget is added to a bar.

Popup styling is adapted from the supplied Catppuccin-style CSS. This repository
contains only YASB configuration; runtime logs, backups, tools, and installers
are excluded.
