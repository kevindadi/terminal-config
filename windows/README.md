# Windows 终端美化 — WezTerm + PowerShell 7

与 Linux 端（`../README.md`）共用一套 gruvbox 视觉与别名习惯，面向 Rust / C++ / Python + Git 工作流。

## 组件清单

| 组件 | 作用 | 安装方式 |
|---|---|---|
| WezTerm | 终端模拟器 | 已安装（`winget install WezTerm.WezTerm`） |
| JetBrainsMono Nerd Font | 图标字体（不装会显示方块） | `DEVCOM.JetBrainsMonoNerdFont` |
| PowerShell 7 | Shell | `Microsoft.PowerShell` |
| starship | 提示符（gruvbox-rainbow） | `Starship.Starship` |
| PSReadLine | 灰色历史建议（≈ zsh-autosuggestions）+ 语法高亮 | pwsh 内置，配置在本仓库 profile |
| PSFzf + fzf | `Ctrl+R` 历史 / `Ctrl+T` 文件模糊搜索 | PSGallery 模块 + `junegunn.fzf` |
| zoxide | `z 关键词` 智能跳转 | `ajeetdsouza.zoxide` |
| eza | `ls` 替代（图标 + git 状态列） | `eza-community.eza` |
| bat | `cat` 替代（语法高亮） | `sharkdp.bat` |
| fd / ripgrep | 快速找文件 / 找内容 | `sharkdp.fd` / `BurntSushi.ripgrep.MSVC` |
| git-delta | `git diff` 彩色并排显示 | `dandavison.delta` |

## 目录结构与生效方式

Windows 默认不允许普通用户建软链接（需开发者模式/管理员），因此采用**加载器**方案：

```
windows/
├── install.ps1                           # 一键安装（幂等，可反复执行）
├── README.md                             # 本文档
├── wezterm/.config/wezterm/wezterm.lua   # WezTerm 主配置
└── pwsh/Microsoft.PowerShell_profile.ps1 # PowerShell 7 主配置
```

安装后各配置的映射关系：

| 目标位置 | 机制 |
|---|---|
| `WEZTERM_CONFIG_FILE`（用户环境变量） | 直接指向 `windows/wezterm/.config/wezterm/wezterm.lua` |
| `$PROFILE`（`Documents\PowerShell\...`） | 生成的加载器：dot-source 仓库 profile + 设置 `TERMINAL_CONFIG_REPO` |
| `~\.gitconfig` | 生成的 shim：`include` 仓库 `git/.gitconfig`，并覆盖 Windows 专属项 |
| starship / bat 配置 | profile 中设置 `STARSHIP_CONFIG` / `BAT_CONFIG_PATH` 指向仓库文件 |

**与 Linux 端共用的文件**（改一处两端同时生效）：`starship/.config/starship.toml`、`bat/.config/bat/config`、`git/.gitconfig`。
Windows 专属差异放在 `~/.gitconfig` shim 里（目前只有 `core.editor = code --wait`）。

## 安装

```powershell
pwsh -File E:\local-repos\terminal-config\windows\install.ps1
```

- 装完**重开一个 WezTerm 窗口**生效。
- 换机器 / 重装：克隆仓库后执行同一条命令即可（已装的包会自动跳过）。
- 已被覆盖的原文件会自动备份为 `*.bak-时间戳`。

## 快捷键

### WezTerm（前缀键 `Ctrl+B`，与 tmux 一致）

| 按键 | 作用 |
|---|---|
| `前缀 + \|` / `前缀 + -` | 竖切 / 横切面板 |
| `前缀 + h/j/k/l` | 切换面板 |
| `前缀 + H/J/K/L` | 调整面板大小 |
| `前缀 + z` | 当前面板最大化 / 还原 |
| `前缀 + c` / `n` / `p` / `x` | 新建标签页 / 下一个 / 上一个 / 关闭面板 |
| `前缀 + [` | 复制模式（vi 键位，`q` 退出） |
| `前缀 + s` | 连接菜单（SSH 直连：`rocky` / ssh config 主机） |
| `前缀 + r` | 重载配置 |
| `Ctrl+Shift+空格` | 启动菜单（PowerShell 7 / 5.1 / CMD） |
| `Ctrl+=` / `Ctrl+-` / `Ctrl+0` | 字号放大 / 缩小 / 复位 |

### PowerShell（PSReadLine）

| 按键 | 作用 |
|---|---|
| `→` | 接受灰色历史建议（InlineView） |
| `↑` / `↓` | 按前缀搜索历史 |
| `Ctrl+R` / `Ctrl+T` | fzf 搜历史命令 / 搜文件 |
| `Tab` | 补全菜单（可上下选择） |
| `z 关键词` | zoxide 跳转目录 |

## SSH 直连（内置 SSH 域）

WezTerm 内置 SSH 客户端，不用另开 ssh 命令；已配置好 `rocky` 域（`kevin@192.168.0.118`），并自动读取 `~/.ssh/config` 中已有的主机。

- `wezterm connect rocky` —— 新窗口直连服务器
- 前缀键 `Ctrl+B` 再按 `s` —— 弹出连接菜单（`rocky` + ssh config 自动发现的主机）
- 在已开窗口中新增标签：`wezterm cli spawn --domain-name rocky`

当前为**普通 SSH 模式**（`multiplexing = 'None'`），断线即断，会话保持沿用服务器上的 tmux（`tmux a`）。若以后想要"断线重连恢复现场"（WezTerm 原生会话），需在服务器安装与客户端同版本的 wezterm 二进制，并把域配置改为 `multiplexing = 'WezTerm'`（`wezterm.lua` 里有注释说明）。

## 别名速查（与 Linux 端一致的部分）

| 分类 | 别名 | 含义 |
|---|---|---|
| 文件 | `ls` `ll` `la` `lt` `ltt` | eza 列表 / 长格式 / 含隐藏 / 树形2层 / 树形3层 |
| 文件 | `cat` `catn` | bat 高亮 / 带行号 |
| Rust | `c` `cr` `cb` `cbr` `ck` `ct` `cf` `cl` `ca` `cu` | cargo / run / build / build --release / check / test / fmt / clippy / add / update |
| C++ | `mk` `cmk` `cmkr` `cmb` | make -j / cmake -B build / Release 配置 / 构建（需自装 make/cmake） |
| Python | `py` `pip` `venv` `act` `deact` | python / python -m pip / 建 .venv / 激活 / 退出 |
| Git | `git s` `git d` `git l` `git la` `git last` `git p` `git pl` | status / diff / 图形日志 / 全部日志 / 最近一次提交 / push / pull --rebase |
| 其他 | `reload` `path` `ports` `which` | 重载配置 / 查看 PATH / 监听端口 / 查命令路径 |

> Git 别名来自共用的 `git/.gitconfig`。Windows 上与 Linux 的差异：venv 在 `.venv\Scripts\`；`mk/cmk` 系列需要自行安装 make/cmake 后才可用。

## 维护

- **改配置**：直接改仓库文件（WezTerm 自动重载或 `前缀+r`；PowerShell 执行 `reload`）。
- **改全局 git 设置**：改仓库 `git/.gitconfig`；仅 Windows 的覆盖项改 `~/.gitconfig` shim。
- **私有覆盖（不入库）**：`~/.pwshrc.local.ps1`。
- **升级工具**：`winget upgrade <包名>`；starship / eza 等升级后无需改配置。
- **重跑安装脚本**：可随时重复执行，用于修复加载器/环境变量。
