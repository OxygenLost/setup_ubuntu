# Setup Ubuntu

适用于 **Ubuntu 22.04 / 24.04** 的终端环境一键配置脚本。安装现代化 CLI 工具、写入精心调配的 `.zshrc`，并配置 Starship 提示符 —— 一次运行全部搞定。脚本**幂等**，重复执行不会产生副作用。

![Shell](https://img.shields.io/badge/shell-bash-blue)
![Platform](https://img.shields.io/badge/platform-Ubuntu%2022.04%20%7C%2024.04-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## 快速开始

一行命令，直接从远程下载并执行：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/OxygenLost/setup_ubuntu/main/setup_ubuntu.sh)
```

或者手动克隆后执行：

```bash
git clone https://github.com/OxygenLost/setup_ubuntu.git
cd setup_ubuntu
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh
```

### 安装完成后

1. **注销并重新登录**（或直接运行 `zsh`）以激活新的默认 Shell。
2. 将终端字体设置为 **JetBrainsMono Nerd Font** 以正确显示图标。
3. 运行 `source ~/.zshrc` 加载新配置。

## 安装内容

### CLI 工具

| 步骤 | 工具 | 用途 |
|:----:|------|------|
| 1 | [Zsh](https://www.zsh.org/) | 默认 Shell，强大的脚本与补全能力 |
| 2 | Git / curl / wget / unzip / fontconfig | 基础构建与下载工具 |
| 3 | [Starship](https://starship.rs/) | 快速跨 Shell 提示符，内置 Git 状态 |
| 4 | [eza](https://github.com/eza-community/eza) | 现代 `ls`，支持图标、Git 感知与树状视图 |
| 5 | [bat](https://github.com/sharkdp/bat) | 现代 `cat`，语法高亮 + 行号 |
| 6 | [fzf](https://github.com/junegunn/fzf) | 模糊查找器，`Ctrl+R` 搜历史，`Ctrl+T` 搜文件 |
| 7 | [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) / [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | 幽灵文字补全 + 实时语法着色 |
| 8 | [broot](https://github.com/Canop/broot) + tree | 交互式与经典目录树查看器 |
| — | [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts) | 补丁字体，支持终端图标渲染 |

### 开发环境

| 工具 | 说明 |
|------|------|
| [uv](https://github.com/astral-sh/uv) | 极速 Python 包管理器（Rust 实现） |
| [nvm](https://github.com/nvm-sh/nvm) v0.40.4 | Node.js 版本管理器 |
| Node.js 22 | 通过 nvm 安装的 LTS 版本 |
| [@openai/codex](https://www.npmjs.com/package/@openai/codex) | OpenAI Codex CLI，全局安装 |
| [vibe-remote](https://github.com/cyhhao/vibe-remote) | 远程 Vibe 开发工具 |
| [cc-switch-cli](https://github.com/SaladDay/cc-switch-cli) | Claude Code 账号切换工具 |

## 配置内容

- **`.zshrc`** — 历史记录、Tab 补全、Emacs 风格快捷键、git / eza / bat / tree 别名，以及 `mkcd`、`extract`、`f`（快速文件搜索）等辅助函数。
- **`starship.toml`** — 双行提示符，显示目录、Git 分支/状态、语言版本（Python、Node、Rust）、命令耗时与时钟。
- **ROS 2 Jazzy** — 若检测到 `/opt/ros/jazzy/setup.zsh` 则自动 source。

## 别名速查

### 文件导航

| 别名 | 命令 |
|------|------|
| `ls` | `eza --icons` |
| `ll` | `eza -lh --icons --git` |
| `la` | `eza -lah --icons --git` |
| `lt` | `eza --tree --icons --level=2` |
| `cat` | `bat --paging=never` |
| `t2` / `t3` | `tree -L 2` / `tree -L 3` |

### Git

| 别名 | 命令 |
|------|------|
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git log --oneline --graph --decorate --color` |
| `gd` | `git diff` |
| `gco` | `git checkout` |

### 辅助函数

| 函数 | 说明 |
|------|------|
| `mkcd <dir>` | 创建目录并进入 |
| `f <pattern>` | 大小写不敏感的快速文件搜索 |
| `extract <file>` | 解压任意常见压缩格式 |

## 系统要求

- **Ubuntu 22.04 或 24.04**（其他 Debian 系发行版稍作调整应可兼容）
- 拥有 **sudo** 权限

## 自定义

脚本会直接写入 `~/.zshrc` 和 `~/.config/starship.toml`。安装后可直接编辑这两个文件进行自定义。重新运行脚本时，现有 `.zshrc` 会先备份为 `.zshrc.bak` 再覆盖。

## License

[MIT License](LICENSE)
