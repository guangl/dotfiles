#!/usr/bin/env bash
# Bootstrap a macOS machine: install Homebrew, install everything in Brewfile
# (CLI tools, casks, VS Code extensions), then apply dotfiles via chezmoi.
set -euo pipefail

REPO="guangl/dotfiles"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

retry() {
  local description="$1"
  shift
  local max_attempts=3
  local delay_seconds=5
  local attempt=1
  while true; do
    if "$@"; then
      return 0
    fi
    if [[ ${attempt} -ge ${max_attempts} ]]; then
      echo "==> ${description} failed after ${max_attempts} attempts" >&2
      return 1
    fi
    echo "==> ${description} failed (attempt ${attempt}/${max_attempts}), retrying in ${delay_seconds}s..." >&2
    sleep "${delay_seconds}"
    attempt=$((attempt + 1))
  done
}

if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew..."
  retry "Homebrew install" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [[ -f "${SCRIPT_DIR}/Brewfile" ]]; then
  echo "==> Installing everything in Brewfile"
  retry "brew bundle install" brew bundle install --file="${SCRIPT_DIR}/Brewfile"
else
  echo "==> No local Brewfile found, fetching from repo and installing"
  retry "brew bundle install" bash -c "curl -fsSL https://raw.githubusercontent.com/${REPO}/main/Brewfile | brew bundle install --file=-"
fi

echo "==> Applying dotfiles from ${REPO}"
retry "chezmoi init --apply" chezmoi init --apply "${REPO}"

echo "==> Done. Restart your terminal to pick up the new shell config."
