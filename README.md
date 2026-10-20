# ~/terminal — 终端美化 dotfiles

面向 **Rust / C++ / Python** 开发 + **Git** 工作流的终端配置，两端共用一套 gruvbox 视觉与别名习惯：

- **SSH 远程端**（Rocky Linux 9）：zsh + oh-my-zsh + tmux（本文档主体）
- **Windows 本机**（WezTerm + PowerShell 7）：见 [windows/README.md](windows/README.md)

## 组件一览

| 组件 | 作用 | 安装位置 |
|---|---|---|
| zsh + oh-my-zsh | Shell 本体及插件框架 | `/usr/bin/zsh`, `~/.oh-my-zsh` |
| zsh-autosuggestions / syntax-highlighting | 灰色历史建议（`→` 接受）、命令语法高亮 | omz 插件目录 |
| starship | 提示符（gruvbox-rainbow 配色） | `~/.local/bin/starship` |
| fzf | `Ctrl+R` 历史 / `Ctrl+T` 文件 / `Alt+C` 目录 模糊搜索 | dnf |
| zoxide | `z 目录关键词` 智能跳转 | dnf |
| eza | `ls` 替代（图标 + git 状态列） | `~/.local/bin/eza` |
| bat | `cat` 替代（语法高亮） | dnf |
| fd / ripgrep | 快速找文件 / 找内容 | dnf |
| git-delta | `git diff` 彩色并排显示 | dnf |
| tmux | 会话复用 + gruvbox 状态栏 | dnf |

## 目录结构（stow 风格）

```
~/terminal-config/
├── install.sh                     # 一键建立软链接（换机器时直接跑）
├── README.md
├── zsh/.zshrc                     # -> ~/.zshrc
├── starship/.config/starship.toml # -> ~/.config/starship.toml
├── git/.gitconfig                 # -> ~/.gitconfig（本机私有项走 ~/.gitconfig.local）
├── tmux/.tmux.conf                # -> ~/.tmux.conf
├── bat/.config/bat/config         # -> ~/.config/bat/config
├── cargo/.cargo/config.toml       # -> ~/.cargo/config.toml（rsproxy 镜像）
└── windows/                       # Windows 本机 (WezTerm + PowerShell 7)
    ├── install.ps1                # 一键安装 / 修复加载器
    ├── wezterm/.config/wezterm/wezterm.lua
    └── pwsh/Microsoft.PowerShell_profile.ps1
```

所有配置通过软链接生效：**直接改 `~/terminal-config` 里的文件即可**，改完 `reload` 重载 zsh（tmux 用 `前缀+r`）。
本机私有项（git 身份/凭据、额外 PATH 等）放 `~/.gitconfig.local`、`~/.zshrc.local`，不进仓库。

## 日常使用

### 别名速查

| 分类 | 别名 | 含义 |
|---|---|---|
| 文件 | `ls` `ll` `la` `lt` `ltt` | eza 列表 / 长格式 / 含隐藏 / 树形2层 / 树形3层 |
| 文件 | `cat` `catn` | bat 高亮 / 带行号 |
| Rust | `c` `cr` `cb` `cbr` `ck` `ct` `cf` `cl` `ca` `cu` | cargo / run / build / build --release / check / test / fmt / clippy / add / update |
| C++ | `mk` `cmk` `cmkr` `cmb` | make -j / cmake -B build / Release 配置 / 构建 |
| Python | `py` `pip` `venv` `act` `deact` | python3 / pip3 / 建 .venv / 激活 / 退出 |
| Git | `git s` `git d` `git l` `git la` `git last` `git p` `git pl` | status / diff / 图形日志 / 全部日志 / 最近一次提交 / push / pull --rebase |
| 其他 | `reload` `path` `ports` `z 关键词` | 重载配置 / 查看 PATH / 监听端口 / zoxide 跳转 |

### 快捷键

- **fzf**：`Ctrl+R` 搜历史命令，`Ctrl+T` 搜文件（带预览），`Alt+C` 跳目录
- **zsh**：`→` 或 `End` 接受灰色建议
- **tmux**（前缀 `Ctrl+B`）：
  - `|` / `-` 竖切 / 横切面板，`h/j/k/l` 切换面板
  - `H/J/K/L` 调整面板大小，`r` 重载配置

### tmux 常用

```bash
tmux           # 新建会话
tmux a         # 恢复上次会话（断线不丢）
tmux ls        # 列出会话
```

## 换机器 / 重装

> 仓库克隆到哪都行（本机为 `~/terminal-config`），install.sh 按实际路径建链接。

```bash
# 1. 系统包
#   Rocky / Fedora:
sudo dnf install -y zsh tmux fzf ripgrep fd-find bat git-delta zoxide stow
#   Ubuntu / Debian:
sudo apt install -y zsh tmux fzf ripgrep fd-find bat git-delta zoxide stow

# 2. 用户级工具（GitHub 加速下载）
curl -sL "https://ghfast.top/https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-musl.tar.gz" | tar xz -C ~/.local/bin starship
curl -sL "https://ghfast.top/https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-musl.tar.gz" | tar xz -C ~/.local/bin ./eza

# 3. oh-my-zsh + 插件（gitee 镜像）
git clone --depth 1 https://gitee.com/mirrors/oh-my-zsh.git ~/.oh-my-zsh
git clone --depth 1 https://gitee.com/mirrors/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone --depth 1 https://gitee.com/mirrors/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# 4. rustup（走 rsproxy 代理；已有 rustup 的机器跳过）
export RUSTUP_DIST_SERVER=https://rsproxy.cn
export RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly

# 5. 软链接（含 cargo rsproxy 镜像、rustup 补全；Ubuntu 会自动补 fd/bat 用户级软链）
bash ~/terminal-config/install.sh
chsh -s /usr/bin/zsh
```

### rustup / cargo 镜像（rsproxy）说明

- `~/.zshrc` 导出 `RUSTUP_DIST_SERVER` / `RUSTUP_UPDATE_ROOT`，rustup 下载工具链走 rsproxy；
- `~/.cargo/config.toml` 由本仓库软链接提供（crates.io 源替换为 rsproxy 稀疏索引）；
- 若机器上已有旧式 `~/.cargo/config`（无扩展名，cargo 优先读它），`install.sh` 会自动备份并让位给 `config.toml`；
- 默认工具链在 rustup 安装时指定（本机为 `nightly`），补全文件由 `install.sh` 生成。

## Windows 本机（WezTerm + PowerShell 7）

与远程端同款 gruvbox（starship / bat / git 配置共用本仓库文件），一键装齐：

```powershell
pwsh -File E:\local-repos\terminal-config\windows\install.ps1
```

组件清单、快捷键（WezTerm 前缀键 `Ctrl+B`，与 tmux 一致）、别名、维护说明见 [windows/README.md](windows/README.md)。

## 本地终端要求

- 本机 SSH 客户端终端需使用 **Nerd Font** 字体（如 JetBrainsMono Nerd Font、FiraCode Nerd Font、Maple Mono NF），否则图标字符会显示为方块。
- 建议开启真彩色（Windows Terminal / iTerm2 / WezTerm 默认支持）。

## 升级与回滚

- 升级 starship / eza：重新执行上面第 2 步的下载命令即可。
- 回滚：删掉软链接，把 `~/*.bak-*` 备份恢复即可。
