#!/usr/bin/env bash
# Bootstrap a macOS machine: install Homebrew, install everything in Brewfile
# (CLI tools, casks, VS Code extensions), then apply dotfiles via chezmoi.
set -euo pipefail

REPO="guangl/dotfiles"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [[ -f "${SCRIPT_DIR}/Brewfile" ]]; then
  echo "==> Installing everything in Brewfile"
  brew bundle install --file="${SCRIPT_DIR}/Brewfile"
else
  echo "==> No local Brewfile found, fetching from repo and installing"
  curl -fsSL "https://raw.githubusercontent.com/${REPO}/main/Brewfile" | brew bundle install --file=-
fi

echo "==> Applying dotfiles from ${REPO}"
chezmoi init --apply "${REPO}"

echo "==> Done. Restart your terminal to pick up the new shell config."
