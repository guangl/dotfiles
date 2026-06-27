# Bootstrap a Windows machine: install scoop + winget packages, then apply
# dotfiles via chezmoi.
#
# Run from a regular PowerShell prompt:
#   irm https://raw.githubusercontent.com/guangl/dotfiles/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$Repo = "guangl/dotfiles"

# ---- scoop (CLI tools) ------------------------------------------------------

$ScoopBuckets = @()

$ScoopApps = @(
  # add scoop package names here
)

# ---- winget (GUI apps) ------------------------------------------------------

$WingetApps = @(
  # add winget package IDs here
)

# -----------------------------------------------------------------------------

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Write-Host "==> Installing scoop"
  Invoke-RestMethod get.scoop.sh | Invoke-Expression
}

foreach ($bucket in $ScoopBuckets) {
  scoop bucket add $bucket 2>$null
}

foreach ($app in $ScoopApps) {
  Write-Host "==> scoop install $app"
  scoop install $app
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  throw "winget not found. Install 'App Installer' from the Microsoft Store first."
}

foreach ($id in $WingetApps) {
  Write-Host "==> winget install $id"
  winget install --id $id -e --accept-source-agreements --accept-package-agreements --silent
}

Write-Host "==> Applying dotfiles from $Repo"
chezmoi init --apply $Repo

Write-Host "==> Done. Restart your terminal to pick up the new profile."
