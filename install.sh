#!/usr/bin/env bash
# ===========================================================================
#  ~/terminal-config dotfiles 安装脚本
#  作用: 把仓库内的配置文件软链接到 $HOME（已存在的同名文件会先备份）
#  用法: bash ~/terminal-config/install.sh
# ===========================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"

link() {  # link <仓库内路径> <$HOME 相对路径>
    local src="$REPO/$1" dst="$HOME/$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "$dst.bak-$TS"
        echo "  备份: ~/$2 -> ~/$2.bak-$TS"
    fi
    ln -sfn "$src" "$dst"
    echo "  链接: ~/$2 -> $REPO/$1"
}

# 旧式 ~/.cargo/config（无扩展名）优先级高于 config.toml，先备份让位
if [ -f "$HOME/.cargo/config" ] && [ ! -L "$HOME/.cargo/config" ]; then
    mv "$HOME/.cargo/config" "$HOME/.cargo/config.bak-$TS"
    echo "  备份: ~/.cargo/config -> ~/.cargo/config.bak-$TS (旧式文件名会覆盖 config.toml)"
fi

echo "==> 创建软链接"
link zsh/.zshrc                      .zshrc
link starship/.config/starship.toml  .config/starship.toml
link git/.gitconfig                  .gitconfig
link tmux/.tmux.conf                 .tmux.conf
link bat/.config/bat/config          .config/bat/config
link cargo/.cargo/config.toml        .cargo/config.toml

echo "==> 系统差异兼容 (Ubuntu/Debian 的 fd-find / bat 二进制名不同)"
mkdir -p "$HOME/.local/bin"
if command -v fdfind >/dev/null 2>&1; then
    ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
    echo "  链接: ~/.local/bin/fd -> $(command -v fdfind)"
fi
if command -v batcat >/dev/null 2>&1; then
    ln -sfn "$(command -v batcat)" "$HOME/.local/bin/bat"
    echo "  链接: ~/.local/bin/bat -> $(command -v batcat)"
fi

echo "==> rustup zsh 补全"
if command -v rustup >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/share/zsh/site-functions"
    rustup completions zsh        > "$HOME/.local/share/zsh/site-functions/_rustup" 2>/dev/null || echo "  (rustup 补全失败，跳过)"
    rustup completions zsh cargo  > "$HOME/.local/share/zsh/site-functions/_cargo"  2>/dev/null || echo "  (cargo 补全失败，跳过)"
    echo "  写入: ~/.local/share/zsh/site-functions/{_rustup,_cargo}"
fi

echo
echo "✔ 安装完成"
echo "  - 立即体验:    exec zsh"
echo "  - 设为默认:    chsh -s /usr/bin/zsh   (需要输入登录密码)"
echo "  - tmux 已运行的会话: tmux source-file ~/.tmux.conf"
