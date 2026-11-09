#!/usr/bin/env python3
"""Render a static HTML overview of the dotfiles repository."""

import argparse
from html import escape
from pathlib import Path
import re
import subprocess
from urllib.parse import quote


ROOT = Path(__file__).resolve().parents[1]
GITHUB_REPO = "https://github.com/guangl/dotfiles"
SECTIONS = (
    (
        "配置管理",
        "chezmoi 把仓库里的源文件映射到用户目录，并按平台应用不同配置。同步脚本负责从本机回收纳管的文件。",
        (".chezmoiroot", "home/.chezmoiignore", "home/.chezmoi.toml.tmpl", "scripts/sync_home.py"),
    ),
    (
        "Shell 与终端",
        "Zim 管理 zsh 模块，Starship 提供提示符，Atuin 管理命令历史，Ghostty 和 Zellij 分别负责终端界面与会话。",
        ("home/dot_zshrc", "home/dot_zimrc", "home/dot_config/starship",
         "home/dot_config/private_atuin", "home/dot_config/ghostty", "home/dot_config/zellij"),
    ),
    (
        "编辑器",
        "Neovim 以 AstroNvim 为基础。仓库保存插件配置和锁文件，便于在其他机器上复现插件组合。",
        ("home/dot_config/nvim",),
    ),
    (
        "版本控制与运行时",
        "Git 与 CLI 配置记录可复用的工作习惯，Docker 和 Rustup 的设置随配置迁移。",
        ("home/dot_gitconfig", "home/dot_config/git", "home/dot_config/jgit",
         "home/dot_config/gh", "home/dot_docker", "home/dot_rustup"),
    ),
    (
        "软件与系统入口",
        "macOS 和 Windows 各自通过原生的软件管理工具安装依赖，Windows 另有 PowerShell 配置入口。",
        ("Brewfile", "packages.csv", "install.sh", "install.ps1", "home/Documents/PowerShell"),
    ),
    (
        "GitHub Actions",
        "推送到 main 或手动运行后，工作流读取仓库配置，生成静态 HTML，并发布到 GitHub Pages。",
        (".github/workflows/configuration-report.yml", "scripts/render_config_report.py"),
    ),
)

PACKAGE_GROUPS = {
    "brew": "Homebrew 命令行工具",
    "cask": "macOS 应用",
    "vscode": "VS Code 扩展",
    "cargo": "Cargo 工具",
    "uv": "Python 工具",
    "npm": "npm 工具",
}


def render_packages() -> str:
    brewfile = (ROOT / "Brewfile").read_text(encoding="utf-8")
    entries = re.findall(r'^([a-z]+) "([^"]+)"', brewfile, re.MULTILINE)
    groups = []
    for kind, title in PACKAGE_GROUPS.items():
        names = [escape(name) for entry_kind, name in entries if entry_kind == kind]
        if names:
            items = "".join(f"<li><code>{name}</code></li>" for name in names)
            groups.append(f"<details><summary>{title}（{len(names)}）</summary><ul>{items}</ul></details>")
    return "\n".join(groups)


def render_report() -> str:
    commit = subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True
    ).strip()
    state = subprocess.check_output(
        ["git", "status", "--porcelain"], cwd=ROOT, text=True
    )
    short_commit = commit[:7]
    version = f"{short_commit} · 含本地改动" if state else short_commit
    cards = []
    for title, explanation, paths in SECTIONS:
        items = []
        for path in paths:
            source = ROOT / path
            if source.exists():
                label = f"<code>{escape(path)}</code>"
                if not state:
                    view = "tree" if source.is_dir() else "blob"
                    url = f"{GITHUB_REPO}/{view}/{commit}/{quote(path)}"
                    label = f'<a href="{url}">{label}</a>'
                items.append(f"<li>{label}</li>")
        cards.append(
            f"<section><h2>{escape(title)}</h2><p>{escape(explanation)}</p><ul>{''.join(items)}</ul></section>"
        )
    sections = "\n".join(cards)
    return f"""<!doctype html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>dotfiles 配置报告</title>
<style>
* {{ box-sizing: border-box; }}
body {{ margin: 0; background: #f4f5ef; color: #162927; font: 16px/1.65 system-ui, sans-serif; }}
main {{ max-width: 1040px; margin: auto; padding: 48px 24px; }}
header {{ border-top: 5px solid #08665e; padding: 20px 0; }}
h1 {{ font-size: clamp(32px, 7vw, 64px); line-height: 1.1; margin: 12px 0; }}
h2 {{ margin: 0; font-size: 21px; }}
.label {{ color: #08665e; font: 700 13px system-ui, sans-serif; letter-spacing: .12em; }}
.grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 295px), 1fr)); gap: 16px; }}
section {{ background: white; border: 1px solid #cdd8d2; border-radius: 12px; padding: 20px; }}
ul {{ padding-left: 20px; margin-bottom: 0; }}
code {{ font-size: .86em; overflow-wrap: anywhere; }}
a {{ color: #08665e; }}
footer {{ margin-top: 24px; color: #3b514e; }}
details {{ margin-top: 12px; }}
summary {{ cursor: pointer; }}
.inventory {{ margin-top: 16px; }}
</style>
</head>
<body>
<main>
<header>
<p class="label">DOTFILES / CONFIGURATION</p>
<h1>配置报告</h1>
<p>仓库配置的用途、组织方式与文件位置。</p>
<p>版本 <code>{escape(version)}</code></p>
</header>
<div class="grid">
{sections}
</div>
<section class="inventory">
<h2>macOS 软件清单</h2>
<p>以下条目从当前版本的 Brewfile 读取。Windows 软件由独立清单管理。</p>
{render_packages()}
</section>
<footer>由 GitHub Actions 生成并发布至 GitHub Pages。</footer>
</main>
</body>
</html>
"""


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    output = parser.parse_args().output
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(render_report(), encoding="utf-8")


if __name__ == "__main__":
    main()
