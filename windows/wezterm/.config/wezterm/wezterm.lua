-- ===========================================================================
--  terminal-config (Windows) — WezTerm 主配置 (gruvbox)
--  仓库路径: terminal-config/windows/wezterm/.config/wezterm/wezterm.lua
--  生效方式: 环境变量 WEZTERM_CONFIG_FILE 指向本文件 (由 windows/install.ps1 设置)
--  重载配置: 前缀键 Ctrl+B 之后按 r
-- ===========================================================================

local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- ---------------------------------------------------------------------------
-- 1. 程序与启动
-- ---------------------------------------------------------------------------
config.default_prog = { 'pwsh.exe', '-NoLogo' }   -- 默认 Shell: PowerShell 7

-- 启动菜单: Ctrl+Shift+空格 呼出
config.launch_menu = {
    { label = 'PowerShell 7',       args = { 'pwsh.exe', '-NoLogo' } },
    { label = 'Windows PowerShell', args = { 'powershell.exe', '-NoLogo' } },
    { label = 'CMD',                args = { 'cmd.exe' } },
    -- WSL 用户可启用: { label = 'WSL', args = { 'wsl.exe', '--cd', '~' } },
}

-- ---------------------------------------------------------------------------
-- 2. 字体 (需 Nerd Font, install.ps1 已装 JetBrainsMono Nerd Font)
-- ---------------------------------------------------------------------------
config.font = wezterm.font_with_fallback {
    'JetBrainsMono Nerd Font',
    'FiraCode Nerd Font',
    'CaskaydiaCove Nerd Font',
}
config.font_size = 11.5
config.use_dead_keys = false   -- 中文输入场景: ` 和 ~ 直接输入, 不做组合键

-- ---------------------------------------------------------------------------
-- 3. gruvbox dark 配色
-- ---------------------------------------------------------------------------
config.colors = {
    foreground     = '#ebdbb2',
    background     = '#282828',
    cursor_bg      = '#ebdbb2',
    cursor_fg      = '#282828',
    cursor_border  = '#ebdbb2',
    selection_bg   = '#83a598',
    selection_fg   = '#282828',
    scrollbar_thumb = '#504945',
    split          = '#504945',   -- 面板分隔线
    ansi    = { '#282828', '#cc241d', '#98971a', '#d79921', '#458588', '#b16286', '#689d6a', '#a89984' },
    brights = { '#928374', '#fb4934', '#b8bb26', '#fabd2f', '#83a598', '#d3869b', '#8ec07c', '#ebdbb2' },

    tab_bar = {
        background = '#282828',
        active_tab         = { bg_color = '#d79921', fg_color = '#282828' },
        inactive_tab       = { bg_color = '#3c3836', fg_color = '#a89984' },
        inactive_tab_hover = { bg_color = '#504945', fg_color = '#ebdbb2' },
        new_tab            = { bg_color = '#282828', fg_color = '#928374' },
        new_tab_hover      = { bg_color = '#3c3836', fg_color = '#ebdbb2' },
    },
}

config.window_frame = {
    active_titlebar_bg   = '#3c3836',
    inactive_titlebar_bg = '#282828',
    active_titlebar_fg   = '#ebdbb2',
    inactive_titlebar_fg = '#928374',
}

-- ---------------------------------------------------------------------------
-- 4. 窗口 / 外观
-- ---------------------------------------------------------------------------
config.initial_cols = 120
config.initial_rows = 32
config.window_padding = { left = 8, right = 8, top = 6, bottom = 6 }
config.window_background_opacity = 0.97    -- 想要完全不透明改成 1.0
config.scrollback_lines = 50000            -- 与 tmux history-limit 一致
config.default_cursor_style = 'SteadyBlock'
config.inactive_pane_hsb = { saturation = 0.75, brightness = 0.7 }  -- 未聚焦面板变暗
config.audible_bell = 'Disabled'
config.check_for_updates = false           -- 关闭自动更新检查 (网络原因)
config.automatically_reload_config = true  -- 编辑后自动重载; 手动: 前缀键 + r

-- ---------------------------------------------------------------------------
-- 5. 快捷键 (仿 tmux: 前缀键 Ctrl+B)
-- ---------------------------------------------------------------------------
config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
    -- 面板: | 竖切 / - 横切 / hjkl 切换 / HJKL 调大小 / z 最大化
    { key = '|',  mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = '\\', mods = 'LEADER',       action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = '-',  mods = 'LEADER',       action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },
    { key = 'h',  mods = 'LEADER', action = act.ActivatePaneDirection 'Left'  },
    { key = 'j',  mods = 'LEADER', action = act.ActivatePaneDirection 'Down'  },
    { key = 'k',  mods = 'LEADER', action = act.ActivatePaneDirection 'Up'    },
    { key = 'l',  mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
    { key = 'H',  mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Left', 5 }  },
    { key = 'J',  mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Down', 5 }  },
    { key = 'K',  mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Up', 5 }    },
    { key = 'L',  mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },
    { key = 'z',  mods = 'LEADER', action = act.TogglePaneZoomState },
    { key = 'x',  mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },

    -- 标签页 (对应 tmux 的窗口)
    { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
    { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },

    -- 其他
    { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },   -- 重载配置
    { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },      -- 复制模式 (vi 键位, q 退出)
    { key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|TABS' } },
    { key = 'Space', mods = 'CTRL|SHIFT', action = act.ShowLauncherArgs { flags = 'FUZZY|LAUNCH_MENU_ITEMS' } },

    -- 字号缩放
    { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
    { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
    { key = '0', mods = 'CTRL', action = act.ResetFontSize },
}

return config
