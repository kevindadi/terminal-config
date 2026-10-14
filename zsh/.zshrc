# ===========================================================================
#  ~/terminal dotfiles — zsh 主配置 (Rust / C++ / Python)
#  软链接: ~/.zshrc -> ~/terminal/zsh/.zshrc
#  文档:   ~/terminal/README.md
# ===========================================================================

# ---------------------------------------------------------------------------
# 1. 环境变量（沿用原有 bash 环境）
# ---------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin"
export OTAWA_INSTALL_DIR="$HOME/otawa-install"
export PATH="$PATH:$OTAWA_INSTALL_DIR/bin"
export PATH="$HOME/.opencode/bin:$PATH"
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
export EDITOR=vim VISUAL=vim
export LESSCHARSET=utf-8

# opam (OCaml)
test -r "$HOME/.opam/opam-init/init.zsh" && source "$HOME/.opam/opam-init/init.zsh" >/dev/null 2>&1

# ---------------------------------------------------------------------------
# 2. 补全系统（rustup/cargo 补全 + 体验优化）
# ---------------------------------------------------------------------------
fpath=("$HOME/.local/share/zsh/site-functions" $fpath)

command -v dircolors >/dev/null 2>&1 && eval "$(dircolors -b)"

zstyle ':completion:*' menu select                          # 补全菜单可上下选择
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # 补全忽略大小写
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# ---------------------------------------------------------------------------
# 3. oh-my-zsh + 插件
# ---------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""                          # 提示符交给 starship
zstyle ':omz:update' mode disabled    # 网络原因关闭自动更新提示
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source "$ZSH/oh-my-zsh.sh"

# ---------------------------------------------------------------------------
# 4. 历史与交互
# ---------------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_VERIFY EXTENDED_HISTORY
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS INTERACTIVE_COMMENTS NO_FLOW_CONTROL
unsetopt BEEP

# 终端按键：Ctrl+←/→ 按词移动，Home/End
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# ---------------------------------------------------------------------------
# 5. Starship 提示符 (gruvbox-rainbow)
# ---------------------------------------------------------------------------
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ---------------------------------------------------------------------------
# 6. fzf 模糊搜索 (Ctrl+R 历史，Ctrl+T 找文件，Alt+C 跳目录)
# ---------------------------------------------------------------------------
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git --exclude target --exclude node_modules'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git --exclude target --exclude node_modules'
export FZF_DEFAULT_OPTS='--height=50% --layout=reverse --border=rounded --info=inline --color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:#ebdbb2,prompt:#fabd2f,hl+:#fabd2f'
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range=:300 {} 2>/dev/null'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=1 --color=always --icons=always {} 2>/dev/null'"
if command -v fzf >/dev/null 2>&1 && [ -f /usr/share/fzf/shell/key-bindings.zsh ]; then
    source /usr/share/fzf/shell/key-bindings.zsh
fi

# ---------------------------------------------------------------------------
# 7. zoxide 智能跳转（z 目录名）
# ---------------------------------------------------------------------------
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# ---------------------------------------------------------------------------
# 8. 别名
# ---------------------------------------------------------------------------
# --- 基础 ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias reload='source ~/.zshrc && echo "✔ 配置已重载"'
alias path='print -l ${(s.:.)PATH}'
alias ports='ss -tulpn'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# --- eza 替代 ls ---
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons=always --group-directories-first'
    alias l='eza --icons=always --group-directories-first'
    alias ll='eza -l --icons=always --group-directories-first --git --time-style=long-iso'
    alias la='eza -la --icons=always --group-directories-first --git --time-style=long-iso'
    alias lt='eza --tree --level=2 --icons=always --group-directories-first'
    alias ltt='eza --tree --level=3 --icons=always --group-directories-first'
fi

# --- bat 替代 cat ---
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --style=plain --paging=never'
    alias catn='bat --style=numbers,header --paging=never'
fi

alias grep='grep --color=auto'

# --- Rust (cargo) ---
alias c='cargo'
alias cr='cargo run'
alias cb='cargo build'
alias cbr='cargo build --release'
alias ck='cargo check'
alias ct='cargo test'
alias cf='cargo fmt'
alias cl='cargo clippy --all-targets'
alias ca='cargo add'
alias cu='cargo update'

# --- C / C++ ---
alias mk='make -j$(nproc)'
alias cmk='cmake -B build'
alias cmkr='cmake -B build -DCMAKE_BUILD_TYPE=Release'
alias cmb='cmake --build build -j$(nproc)'

# --- Python ---
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv .venv'

# 激活当前目录的 .venv
act() {
    if [ -f .venv/bin/activate ]; then
        source .venv/bin/activate
        echo "✔ .venv 已激活 ($(python --version 2>&1 | awk '{print $2}'))"
    else
        echo "✘ 当前目录没有 .venv（可用 venv 命令创建）"
    fi
}
# 退出 venv
deact() { deactivate 2>/dev/null && echo "✔ 已退出 venv" || echo "✘ 没有激活中的 venv" }

# ---------------------------------------------------------------------------
# 9. 语法高亮 / 自动建议 配色 (gruvbox)
# ---------------------------------------------------------------------------
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_STYLES[default]='fg=#ebdbb2'
ZSH_HIGHLIGHT_STYLES[command]='fg=#8ec07c,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#8ec07c'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[function]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[path]='fg=#83a598'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#d3869b'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#fb4934'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#fb4934'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#d3869b'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#fb4934,bold,underline'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#928374,italic'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#fabd2f'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#fabd2f'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#fabd2f'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#fabd2f'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#83a598'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#83a598'
ZSH_HIGHLIGHT_STYLES[brackets]='fg=#a89984,bold'
ZSH_HIGHLIGHT_STYLES[cursor]='bg=#665c54'

# 自动建议（灰色历史提示，→ 接受）
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#665c54'

# ---------------------------------------------------------------------------
# 10. 本地私有覆盖（可选，不纳入版本管理）
# ---------------------------------------------------------------------------
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
