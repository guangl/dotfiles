#!/usr/bin/env bash
# Re-export the curated macOS preference domains into defaults/ as XML plists
# (reviewable diffs, and the capture script can scan them for secrets).
# Usage: ./macos/capture.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${SCRIPT_DIR}/defaults"

DOMAINS=(
  NSGlobalDomain
  com.apple.dock
  com.apple.finder
  com.apple.screencapture
  com.apple.menuextra.clock
  com.apple.controlcenter
  com.apple.AppleMultitouchTrackpad
  com.apple.AppleMultitouchMouse
  com.apple.symbolichotkeys
  com.apple.desktopservices
  com.apple.TextEdit
  com.apple.WindowManager
  com.apple.universalaccess
  com.apple.iCal
  com.apple.ActivityMonitor
  com.apple.Terminal
  com.apple.systemuiserver
)

mkdir -p "${DEST}"
for domain in "${DOMAINS[@]}"; do
  if ! defaults read "${domain}" >/dev/null 2>&1; then
    echo "skip (no such domain): ${domain}"
    continue
  fi
  defaults export "${domain}" "${DEST}/${domain}.plist"
  plutil -convert xml1 "${DEST}/${domain}.plist"
  echo "captured: ${domain}"
done
