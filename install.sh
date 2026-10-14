#!/usr/bin/env bash
# ===========================================================================
#  ~/terminal dotfiles 安装脚本
#  作用: 把仓库内的配置文件软链接到 $HOME（已存在的同名文件会先备份）
#  用法: bash ~/terminal/install.sh
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
    echo "  链接: ~/$2 -> ~/terminal/$1"
}

echo "==> 创建软链接"
link zsh/.zshrc                      .zshrc
link starship/.config/starship.toml  .config/starship.toml
link git/.gitconfig                  .gitconfig
link tmux/.tmux.conf                 .tmux.conf
link bat/.config/bat/config          .config/bat/config

echo
echo "✔ 安装完成"
echo "  - 立即体验:    exec zsh"
echo "  - 设为默认:    chsh -s /usr/bin/zsh   (需要输入登录密码)"
echo "  - tmux 已运行的会话: tmux source-file ~/.tmux.conf"
