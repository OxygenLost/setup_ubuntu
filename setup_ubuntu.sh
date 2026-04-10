#!/bin/bash
# Premium terminal setup for Ubuntu 24.04
# Ubuntu 22.04、24.04 终端环境一键配置脚本（可重复执行）
# Run: chmod +x setup_ubuntu.sh && ./setup_ubuntu.sh

set -e

# Fail fast: stop immediately when any command fails.
# 失败即退出：任一命令报错时立即停止，避免产生半配置状态。

echo ""
echo "── Updating packages ───────────────────────────────────"
# Refresh APT package index before installation.
# 安装前先刷新 APT 软件包索引。
sudo apt update -qq

echo ""
echo "── 1/8  Zsh ────────────────────────────────────────────"
# Install zsh only when missing; keep reruns idempotent.
# 仅在缺失时安装 zsh，保证重复执行不会重复安装。
if ! command -v zsh &>/dev/null; then
  sudo apt install -y zsh
  # Set zsh as default login shell (effective after re-login).
  # 将 zsh 设为默认登录 shell（需重新登录后生效）。
  chsh -s "$(which zsh)"
  echo "✓ Zsh installed — will be default shell after logout/login"
else
  echo "✓ Already installed"
fi

echo ""
echo "── 2/8  Git + curl + build tools ──────────────────────"
# Install baseline tools required by later steps.
# 安装后续步骤依赖的基础工具。
sudo apt install -y git curl wget unzip fontconfig
echo "✓ Done"

echo ""
echo "── 3/8  Starship (prompt) ──────────────────────────────"
# Official one-line installer; --yes avoids interactive prompt.
# 使用官方安装脚本，--yes 表示无交互安装。
curl -sS https://starship.rs/install.sh | sh -s -- --yes
echo "✓ Starship installed"

echo ""
echo "── 4/8  eza (modern ls) ────────────────────────────────"
# Add upstream APT repo and install eza from it.
# 添加上游 APT 源并安装 eza。
sudo apt install -y gpg
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
  | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
  | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update -qq && sudo apt install -y eza
echo "✓ eza installed"

echo ""
echo "── 5/8  bat (modern cat) ───────────────────────────────"
sudo apt install -y bat
# Ubuntu installs it as 'batcat' to avoid conflict
# Ubuntu 将命令名设为 batcat，这里补一个 bat 软链接，便于统一使用。
mkdir -p ~/.local/bin
ln -sf /usr/bin/batcat ~/.local/bin/bat
echo "✓ bat installed (symlinked as 'bat')"

echo ""
echo "── 6/8  fzf (fuzzy finder) ─────────────────────────────"
if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi
~/.fzf/install --all --no-bash --no-fish --no-update-rc 2>/dev/null || true
echo "✓ fzf installed — ctrl+r: history search, ctrl+t: file search"

echo ""
echo "── 7/8  zsh plugins ────────────────────────────────────"
# Install autosuggestions and syntax-highlighting plugins.
# 安装自动建议与语法高亮插件。
sudo apt install -y zsh-autosuggestions zsh-syntax-highlighting
echo "✓ Plugins installed"

echo ""
echo "── 8/8  tree + broot ───────────────────────────────────"
sudo apt install -y tree
# broot — download latest binary
# Query GitHub release API and pick Linux musl x86_64 binary.
# 通过 GitHub Release API 获取 Linux musl x86_64 二进制下载地址。
BROOT_URL=$(curl -s https://api.github.com/repos/Canop/broot/releases/latest \
  | grep '"browser_download_url"' \
  | grep 'x86_64-unknown-linux-musl' \
  | head -1 \
  | cut -d'"' -f4)
if [ -n "$BROOT_URL" ]; then
  curl -sL "$BROOT_URL" -o /tmp/broot
  chmod +x /tmp/broot
  sudo mv /tmp/broot /usr/local/bin/broot
  # Generate shell integration script (launcher function `br`).
  # 生成 shell 集成脚本（提供 `br` 启动函数）。
  broot --install
  echo "✓ tree + broot installed"
else
  echo "⚠ broot: could not find download URL, skipping (install manually later)"
  echo "✓ tree installed"
fi

