#!/usr/bin/env bash
# Re-import the curated macOS preference domains captured in defaults/.
# Usage: ./macos/restore.sh [-n]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
[[ "${1:-}" == "-n" ]] && DRY_RUN=1

restart_apps() {
  for app in Dock Finder SystemUIServer; do
    killall "${app}" 2>/dev/null || true
  done
}

for plist in "${SCRIPT_DIR}"/defaults/*.plist; do
  domain="$(basename "${plist}" .plist)"
  echo "==> ${domain}"
  if (( DRY_RUN )); then
    echo "    defaults import ${domain} ${plist}"
  else
    defaults import "${domain}" "${plist}"
  fi
done

if (( DRY_RUN )); then
  echo "dry run: preferences were not changed"
else
  echo "==> Restarting Dock, Finder, and the menu bar"
  restart_apps
fi
