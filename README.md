# my-dots

My Windows dotfiles for PowerShell 7, Starship, Fastfetch, and YASB.
Use a Nerd Font in your terminal (for example, JetBrainsMono Nerd Font) for icons.

## Files

| Folder | Configuration |
| --- | --- |
| `powershell/` | PowerShell profile, key bindings, aliases, and startup caches |
| `starship/` | Minimal blue Windows/home icons and current directory, with a green/red prompt arrow |
| `fastfetch/` | Pastel system information banner and custom ASCII logo |
| `yasb/` | Dark desktop bar with a lavender outline; tested with YASB 2.0.7 |

## Terminal setup

Install PowerShell 7, Starship, Fastfetch, and a Nerd Font. Open PowerShell 7
(`pwsh`) and run these commands from the repository root. Existing files are
backed up before copying.

```powershell
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$targets = @(
    @{ Source = '.\powershell\Microsoft.PowerShell_profile.ps1'; Target = $PROFILE.CurrentUserCurrentHost },
    @{ Source = '.\starship\starship.toml'; Target = "$HOME\.config\starship.toml" },
    @{ Source = '.\fastfetch\config.jsonc'; Target = "$HOME\.config\fastfetch\config.jsonc" },
    @{ Source = '.\fastfetch\ascii.txt'; Target = "$HOME\.config\fastfetch\ascii.txt" }
)
foreach ($file in $targets) {
    New-Item -ItemType Directory -Path (Split-Path $file.Target) -Force | Out-Null
    if (Test-Path -LiteralPath $file.Target) {
        Move-Item -LiteralPath $file.Target -Destination ($file.Target + '.backup-' + $stamp)
    }
    Copy-Item -LiteralPath $file.Source -Destination $file.Target
}
. $PROFILE
Update-ProfileCache
```

The profile is for interactive PowerShell 7 console sessions. It uses Starship
instead of Oh My Posh. The configuration path is explicitly set to
`~/.config/starship.toml`. The prompt shows `~` at home and the current path
elsewhere, without an extra blank line. Its arrow is green on success, red on
failure, and yellow in Vim command mode. The default editing mode is Windows.

PSReadLine is imported directly, with history predictions, Tab menu completion,
and Up/Down history search. UTF-8 is enabled.

### Startup caches

Caches live in `%LOCALAPPDATA%\PowerShell\ProfileCache`, outside the repository.

- Starship's full PowerShell initialization is cached for one day and rebuilt
  when its executable has a newer modification time. Theme edits are read by
  Starship at prompt rendering time.
- Fastfetch's banner is cached for ten minutes and refreshed after config edits.
  Color is forced with `--pipe false`, so ANSI colors survive capture and replay.
  Memory and disk figures in the cached banner are snapshots.
- `fetch` shows live system information and refreshes the banner cache.
- `cfetch` clears the screen, then runs `fetch`.
- `Update-ProfileCache` removes the Starship/banner caches and reloads the profile.
  Use it after a tool upgrade or an ASCII logo edit to force a refresh.

### Shortcuts

Optional tools used by shortcuts: `eza`, `bat`, `rg`, `fd`, `fzf`, Git, Docker,
and Scoop. Install the ones you use; the profile does not install tools.

| Commands | Purpose |
| --- | --- |
| `ls`, `ll`, `la`, `lt`, `l1` | Listings with eza |
| `cat`, `grep` | Aliases for bat and ripgrep |
| `..`, `...`, `....`, `home` | Directory navigation |
| `fcd`, `ff` | Fuzzy directory/file selection |
| `gs`, `ga`, `gaa`, `gc`, `gp`, `gpl`, `gd`, `gl`, `gb`, `gco` | Git shortcuts; `ga`/`gaa` stage changes and `gp` pushes |
| `dps`, `dpa`, `di`, `dcup`, `dcdown`, `dclogs` | Docker/Compose shortcuts |
| `su`, `ss`, `si` | Scoop update/search/install |

## YASB setup

A full-width dark bar with a lavender outline, Windows virtual desktop buttons,
a centered Windows Start icon, and compact connectivity, volume, brightness,
battery, clock, notification, and power controls. The bar stays above apps and
reserves space for maximized windows.

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

Popup styling is adapted from the supplied Catppuccin-style CSS. Runtime caches,
logs, backups, tools, and installers are excluded from this repository.