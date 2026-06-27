# Bootstrap a Windows machine: install scoop + winget packages mirroring the
# macOS Brewfile, then apply dotfiles via chezmoi.
#
# Run from a regular PowerShell prompt:
#   irm https://raw.githubusercontent.com/guangl/dotfiles/main/install.ps1 | iex
#
# NOTE: this has not been tested on a real Windows machine yet. Package IDs
# are best-effort guesses from the macOS Brewfile — verify with
# `scoop search <name>` / `winget search <name>` and fix any that fail.

$ErrorActionPreference = "Stop"

$Repo = "guangl/dotfiles"

# ---- scoop (CLI tools, mirrors `brew` formulae) ----------------------------

$ScoopBuckets = @("extras", "nerd-fonts")

$ScoopApps = @(
  "atuin", "bat", "bottom", "bun", "chezmoi", "sqlite", "direnv", "duckdb",
  "dust", "eza", "fd", "ffmpeg", "fzf", "gdu", "gh", "git", "delta",
  "python", "httpie", "hyperfine", "jq", "lazygit", "neovim", "nodejs",
  "openjdk", "postgresql", "ripgrep", "rustup", "starship", "vim", "yq",
  "yt-dlp", "zellij", "zoxide", "espanso",
  "FiraCode-NF"
  # Skipped (no Windows/scoop equivalent): colima, zimfw (zsh-only), trash,
  # pre-commit (install via `pip install pre-commit` instead).
)

# ---- winget (GUI apps, mirrors `cask`) -------------------------------------

$WingetApps = @(
  "AgileBits.1Password.CLI",
  "ScooterSoftware.BeyondCompare4",
  "Anthropic.Claude",
  "Google.Chrome",
  "JetBrains.Toolbox",
  "Valve.Steam",
  "Telegram.TelegramDesktop",
  "Termius.Termius",
  "Mozilla.Thunderbird",
  "Typora.Typora",
  "Microsoft.VisualStudioCode",
  "Tencent.WeChat",
  "Tencent.WeCom"
  # Skipped (macOS-only, no Windows build): alfred, awesun, cleanshot,
  # coteditor, devonthink, downie, ghostty, iina, istat-menus, pearcleaner,
  # popclip, surge. Verify uncertain IDs (navicat, qqmusic, thunder/xunlei,
  # wpsoffice) with `winget search` before relying on this list.
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
