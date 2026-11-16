# dotfiles

Portable shell, terminal, editor and CLI settings, plus software installation
lists for macOS and Windows. Managed with [chezmoi](https://www.chezmoi.io/).

The macOS package inventory was refreshed from the MacBook Air on 2026-11-09.
Managed files are synced with
[`scripts/sync_home.py`](./scripts/sync_home.py).

## Layout

```
.chezmoiroot                 # "home" — the chezmoi source directory
home/                        # everything that lands in $HOME
  .chezmoi.toml.tmpl         # prompts for hostname_role / email on init
  .chezmoiignore             # platform-specific exclusions (Windows/macOS)
  dot_zshrc, dot_config/…    # chezmoi source names
scripts/sync_home.py         # reproducible capture from a live machine
Brewfile, packages.csv       # macOS inventory and Windows package mapping
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
| Shell | `dot_zshrc`, `dot_zprofile`, `dot_profile`, `dot_zimrc`, `dot_local/share/zsh/site-functions/_dm` | `~/.zshrc`, `~/.zprofile`, `~/.profile`, `~/.zimrc`, `~/.local/share/zsh/site-functions/_dm` |
| Prompt / terminal | `dot_config/starship`, `dot_config/zellij`, `dot_config/ghostty` | `~/.config/{starship,zellij,ghostty}` |
| Shell history | `dot_config/private_atuin/private_config.toml` | `~/.config/atuin/config.toml` (0600) |
| Neovim | `dot_config/nvim` (AstroNvim) | `~/.config/nvim` |
| Yazi | `dot_config/yazi/yazi.toml` | `~/.config/yazi/yazi.toml` |
| Git | `dot_gitconfig`, `dot_config/git/ignore`, `dot_config/jgit/config`, `dot_config/gh/private_config.yml` | `~/.gitconfig`, `~/.config/{git,jgit,gh}` |
| Containers / runtimes | `dot_docker/private_config.json`, `dot_rustup/settings.toml` | `~/.docker/config.json` (0600), `~/.rustup/settings.toml` |
| Small tools | `dot_config/{chezmoi,mimocode}` | matching paths under `~/.config` |
| Packages | `Brewfile`, `packages.csv`, `install.sh`, `install.ps1` | package managers |
| Windows | `Documents/PowerShell/Microsoft.PowerShell_profile.ps1` | PowerShell profile |

Claude, DSH, SSH, CodeWhale, Codex, shared agent skills (`~/.agents`),
espanso, fish, and billion-context are no longer captured or managed. Their
existing HOME directories are left intact.
Repository documentation lives outside `home/` and is never installed into HOME.

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
  `REDACTED` before it is written.

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
[`Brewfile`](./Brewfile) — formulae, casks, VS Code extensions, and selected Cargo, uv and npm tools):

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
- **Windows** (native PowerShell, no WSL): starship, atuin, zellij and
  the eza alias via the PowerShell profile. zsh/zim, ghostty, jgit, Yazi's
  standalone configuration and `~/.local` are skipped by
  [`home/.chezmoiignore`](./home/.chezmoiignore).

## Yazi and Neovim on macOS

- In zsh, run `y` to browse and press `q` to return to the shell in the last directory.
- In standalone Yazi, `Enter` on a text file opens it in Neovim.
- In Neovim, press `<Space>-` to reveal the current file or `<Space>fy` to start in the working directory. Press `Enter` on a file in the floating window to open it in the same Neovim session.

## Requirements

### macOS

- [Homebrew](https://brew.sh/)
- `zimfw` (`brew install zimfw`)
- `eza`, `starship`, `atuin`, `zellij`, `ghostty`, `neovim`, `yazi`

### Windows

- [winget](https://learn.microsoft.com/windows/package-manager/winget/) or
  [scoop](https://scoop.sh/)
- `eza`, `starship`, `atuin`, `zellij`, `espanso`, `neovim`

## 配置取舍

- **chezmoi 与显式清单**。同一份仓库可以按平台应用配置，采集脚本只读取明确列出的 HOME 路径。临时诊断脚本、账户状态和历史记录适合留在本机。Docker 和 Rustup 的已有配置会在本机文件缺失时保留，避免用一台机器的状态覆盖其他机器的配置。
- **终端分层**。Zim 管理 zsh 模块，Starship 提供提示符，Atuin 管理历史，Ghostty 和 Zellij 分别负责终端界面和会话。Windows 的 PowerShell 可以复用 Starship、Atuin 和 Zellij。
- **软件清单按平台维护**。`Brewfile` 以 MacBook Air 的当前安装记录为基线，方便重建开发环境。引导清单省略了带本机显式信任设置的 QLStephenSwift。`packages.csv` 的 Scoop 列驱动 Windows 安装，应用是否出现在当前 Mac 上不决定它是否应从 Windows 清单移除。

## 配置报告

在线报告列出配置用途、软件清单和对应的仓库文件。[查看配置报告](https://guangl.github.io/dotfiles/)

推送到 `main` 后，GitHub Actions 会生成报告并发布到 GitHub Pages。
也可以在 **Actions → Publish configuration report** 中手动运行。

在本地生成报告：

```sh
python3 scripts/render_config_report.py /tmp/dotfiles-report/index.html
```
