# ======== Init cache (starship/atuin) ===
# starship/atuin init spawns a subprocess on every shell launch (~0.6s each).
# Cache their generated script and only regenerate when missing or stale.
$initCacheDir = "$HOME\.cache\powershell"
if (-not (Test-Path $initCacheDir)) {
    New-Item -ItemType Directory -Path $initCacheDir -Force | Out-Null
}

function Update-InitCache {
    param([string]$Command, [string]$CachePath, [string[]]$InitArgs)
    $binPath = (Get-Command $Command).Path
    $stale = (-not (Test-Path $CachePath)) -or ((Get-Item $binPath).LastWriteTime -gt (Get-Item $CachePath).LastWriteTime)
    if ($stale) {
        & $Command @InitArgs | Out-File -FilePath $CachePath -Encoding utf8
    }
}

$starshipCache = "$initCacheDir\starship_init.ps1"
Update-InitCache -Command starship -CachePath $starshipCache -InitArgs @("init", "powershell")
. $starshipCache

$atuinCache = "$initCacheDir\atuin_init.ps1"
Update-InitCache -Command atuin -CachePath $atuinCache -InitArgs @("init", "powershell")
. $atuinCache

$zoxideCache = "$initCacheDir\zoxide_init.ps1"
Update-InitCache -Command zoxide -CachePath $zoxideCache -InitArgs @("init", "powershell")
. $zoxideCache
# =======================================

# ======== Alias (ported from macOS .zshrc) =====
Remove-Item Alias:rm -Force -ErrorAction SilentlyContinue
Remove-Item Alias:cd -Force -ErrorAction SilentlyContinue
function cd { if ($args.Count -eq 0) { z $HOME } else { z @args } }
function rm { trash @args }
function ce { chezmoi edit --apply @args }
function dotedit { nvim (chezmoi source-path) }
function reload { . $PROFILE }
# =================================================

# ======== Zellij =======================
$env:ZELLIJ_CONFIG_DIR = "$HOME\.config\zellij"
$env:ZELLIJ_AUTO_ATTACH = "false"
$env:ZELLIJ_AUTO_EXIT = "true"
if (-not $env:ZELLIJ) {
    if ($env:ZELLIJ_AUTO_ATTACH -eq "true") {
        zellij attach -c
    } else {
        zellij
    }
    if ($env:ZELLIJ_AUTO_EXIT -eq "true") {
        exit
    }
}
# =======================================

# ======== Alias =========================
# PowerShell's built-in "ls" alias (-> Get-ChildItem) takes precedence over
# a same-named function, so it must be removed before defining ls as eza.
Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
function ls { eza --group-directories-first --icons @args }
function ll { eza --group-directories-first --icons --long @args }
function la { eza --group-directories-first --icons --all @args }
function lla { eza --group-directories-first --icons --long --all @args }
function lt { eza --group-directories-first --icons --tree @args }
# =========================================

# ======== Espanso =======================
$env:ESPANSO_CONFIG_DIR = "$HOME\.config\espanso"
# =======================================

# ======== Starship config ===============
$env:STARSHIP_CONFIG = "$HOME\.config\starship\config.toml"
# =========================================
