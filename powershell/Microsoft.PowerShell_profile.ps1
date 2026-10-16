# 1. IMMEDIATE TERMINAL CHECK & ENVIRONMENT PROTECTION
if ($Host.Name -ne 'ConsoleHost' -or [Console]::IsOutputRedirected -or $env:TERM -eq 'dumb') { return }

# Instant UTF-8 enforcement via .NET core hooks
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# 2. Local startup caches (Starship initialization refreshes daily).
$script:ProfileCache = Join-Path $env:LOCALAPPDATA 'PowerShell/ProfileCache'
$env:STARSHIP_CONFIG = Join-Path $HOME '.config/starship.toml'
[void][IO.Directory]::CreateDirectory($script:ProfileCache)

# Import directly instead of scanning all module directories.
Import-Module PSReadLine -ErrorAction SilentlyContinue
if (Get-Module PSReadLine) {
    Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView -EditMode Windows
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# Cache full Starship initialization, refreshing daily or after a binary update.
$starshipCache = Join-Path $script:ProfileCache 'starship-init.ps1'
$starshipFile = Get-Item -LiteralPath $starshipCache -ErrorAction SilentlyContinue
$starshipCommand = Get-Command starship -ErrorAction SilentlyContinue
if ($starshipCommand) {
    $starshipBinary = Get-Item -LiteralPath $starshipCommand.Source
    if (!$starshipFile -or $starshipFile.LastWriteTimeUtc -lt [DateTime]::UtcNow.AddDays(-1) -or
        $starshipBinary.LastWriteTimeUtc -gt $starshipFile.LastWriteTimeUtc) {
        $init = & $starshipCommand.Source init powershell --print-full-init
        if ($LASTEXITCODE -eq 0 -and $init) {
            [IO.File]::WriteAllText($starshipCache, ($init -join "`n"), [Text.UTF8Encoding]::new($false))
        }
    }
    if (Test-Path -LiteralPath $starshipCache) {
        if (Get-Module oh-my-posh-core) { Remove-Module oh-my-posh-core -Force }
        . $starshipCache
    }
}

# 4. HARDCODED ALIAS CORES (Zero Environment Path Crawls)
Set-Alias ls eza -Option AllScope -ErrorAction SilentlyContinue
Set-Alias ll eza -ErrorAction SilentlyContinue
Set-Alias cat bat -Option AllScope -ErrorAction SilentlyContinue
Set-Alias grep rg -ErrorAction SilentlyContinue

# 5. HIGH-SPEED NAVIGATION & CLI FUNCTIONS
function la { eza -la --icons --group-directories-first }
function lt { eza --tree --icons --group-directories-first }
function l1 { eza -1 --icons --group-directories-first }

function ..   { Set-Location .. }
function ...  { Set-Location ../.. }
function .... { Set-Location ../../.. }
function home { Set-Location $HOME }

function fcd  { $d = fd --type d --hidden --exclude .git | fzf; if ($d) { Set-Location $d } }
function ff   { $f = fd --type f --hidden --exclude .git | fzf; if ($f) { bat $f } }

# Git Primitives (Swapped dynamic parameter validation blocks for instant $args matching)
function gs  { git status }
function ga  { git add . }
function gaa { git add --all }
function gc  { git commit -m ($args -join " ") }
function gp  { git push }
function gpl { git pull }
function gd  { git diff }
function gl  { git log --oneline --graph --decorate -20 }
function gb  { git branch }
function gco { git checkout $args }

# Containerization & App Management
function dps    { docker ps }
function dpa    { docker ps -a }
function di     { docker images }
function dcup   { docker compose up -d }
function dcdown { docker compose down }
function dclogs { docker compose logs -f }
function su     { scoop update * }
function ss     { scoop search $args }
function si     { scoop install $args }

# Fastfetch Engine
# Explicit fetch is always live and refreshes the startup snapshot.
function fetch {
    $output = fastfetch --pipe false -c "$HOME/.config/fastfetch/config.jsonc"
    if ($LASTEXITCODE -eq 0 -and $output) {
        [IO.File]::WriteAllText((Join-Path $script:ProfileCache 'fastfetch.txt'), ($output -join "`n"))
    }
    $output
}
function Update-ProfileCache {
    Remove-Item -LiteralPath (Join-Path $script:ProfileCache 'starship-init.ps1'), (Join-Path $script:ProfileCache 'fastfetch.txt') -ErrorAction SilentlyContinue
    . $PROFILE
}
function cfetch { [Console]::Clear(); fetch }

# 6. INSTANT VISUAL RETURN
[Console]::Clear()
# Reuse the banner for ten minutes; memory/disk figures are a snapshot.
$fetchCache = Join-Path $script:ProfileCache 'fastfetch.txt'
$fetchFile = Get-Item -LiteralPath $fetchCache -ErrorAction SilentlyContinue
$fetchConfig = Get-Item -LiteralPath "$HOME/.config/fastfetch/config.jsonc" -ErrorAction SilentlyContinue
if ($fetchFile -and $fetchFile.LastWriteTimeUtc -gt [DateTime]::UtcNow.AddMinutes(-10) -and
    (!$fetchConfig -or $fetchConfig.LastWriteTimeUtc -le $fetchFile.LastWriteTimeUtc)) {
    [IO.File]::ReadAllText($fetchCache)
} elseif (Get-Command fastfetch -ErrorAction SilentlyContinue) { fetch }
