# ===========================================================================
#  terminal-config (Windows) — PowerShell 7 主配置 (Rust / C++ / Python)
#  加载方式: $PROFILE 里的加载器 dot-source 本文件, 并设置 $env:TERMINAL_CONFIG_REPO
#  文档:     terminal-config/windows/README.md
# ===========================================================================

# ---------------------------------------------------------------------------
# 0. 定位仓库 (starship / bat 共用配置在仓库里)
# ---------------------------------------------------------------------------
$repoRoot = $env:TERMINAL_CONFIG_REPO
if (-not $repoRoot -or -not (Test-Path $repoRoot)) {
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

# ---------------------------------------------------------------------------
# 1. 环境变量
# ---------------------------------------------------------------------------
$env:EDITOR         = 'code --wait'
$env:STARSHIP_CONFIG = Join-Path $repoRoot 'starship\.config\starship.toml'
$env:BAT_CONFIG_PATH = Join-Path $repoRoot 'bat\.config\bat\config'

# fzf (Ctrl+R 历史 / Ctrl+T 文件)
$env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git --exclude target --exclude node_modules'
$env:FZF_CTRL_T_COMMAND  = $env:FZF_DEFAULT_COMMAND
$env:FZF_ALT_C_COMMAND   = 'fd --type d --hidden --exclude .git --exclude target --exclude node_modules'
$env:FZF_DEFAULT_OPTS    = '--height=50% --layout=reverse --border=rounded --info=inline --color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:#ebdbb2,prompt:#fabd2f,hl+:#fabd2f'
$env:FZF_CTRL_T_OPTS     = "--preview 'bat --style=numbers --color=always --line-range=:300 {}'"
$env:FZF_ALT_C_OPTS      = "--preview 'eza --tree --level=1 --color=always --icons=always {}'"

# ---------------------------------------------------------------------------
# 2. PSReadLine (历史预测 ≈ zsh-autosuggestions; 配色 gruvbox ≈ syntax-highlighting)
# ---------------------------------------------------------------------------
Set-PSReadLineOption -EditMode Emacs              # 与 zsh 习惯一致 (Ctrl+A/E 行首行尾)
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -MaximumHistoryCount 100000
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -AddToHistoryHandler { param($line) -not $line.StartsWith(' ') }  # 空格开头的命令不记历史

try {
    Set-PSReadLineOption -PredictionSource History      # 灰色历史建议, → 接受
    Set-PSReadLineOption -PredictionViewStyle InlineView
} catch { }

try {
    Set-PSReadLineOption -Colors @{
        ContinuationPrompt = '#fabd2f'
        Default            = '#ebdbb2'
        Comment            = '#928374'
        Keyword            = '#fb4934'
        String             = '#b8bb26'
        Operator           = '#fb4934'
        Variable           = '#83a598'
        Command            = '#8ec07c'
        Parameter          = '#fabd2f'
        Type               = '#fabd2f'
        Number             = '#d3869b'
        Member             = '#83a598'
        Emphasis           = '#fabd2f'
        Error              = '#fb4934'
        Selection          = '#504945'
        InlinePrediction   = '#665c54'
        ListPrediction     = '#928374'
    }
} catch {
    Set-PSReadLineOption -Colors @{ Default = '#ebdbb2'; Command = '#8ec07c'; Parameter = '#fabd2f'; String = '#b8bb26'; Comment = '#928374' }
}
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete            # 补全菜单 (≈ zsh menu select)
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# ---------------------------------------------------------------------------
# 3. starship 提示符 (gruvbox-rainbow, 配置与 Linux 共用)
# ---------------------------------------------------------------------------
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# ---------------------------------------------------------------------------
# 4. zoxide 智能跳转 (z 目录名)
# ---------------------------------------------------------------------------
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# ---------------------------------------------------------------------------
# 5. fzf 键位 (Ctrl+R 历史, Ctrl+T 文件; 需 PSFzf 模块)
# ---------------------------------------------------------------------------
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# ---------------------------------------------------------------------------
# 6. 别名
# ---------------------------------------------------------------------------
# --- 基础 ---
function reload { . $PROFILE; Write-Host '✔ 配置已重载' }
function path   { $env:PATH -split ';' | Where-Object { $_ } }
function ports  {
    Get-NetTCPConnection -State Listen | Sort-Object LocalPort |
        Select-Object LocalAddress, LocalPort, OwningProcess,
            @{ n = 'Process'; e = { (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName } }
}
if (-not (Get-Command which -ErrorAction SilentlyContinue)) {
    Set-Alias which Get-Command
}

# --- eza 替代 ls ---
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    function ls  { eza --icons=always --group-directories-first @args }
    function l   { eza --icons=always --group-directories-first @args }
    function ll  { eza -l  --icons=always --group-directories-first --git --time-style=long-iso @args }
    function la  { eza -la --icons=always --group-directories-first --git --time-style=long-iso @args }
    function lt  { eza --tree --level=2 --icons=always --group-directories-first @args }
    function ltt { eza --tree --level=3 --icons=always --group-directories-first @args }
}

# --- bat 替代 cat ---
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function cat  { bat --style=plain --paging=never @args }
    function catn { bat --style=numbers,header --paging=never @args }
}

# --- Rust (cargo) ---
function c   { cargo @args }
function cr  { cargo run @args }
function cb  { cargo build @args }
function cbr { cargo build --release @args }
function ck  { cargo check @args }
function ct  { cargo test @args }
function cf  { cargo fmt @args }
function cl  { cargo clippy --all-targets @args }
function ca  { cargo add @args }
function cu  { cargo update @args }

# --- C / C++ ---
if (Get-Command make -ErrorAction SilentlyContinue) {
    function mk { make -j$([Environment]::ProcessorCount) @args }
}
if (Get-Command cmake -ErrorAction SilentlyContinue) {
    function cmk  { cmake -B build @args }
    function cmkr { cmake -B build -DCMAKE_BUILD_TYPE=Release @args }
    function cmb  { cmake --build build -j $([Environment]::ProcessorCount) @args }
}

# --- Python ---
function py   { python @args }
function pip  { python -m pip @args }
function venv { python -m venv .venv @args }

# 激活当前目录的 .venv
function act {
    if (Test-Path .venv\Scripts\Activate.ps1) {
        . .venv\Scripts\Activate.ps1
        Write-Host "✔ .venv 已激活 ($(python --version 2>&1))"
    } else {
        Write-Host '✘ 当前目录没有 .venv（可用 venv 命令创建）'
    }
}
# 退出 venv
function deact {
    if (Get-Command deactivate -ErrorAction SilentlyContinue) { deactivate; Write-Host '✔ 已退出 venv' }
    else { Write-Host '✘ 没有激活中的 venv' }
}

# ---------------------------------------------------------------------------
# 7. 本地私有覆盖 (可选, 不纳入版本管理)
# ---------------------------------------------------------------------------
$localProfile = Join-Path $HOME '.pwshrc.local.ps1'
if (Test-Path $localProfile) { . $localProfile }
