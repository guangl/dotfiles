# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Contents

- `dot_zshrc`, `dot_zimrc` — zsh config, using [zim](https://zimfw.sh/) as the framework
- `dot_config/starship` — [starship](https://starship.rs/) prompt
- `dot_config/atuin` — [atuin](https://atuin.sh/) shell history
- `dot_config/zellij` — [zellij](https://zellij.dev/) terminal multiplexer
- `dot_config/ghostty` — [ghostty](https://ghostty.org/) terminal emulator
- `dot_config/espanso` — [espanso](https://espanso.org/) text expander
- `dot_config/nvim` — [AstroNvim](https://astronvim.com/)-based Neovim config

## Requirements

- [Homebrew](https://brew.sh/)
- `zimfw` (`brew install zimfw`)
- `eza`, `starship`, `atuin`, `zellij`, `espanso`, `ghostty`, `neovim`

## Usage

```sh
chezmoi init https://github.com/guangl/dotfiles.git
chezmoi diff
chezmoi apply
```
