#!/usr/bin/env bash
# Bootstrap a macOS machine: install Homebrew + packages, then apply dotfiles via chezmoi.
set -euo pipefail

REPO="guangl/dotfiles"
PACKAGES=(chezmoi zimfw eza starship atuin zellij espanso ghostty neovim)

if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "==> Installing packages: ${PACKAGES[*]}"
brew install "${PACKAGES[@]}"

echo "==> Applying dotfiles from ${REPO}"
chezmoi init --apply "${REPO}"

echo "==> Done. Restart your terminal to pick up the new shell config."
