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

$ScoopApps = @(
  # required by Documents/PowerShell/Microsoft.PowerShell_profile.ps1 and
  # the dot_config dotfiles
  "pwsh"
  "starship"
  "atuin"
  "zellij"
  "eza"
  "espanso"
  "zoxide"
  "trashy"
  "git"
  "FiraCode-NF-Mono" # nerd font for starship/eza icon glyphs

  # dev tooling
  "chezmoi"
  "gh"
  "neovim"
  "nodejs"
  "bun"
  "go"
  "rustup"
  "gcc"
  "make"
  "pyenv"
  "python"
  "zig"
  "sqlite"
  "bat"

  # GUI apps installed via scoop (extras bucket)
  "googlechrome"
  "vscode"
  "windows-terminal"
  "heidisql"
  "notepadplusplus"
  "potplayer"
  "sumatrapdf"
  "telegram"
  "Termius"
  "wechat"
  "wecom"
  "wpsoffice"
  "jetbrains-toolbox"
  "claude"

  # misc CLI utilities
  "1password-cli"
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

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Write-Host "==> Installing scoop"
  Invoke-RestMethod get.scoop.sh | Invoke-Expression
}

foreach ($bucket in $ScoopBuckets) {
  scoop bucket add $bucket 2>$null
}

foreach ($app in $ScoopApps) {
  Write-Host "==> scoop install $app"
  try {
    scoop install $app
  } catch {
    Write-Warning "scoop install $app failed: $_"
  }
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
