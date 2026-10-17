#!/bin/sh
# Claude Code only discovers skills under ~/.claude/skills, while the shared
# skills live in ~/.agents/skills. Mirror that layout with a symlink.
set -eu

TARGET="$HOME/.agents/skills/weread-skills"
LINK="$HOME/.claude/skills/weread-skills"

if [ -e "$LINK" ] || [ -L "$LINK" ]; then
  exit 0
fi
mkdir -p "$HOME/.claude/skills"
ln -s "$TARGET" "$LINK"