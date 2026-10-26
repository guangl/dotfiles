#!/usr/bin/env python3
"""Capture this machine's configuration files into the chezmoi source tree.

Each entry in MANIFEST is a path relative to $HOME. Files are copied into
home/ (the chezmoi source directory, see .chezmoiroot) using chezmoi's source
naming (a leading "." becomes "dot_"), directories are copied recursively, and
credential-looking strings are redacted on the way in.

Usage: python3 scripts/sync_home.py [--dry-run]
"""
from __future__ import annotations

import os
import re
import shutil
import sys
from pathlib import Path

HOME = Path.home()
REPO = Path(__file__).resolve().parent.parent
SOURCE = REPO / "home"

MANIFEST = [
    # --- shell -------------------------------------------------------------
    ".zshrc",
    ".zprofile",
    ".profile",
    ".zimrc",
    ".config/atuin/config.toml",
    ".config/starship/config.toml",
    ".config/zellij/config.kdl",
    ".config/ghostty/config.ghostty",
    ".local/share/zsh/site-functions/_dm",
    # --- git ---------------------------------------------------------------
    ".gitconfig",
    ".config/git/ignore",
    ".config/jgit/config",
    ".config/gh/config.yml",
    # --- editors -----------------------------------------------------------
    ".config/nvim",
    # --- tools -------------------------------------------------------------
    ".docker/config.json",
    ".rustup/settings.toml",
    ".config/chezmoi/chezmoi.toml",
    ".config/mimocode/mimocode.jsonc",
    # --- AI coding agents --------------------------------------------------
    ".agents/skills",
]

# Never copied even when they live inside a manifest directory.
EXCLUDE_DIRS = {"node_modules", "__pycache__", ".git", ".system", "reports"}
EXCLUDE_NAMES = {".DS_Store"}
EXCLUDE_PREFIXES = (".backup-",)

# Credential-looking strings are replaced before anything lands in the repo.
# The repository is public, so treat every captured file as world-readable.
SECRET_PATTERNS = [
    (re.compile(r"wrk-[A-Za-z0-9_\-]{10,}"), "REDACTED"),
    (re.compile(r"sk-[A-Za-z0-9]{20,}"), "REDACTED"),
    (re.compile(r"github_pat_[A-Za-z0-9_]{20,}"), "REDACTED"),
    (re.compile(r"gh[pousr]_[A-Za-z0-9]{20,}"), "REDACTED"),
    (re.compile(r"AKIA[0-9A-Z]{16}"), "REDACTED"),
    (re.compile(r"xox[baprs]-[A-Za-z0-9\-]{10,}"), "REDACTED"),
]

TEXT_SUFFIXES = {
    "", ".sh", ".zsh", ".bash", ".fish", ".toml", ".yml", ".yaml", ".json",
    ".jsonc", ".kdl", ".conf", ".cfg", ".ini", ".lua", ".md", ".txt", ".py",
    ".js", ".ts", ".css", ".html", ".xml", ".plist", ".properties", ".env",
    ".pub", ".ignore", ".gitconfig", ".vim", ".jsx", ".tsx", ".ps1",
}

# Files that are 0600 on the machine. chezmoi only recreates that mode when a
# path component carries the private_ prefix, so keep the explicit mapping.
PRIVATE_FILES = {
    ".config/atuin/config.toml": "dot_config/private_atuin/private_config.toml",
    ".config/gh/config.yml": "dot_config/gh/private_config.yml",
    ".docker/config.json": "dot_docker/private_config.json",
}

DRY_RUN = "--dry-run" in sys.argv


def chezmoi_name(rel: str) -> str:
    """Map a $HOME-relative path to its chezmoi source path."""
    if rel in PRIVATE_FILES:
        return PRIVATE_FILES[rel]
    parts = []
    for part in Path(rel).parts:
        parts.append("dot_" + part[1:] if part.startswith(".") else part)
    return str(Path(*parts))


def redact(text: str) -> str:
    for pattern, replacement in SECRET_PATTERNS:
        text = pattern.sub(replacement, text)
    return text


def is_text(path: Path) -> bool:
    if path.suffix.lower() not in TEXT_SUFFIXES and path.name not in {"config", "ignore"}:
        return False
    try:
        with path.open("rb") as fh:
            chunk = fh.read(4096)
        chunk.decode("utf-8")
        return True
    except (OSError, UnicodeDecodeError):
        return False


def copy_file(src: Path, dest: Path) -> str:
    dest.parent.mkdir(parents=True, exist_ok=True)
    if src.is_symlink():
        target = os.readlink(src)
        if dest.is_symlink() or dest.exists():
            dest.unlink()
        if not DRY_RUN:
            os.symlink(target, dest)
        return "symlink"
    if is_text(src) and src.stat().st_size < 2_000_000:
        original = src.read_text(encoding="utf-8", errors="replace")
        cleaned = redact(original)
        if not DRY_RUN:
            dest.write_text(cleaned, encoding="utf-8")
        return "redacted" if cleaned != original else "copied"
    if not DRY_RUN:
        shutil.copy2(src, dest)
    return "copied"


def copy_path(rel: str, stats: dict[str, int]) -> None:
    src = HOME / rel
    dest = SOURCE / chezmoi_name(rel)
    if not src.exists() and not src.is_symlink():
        stats["missing"] += 1
        print(f"  skip (missing): {rel}")
        return
    if src.is_dir() and not src.is_symlink():
        for root, dirs, files in os.walk(src):
            root_path = Path(root)
            kept = []
            for d in dirs:
                if d in EXCLUDE_DIRS or d.startswith(EXCLUDE_PREFIXES):
                    continue
                child_dir = root_path / d
                if child_dir.is_symlink():
                    child = child_dir.relative_to(HOME)
                    outcome = copy_file(child_dir, SOURCE / chezmoi_name(str(child)))
                    stats[outcome] += 1
                    print(f"  {outcome}: {child}")
                    continue
                kept.append(d)
            dirs[:] = kept
            for name in files:
                if name in EXCLUDE_NAMES:
                    continue
                file_path = root_path / name
                child = file_path.relative_to(HOME)
                outcome = copy_file(file_path, SOURCE / chezmoi_name(str(child)))
                stats[outcome] += 1
                if outcome == "redacted":
                    print(f"  redacted: {child}")
        return
    outcome = copy_file(src, dest)
    stats[outcome] += 1
    print(f"  {outcome}: {rel}")


def main() -> int:
    stats = {"copied": 0, "redacted": 0, "symlink": 0, "missing": 0}
    for rel in MANIFEST:
        copy_path(rel, stats)
    print(
        "\nsummary: {copied} copied, {redacted} redacted, {symlink} symlinks, "
        "{missing} missing".format(**stats)
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
