# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Contents

- `dot_zshrc`, `dot_zimrc` — zsh config (macOS only), using [zim](https://zimfw.sh/) as the framework
- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1` — PowerShell profile (Windows only), mirrors the zsh setup
- `dot_config/starship` — [starship](https://starship.rs/) prompt
- `dot_config/atuin` — [atuin](https://atuin.sh/) shell history
- `dot_config/zellij` — [zellij](https://zellij.dev/) terminal multiplexer
- `dot_config/ghostty` — [ghostty](https://ghostty.org/) terminal emulator (macOS only, not available on Windows)
- `dot_config/espanso` — [espanso](https://espanso.org/) text expander
- `dot_config/nvim` — [AstroNvim](https://astronvim.com/)-based Neovim config
- `.chezmoi.toml.tmpl` — prompts for machine-specific data (`hostname_role`, `email`) on `chezmoi init`
- `.chezmoiignore` — excludes macOS-only files (zsh, ghostty) on Windows and the PowerShell profile on macOS

## Platform support

- **macOS**: full setup, zsh + zim.
- **Windows** (native PowerShell, no WSL): starship, atuin, zellij, espanso, and the eza alias via the PowerShell profile. zsh/zim and ghostty configs are skipped automatically by `.chezmoiignore`.

## Requirements

### macOS

- [Homebrew](https://brew.sh/)
- `zimfw` (`brew install zimfw`)
- `eza`, `starship`, `atuin`, `zellij`, `espanso`, `ghostty`, `neovim`

### Windows

- [winget](https://learn.microsoft.com/windows/package-manager/winget/) or [scoop](https://scoop.sh/)
- `eza`, `starship`, `atuin`, `zellij`, `espanso`, `neovim`

## Usage

### One-shot bootstrap (new machine)

Installs all required software and applies the dotfiles in one go.

macOS:

```sh
curl -fsSL https://raw.githubusercontent.com/guangl/dotfiles/main/install.sh | bash
```

Windows (PowerShell, requires `winget`):

```powershell
irm https://raw.githubusercontent.com/guangl/dotfiles/main/install.ps1 | iex
```

On first run, `chezmoi init` will prompt for `hostname_role` and `email`.

### Manual / already have chezmoi

```sh
chezmoi init https://github.com/guangl/dotfiles.git
chezmoi diff
chezmoi apply
```
