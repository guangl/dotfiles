# Bootstrap a Windows machine: install scoop + winget packages, then apply
# dotfiles via chezmoi.
#
# Run from a regular PowerShell prompt:
#   irm https://raw.githubusercontent.com/guangl/dotfiles/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$Repo = "guangl/dotfiles"

# ---- scoop (CLI tools) ------------------------------------------------------

$ScoopBuckets = @(
  "extras"
  "nerd-fonts"
)

# Windows-only apps; cross-platform CLI/app names shared with the Brewfile
# live in packages.csv (see below) so they aren't duplicated here.
$ScoopApps = @(
  # required by Documents/PowerShell/Microsoft.PowerShell_profile.ps1 and
  # the dot_config dotfiles
  "pwsh"
  "FiraCode-NF-Mono" # nerd font for starship/eza icon glyphs

  # dev tooling
  "go"
  "gcc"
  "make"
  "pyenv"
  "python"
  "zig"

  # GUI apps installed via scoop (extras bucket)
  "windows-terminal"
  "heidisql"
  "notepadplusplus"
  "potplayer"
  "sumatrapdf"
  "wecom"
  "wpsoffice"

  # misc CLI utilities
  "7zip"
  "innounp" # dependency for extracting some installers
  "dark"    # dependency for extracting some installers

  # fonts
  "FiraCode"
  "jetbrainsmono-nf"
  "LXGWWenKai"
  "LXGWWenKaiMono"
)

# ---- winget (GUI apps) ------------------------------------------------------

$WingetApps = @(
  # add winget package IDs here
)

# -----------------------------------------------------------------------------

function Invoke-WithRetry {
  param(
    [Parameter(Mandatory)] [scriptblock]$Action,
    [string]$Description = "command",
    [int]$MaxAttempts = 3,
    [int]$DelaySeconds = 5
  )

  for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
    try {
      & $Action
      return
    } catch {
      if ($attempt -eq $MaxAttempts) {
        Write-Warning "$Description failed after $MaxAttempts attempts: $_"
        return
      }
      Write-Warning "$Description failed (attempt $attempt/$MaxAttempts): $_. Retrying in ${DelaySeconds}s..."
      Start-Sleep -Seconds $DelaySeconds
    }
  }
}

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Write-Host "==> Installing scoop"
  Invoke-RestMethod get.scoop.sh | Invoke-Expression
}

foreach ($bucket in $ScoopBuckets) {
  scoop bucket add $bucket 2>$null
}

foreach ($app in $ScoopApps) {
  Write-Host "==> scoop install $app"
  Invoke-WithRetry -Description "scoop install $app" -Action { scoop install $app }
}

# Cross-platform CLI/app names (shared with the Brewfile) live in
# packages.csv so the two package lists don't drift apart.
$LocalCsv = Join-Path $PSScriptRoot "packages.csv"
if ($PSScriptRoot -and (Test-Path $LocalCsv)) {
  $CommonPackages = Import-Csv $LocalCsv
} else {
  $CsvUrl = "https://raw.githubusercontent.com/$Repo/main/packages.csv"
  Invoke-WithRetry -Description "download packages.csv" -Action {
    $script:CommonPackages = Invoke-WebRequest -Uri $CsvUrl | Select-Object -ExpandProperty Content | ConvertFrom-Csv
  }
}

foreach ($pkg in $CommonPackages) {
  Write-Host "==> scoop install $($pkg.scoop)"
  Invoke-WithRetry -Description "scoop install $($pkg.scoop)" -Action { scoop install $pkg.scoop }
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  throw "winget not found. Install 'App Installer' from the Microsoft Store first."
}

foreach ($id in $WingetApps) {
  Write-Host "==> winget install $id"
  Invoke-WithRetry -Description "winget install $id" -Action {
    winget install --id $id -e --accept-source-agreements --accept-package-agreements --silent
  }
}

Write-Host "==> Applying dotfiles from $Repo"
Invoke-WithRetry -Description "chezmoi init --apply $Repo" -Action { chezmoi init --apply $Repo }

Write-Host "==> Done. Restart your terminal to pick up the new profile."
