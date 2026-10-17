# dotfiles

Everything that defines how my machines are set up: shell, prompt, terminal,
editors, CLI tools, AI coding agents, and the macOS system preferences that are
worth reproducing. Managed with [chezmoi](https://www.chezmoi.io/).

Snapshotted from a MacBook Air (macOS) in October 2026 and kept in sync with
[`scripts/sync_home.py`](./scripts/sync_home.py).

## Layout

```
.chezmoiroot                 # "home" — the chezmoi source directory
home/                        # everything that lands in $HOME
  .chezmoi.toml.tmpl         # prompts for hostname_role / email on init
  .chezmoiignore             # platform-specific exclusions (Windows/macOS)
  dot_zshrc, dot_config/…    # chezmoi source names
scripts/sync_home.py         # reproducible capture from a live machine
Brewfile, packages.csv       # package lists
install.sh, install.ps1      # one-shot bootstrap
```

Source files use chezmoi naming: a leading `.` in the name is written as
`dot_`, so `home/dot_zshrc` becomes `~/.zshrc` and `home/dot_config/ghostty`
becomes `~/.config/ghostty`. Files that are `0600` on the machine keep that
mode through the `private_` prefix (`home/dot_config/private_atuin/private_config.toml`
→ `~/.config/atuin/config.toml`).

## What is captured

| Area | Source paths | Lands at |
| --- | --- | --- |
| Shell | `dot_zshrc`, `dot_zprofile`, `dot_profile`, `dot_zimrc`, `dot_config/fish/conf.d/uv.env.fish`, `dot_local/share/zsh/site-functions/_dm` | `~/.zshrc`, `~/.zprofile`, `~/.profile`, `~/.zimrc`, `~/.config/fish/conf.d/uv.env.fish`, `~/.local/share/zsh/site-functions/_dm` |
| Prompt / terminal | `dot_config/starship`, `dot_config/zellij`, `dot_config/ghostty` | `~/.config/{starship,zellij,ghostty}` |
| Shell history | `dot_config/private_atuin/private_config.toml` | `~/.config/atuin/config.toml` (0600) |
| Neovim | `dot_config/nvim` (AstroNvim) | `~/.config/nvim` |
| Git / SSH | `dot_gitconfig`, `dot_config/git/ignore`, `dot_config/jgit/config`, `dot_config/gh/private_config.yml`, `dot_ssh/config`, `dot_ssh/id_ed25519.pub` | `~/.gitconfig`, `~/.config/{git,jgit,gh}`, `~/.ssh/{config,id_ed25519.pub}` |
| Containers / runtimes | `dot_docker/private_config.json`, `dot_rustup/settings.toml` | `~/.docker/config.json` (0600), `~/.rustup/settings.toml` |
| Small tools | `dot_config/{chezmoi,billion-context,mimocode,espanso}` | matching paths under `~/.config` |
| AI coding agents | `dot_claude/{private_settings.json,skills}`, `dot_codex/{private_config.toml,keybindings.json,AGENTS.md}`, `dot_agents/skills`, `dot_codewhale/config.toml`, `dot_dsh/profiles/web` (config only, no `node_modules`) | `~/.claude`, `~/.codex`, `~/.agents/skills`, `~/.codewhale`, `~/.dsh/profiles/web` |
| Packages | `Brewfile`, `packages.csv`, `install.sh`, `install.ps1` | package managers |
| Windows | `Documents/PowerShell/Microsoft.PowerShell_profile.ps1` | PowerShell profile |

Skills live once in `~/.agents/skills`; `run_once_after_setup-claude-skills.sh`
creates the `~/.claude/skills/weread-skills` symlink that Claude Code needs.

## Secrets and exclusions

**This repository is public.** Credential material is never committed:

- not captured at all: private SSH keys, `~/.config/gh/hosts.yml`,
  `~/.codex/auth.json`, `~/.dsh/.credentials.yaml`, `.config/op` and 1Password
  data, `~/.claude.json` and its backups, shell history (`.zsh_history`,
  `.bash_history`, `.viminfo`), caches, `node_modules`, VS Code extension
  binaries, the bulk of `~/Library/Preferences`, and the parts of
  `~/Library/Application Support` that are state rather than configuration
  (browser profiles, Alfred's 35 MB preferences bundle, IDE caches, SQLite
  session databases).
- redacted in place: anything matching a known token shape (`wrk-`, `sk-`,
  `github_pat_`, `gh[pousr]_`, `AKIA…`, `xox[baprs]-`) is replaced with
  `REDACTED` before it is written. Today that affects
  `home/dot_claude/private_settings.json` and `home/dot_codex/private_config.toml`
  (`WEREAD_API_KEY`) and `home/dot_codewhale/config.toml` (an `sk-` API key).

After applying on a new machine, put real values back locally (or export them
from your shell environment); re-running the capture script redacts them again.

## Re-sync from a live machine

```sh
python3 scripts/sync_home.py --dry-run   # show what would change
python3 scripts/sync_home.py             # copy + redact into home/
git diff                                 # review before committing
```

The manifest lives at the top of [`scripts/sync_home.py`](./scripts/sync_home.py);
add a path there when you start configuring something new.

## Apply

```sh
chezmoi init https://github.com/guangl/dotfiles.git
chezmoi diff
chezmoi apply
```

## One-shot bootstrap (new machine)

Installs the package manager, every package, and applies the dotfiles in one go.

macOS (installs Homebrew if missing, then `brew bundle install` from
[`Brewfile`](./Brewfile) — CLI tools, casks, and VS Code extensions):

```sh
curl -fsSL https://raw.githubusercontent.com/guangl/dotfiles/main/install.sh | bash
```

Windows (PowerShell, installs [scoop](https://scoop.sh/) for CLI and GUI apps
and uses `winget` as a fallback — the package list lives in `$ScoopApps` /
`$WingetApps` in [`install.ps1`](./install.ps1)):

```powershell
irm https://raw.githubusercontent.com/guangl/dotfiles/main/install.ps1 | iex
```

On first run, `chezmoi init` prompts for `hostname_role` and `email`.

## Platform support

- **macOS**: full setup — zsh + zim, ghostty, and the CLI toolchain.
- **Windows** (native PowerShell, no WSL): starship, atuin, zellij, espanso and
  the eza alias via the PowerShell profile. zsh/zim, ghostty, fish, jgit and
  `~/.local` are skipped by [`home/.chezmoiignore`](./home/.chezmoiignore).

## Requirements

### macOS

- [Homebrew](https://brew.sh/)
- `zimfw` (`brew install zimfw`)
- `eza`, `starship`, `atuin`, `zellij`, `espanso`, `ghostty`, `neovim`

### Windows

- [winget](https://learn.microsoft.com/windows/package-manager/winget/) or
  [scoop](https://scoop.sh/)
- `eza`, `starship`, `atuin`, `zellij`, `espanso`, `neovim`