echo ""
echo "── uv (Python package manager) ─────────────────────────"
curl -LsSf https://astral.sh/uv/install.sh | sh
echo "✓ uv installed"

echo ""
echo "── nvm (Node version manager) ──────────────────────────"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
echo "✓ nvm installed"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 22
echo "✓ Node 22 installed"
npm install -g @openai/codex
echo "✓ @openai/codex installed"

echo ""
echo "── vibe-remote ─────────────────────────────────────────"
curl -fsSL https://raw.githubusercontent.com/cyhhao/vibe-remote/master/install.sh | bash && vibe
echo "✓ vibe-remote installed"

echo ""
echo "── cc-switch-cli ───────────────────────────────────────"
curl -fsSL https://github.com/SaladDay/cc-switch-cli/releases/latest/download/install.sh | bash
echo "✓ cc-switch-cli installed"

echo ""
echo "── Nerd Font (JetBrainsMono) ───────────────────────────"
# Install Nerd Font for icon rendering in terminal UI.
# 安装 Nerd Font 以支持终端图标显示。
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
  -o /tmp/JetBrainsMono.zip
unzip -qo /tmp/JetBrainsMono.zip -d "$FONT_DIR/JetBrainsMono"
fc-cache -f
echo "✓ JetBrainsMono Nerd Font installed"

echo ""
echo "── Writing ~/.zshrc ────────────────────────────────────"
# Back up existing .zshrc if present
# 若已有配置，先备份再覆盖，避免用户配置丢失。
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.bak && echo "  (backed up existing .zshrc to .zshrc.bak)"

# Write a curated zsh profile in one shot.
# 一次性写入整理好的 zsh 配置。
cat > ~/.zshrc << 'EOF'
# ─────────────────────────────────────────────────────────────
#  PATH
# ─────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

# ─────────────────────────────────────────────────────────────
#  HISTORY
# ─────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY SHARE_HISTORY EXTENDED_HISTORY

# ─────────────────────────────────────────────────────────────
#  COMPLETION
# ─────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
setopt AUTO_CD CORRECT

# ─────────────────────────────────────────────────────────────
#  COLORS
# ─────────────────────────────────────────────────────────────
export CLICOLOR=1
alias grep='grep --color=auto'

# ─────────────────────────────────────────────────────────────
#  KEY BINDINGS
# ─────────────────────────────────────────────────────────────
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ─────────────────────────────────────────────────────────────
#  ALIASES — navigation
# ─────────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'
alias -- -='cd -'
alias reload='source ~/.zshrc && echo "  zshrc reloaded"'
alias path='echo $PATH | tr ":" "\n"'

# ─────────────────────────────────────────────────────────────
#  ALIASES — git
# ─────────────────────────────────────────────────────────────
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --color'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# ─────────────────────────────────────────────────────────────
#  eza — modern ls
# ─────────────────────────────────────────────────────────────
alias ls='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias lt='eza --tree --icons --level=2'

# ─────────────────────────────────────────────────────────────
#  bat — modern cat
# ─────────────────────────────────────────────────────────────
alias cat='bat --paging=never'
export BAT_THEME="TwoDark"

# ─────────────────────────────────────────────────────────────
#  tree
# ─────────────────────────────────────────────────────────────
alias tree='tree -C'
alias t2='tree -L 2'
alias t3='tree -L 3'
alias td='tree -d'

# ─────────────────────────────────────────────────────────────
#  FUNCTIONS
# ─────────────────────────────────────────────────────────────
mkcd() { mkdir -p "$1" && cd "$1"; }
f() { find . -iname "*$1*" 2>/dev/null; }
extract() {
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;; *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;; *.bz2)     bunzip2 "$1" ;;
    *.gz)      gunzip "$1"  ;; *.tar)      tar xf "$1"  ;;
    *.zip)     unzip "$1"   ;; *.7z)       7z x "$1"    ;;
    *) echo "Unknown archive: $1" ;;
  esac
}

# ─────────────────────────────────────────────────────────────
#  fzf — fuzzy finder (ctrl+r: history, ctrl+t: files)
# ─────────────────────────────────────────────────────────────
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --color=dark"

# ─────────────────────────────────────────────────────────────
#  broot — interactive tree navigator (type 'br')
# ─────────────────────────────────────────────────────────────
[[ -f ~/.config/broot/launcher/bash/br ]] && \
  source ~/.config/broot/launcher/bash/br

