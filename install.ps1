# Bootstrap a Windows machine: install winget packages, then apply dotfiles via chezmoi.
# Run from an elevated or regular PowerShell prompt:
#   irm https://raw.githubusercontent.com/guangl/dotfiles/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$Repo = "guangl/dotfiles"

# winget package IDs - verify with `winget search <name>` if any of these fail.
$Packages = @(
  "twpayne.chezmoi",
  "eza-community.eza",
  "Starship.Starship",
  "ellie.atuin",
  "zellij-org.zellij",
  "Espanso.Espanso",
  "Neovim.Neovim"
)

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  throw "winget not found. Install 'App Installer' from the Microsoft Store first."
}

foreach ($id in $Packages) {
  Write-Host "==> Installing $id"
  winget install --id $id -e --accept-source-agreements --accept-package-agreements --silent
}

Write-Host "==> Applying dotfiles from $Repo"
chezmoi init --apply $Repo

Write-Host "==> Done. Restart your terminal to pick up the new profile."