# ─────────────────────────────────────────────────────────────
#  zsh-autosuggestions — ghost-text from history (→ to accept)
# ─────────────────────────────────────────────────────────────
[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ─────────────────────────────────────────────────────────────
#  zsh-syntax-highlighting — must be sourced LAST among plugins
# ─────────────────────────────────────────────────────────────
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ─────────────────────────────────────────────────────────────
#  ROS 2 Jazzy
# ─────────────────────────────────────────────────────────────
[ -f /opt/ros/jazzy/setup.zsh ] && source /opt/ros/jazzy/setup.zsh

# ─────────────────────────────────────────────────────────────
#  ROS 2 Humble (if also installed, otherwise skip)
# ─────────────────────────────────────────────────────────────
[ -f /opt/ros/humble/setup.zsh ] && source /opt/ros/humble/setup.zsh

# export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
# export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
# export ROS_DOMAIN_ID=1
# export CYCLONEDDS_URI=/home/fanyang1/cyclonedds_ros2.xml

# ─────────────────────────────────────────────────────────────
#  Starship prompt (must be last, before conda)
# ─────────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
EOF

echo ""
echo "── Copying Starship config ─────────────────────────────"
# Write Starship prompt configuration file.
# 写入 Starship 提示符配置文件。
mkdir -p ~/.config
cat > ~/.config/starship.toml << 'STARSHIP_EOF'
"$schema" = 'https://starship.rs/config-schema.json'

format = """
[╭─](bold 240) $directory$git_branch$git_status$python$nodejs$rust $time
[╰─❯](bold green) """

right_format = "$cmd_duration$status"

[directory]
style = "bold cyan"
truncation_length = 4
truncate_to_repo = true

[git_branch]
symbol = " "
style = "bold magenta"
format = "[$symbol$branch]($style) "

[git_status]
style = "bold red"
format = '([\[$all_status$ahead_behind\]]($style) )'
conflicted = "⚡"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
modified = "!${count}"
untracked = "?${count}"
staged = "+${count}"
deleted = "✘${count}"

[time]
disabled = false
format = "[$time]($style)"
style = "bold 240"
time_format = "%H:%M"

[cmd_duration]
min_time = 2_000
format = "[ $duration](bold yellow)"

[status]
disabled = false
format = "[$symbol$status]($style) "
symbol = "✘ "
style = "bold red"
not_executable_symbol = "🔒 "
not_found_symbol = "🔍 "

[python]
symbol = " "
style = "bold yellow"
format = '[$symbol$pyenv_prefix($version)(\($virtualenv\))]($style) '

[nodejs]
symbol = " "
style = "bold green"
format = "[$symbol($version)]($style) "

[rust]
symbol = " "
style = "bold red"
format = "[$symbol($version)]($style) "
STARSHIP_EOF
echo "✓ Starship config written"

# echo ""
# echo "── Conda (init for zsh) ──────────────────────────────────"
# # If anaconda3 exists, append init block without running `conda init zsh`
# # to avoid rewriting user zshrc unexpectedly.
# # 若检测到 anaconda3，则追加初始化片段；不直接执行 `conda init zsh`，
# # 以避免其改写整份 zshrc。
# # if [ -d "$HOME/anaconda3" ]; then
# #   # Append conda init block directly (avoids conda init zsh clobbering .zshrc)
# #   cat >> ~/.zshrc << 'CONDA_EOF'
#
# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$("$HOME/anaconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "$HOME/anaconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="$HOME/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<
# CONDA_EOF
#   echo "✓ Conda initialized for zsh"
# else
#   echo "⚠ anaconda3 not found at ~/anaconda3, skipping conda init"
# fi

echo ""
echo "─────────────────────────────────────────────────────────"
# Final reminders: shell switch and font setting may require manual actions.
# 收尾提示：切换 shell 与字体设置需要用户手动完成。
echo "  Done!"
echo ""
echo "  Next steps:"
echo "  1. Log out and back in (or run: zsh) to use Zsh"
echo "  2. Set terminal font to: JetBrainsMono Nerd Font"
echo "  3. Run: source ~/.zshrc"
echo "─────────────────────────────────────────────────────────"
