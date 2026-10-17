# ===========================================================================
#  terminal-config (Windows) installer
#  - winget: PowerShell 7, starship, eza, bat, fd, ripgrep, delta, zoxide, fzf,
#    JetBrainsMono Nerd Font
#  - PSGallery: PSFzf module
#  - generates the pwsh $PROFILE loader
#  - sets WEZTERM_CONFIG_FILE (user env var) -> repo wezterm.lua
#  - generates ~/.gitconfig shim (include repo git/.gitconfig + Windows overrides)
#
#  Usage: pwsh -File windows\install.ps1            (or powershell, both work)
#         pwsh -File windows\install.ps1 -NoPackages   (skip winget step)
# ===========================================================================
param([switch]$NoPackages)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot      # windows/ -> repo root
$TS   = Get-Date -Format 'yyyyMMdd-HHmmss'

function Info($msg) { Write-Host "  $msg" }

function Write-Loader($path, $content) {
    $dir = Split-Path -Parent $path
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    if (Test-Path $path) {
        $old = Get-Content $path -Raw -ErrorAction SilentlyContinue
        if ($old -notmatch 'terminal-config') {
            Move-Item $path "$path.bak-$TS"
            Info "backup: $path -> $path.bak-$TS"
        }
    }
    # UTF-8 without BOM (works from both Windows PowerShell 5.1 and pwsh 7)
    [System.IO.File]::WriteAllText($path, $content)
    Info "write:  $path"
}

# ---------------------------------------------------------------------------
# 1. winget packages
# ---------------------------------------------------------------------------
$packages = @(
    @{ Id = 'Microsoft.PowerShell';         Name = 'PowerShell 7' },
    @{ Id = 'Starship.Starship';            Name = 'starship' },
    @{ Id = 'eza-community.eza';            Name = 'eza' },
    @{ Id = 'sharkdp.bat';                  Name = 'bat' },
    @{ Id = 'sharkdp.fd';                   Name = 'fd' },
    @{ Id = 'BurntSushi.ripgrep.MSVC';      Name = 'ripgrep' },
    @{ Id = 'dandavison.delta';             Name = 'git-delta' },
    @{ Id = 'ajeetdsouza.zoxide';           Name = 'zoxide' },
    @{ Id = 'junegunn.fzf';                 Name = 'fzf' },
    @{ Id = 'DEVCOM.JetBrainsMonoNerdFont'; Name = 'JetBrainsMono Nerd Font' }
)

if (-not $NoPackages) {
    Write-Host '==> winget packages'
    foreach ($p in $packages) {
        $listed = winget list --id $p.Id --exact --accept-source-agreements 2>$null | Out-String
        if ($listed -match [regex]::Escape($p.Id)) { Info "skip:    $($p.Name) (already installed)"; continue }
        Write-Host "  install: $($p.Name) [$($p.Id)]"
        winget install --id $p.Id --exact --silent --accept-package-agreements --accept-source-agreements | Out-Null
        if ($LASTEXITCODE -ne 0) { Write-Host "  WARN: winget exit code $LASTEXITCODE for $($p.Id)" }
    }
    # refresh PATH for the remainder of this session
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

# ---------------------------------------------------------------------------
# 2. PowerShell module: PSFzf  (Ctrl+R / Ctrl+T chords for fzf)
# ---------------------------------------------------------------------------
Write-Host '==> PowerShell module: PSFzf'
$pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
if (-not $pwsh) { throw 'pwsh not found - install PowerShell 7 first (or run without -NoPackages)' }
$hasPSFzf = & $pwsh.Source -NoProfile -Command "if (Get-Module -ListAvailable PSFzf) { 'yes' } else { 'no' }"
if ($hasPSFzf -ne 'yes') {
    & $pwsh.Source -NoProfile -Command "try { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue; Install-PackageProvider -Name NuGet -Force -Scope CurrentUser -ErrorAction SilentlyContinue | Out-Null; Install-Module PSFzf -Scope CurrentUser -Force -AllowClobber } catch { Write-Host ('WARN: PSFzf install failed: ' + `$_.Exception.Message) }"
} else { Info 'skip:    PSFzf (already installed)' }

# ---------------------------------------------------------------------------
# 3. pwsh $PROFILE loader (dot-sources the repo profile)
# ---------------------------------------------------------------------------
Write-Host '==> pwsh profile loader'
$profilePath = (& $pwsh.Source -NoProfile -Command '$PROFILE') | Select-Object -First 1
$loader = @"
# terminal-config auto-generated loader - do not edit (managed by windows/install.ps1)
`$env:TERMINAL_CONFIG_REPO = '$repo'
. '$repo\windows\pwsh\Microsoft.PowerShell_profile.ps1'
"@
Write-Loader $profilePath $loader

# ---------------------------------------------------------------------------
# 4. WezTerm config (user env var -> repo wezterm.lua)
# ---------------------------------------------------------------------------
Write-Host '==> WezTerm config'
$wezConfig = Join-Path $repo 'windows\wezterm\.config\wezterm\wezterm.lua'
if (-not (Test-Path $wezConfig)) { throw "config not found: $wezConfig" }
[Environment]::SetEnvironmentVariable('WEZTERM_CONFIG_FILE', $wezConfig, 'User')
$env:WEZTERM_CONFIG_FILE = $wezConfig
Info "WEZTERM_CONFIG_FILE (user) = $wezConfig"

# ---------------------------------------------------------------------------
# 5. ~/.gitconfig shim (include shared config + Windows overrides)
# ---------------------------------------------------------------------------
Write-Host '==> gitconfig shim'
$gitInclude = (Join-Path $repo 'git\.gitconfig') -replace '\\', '/'
$gitShimPath = Join-Path $HOME '.gitconfig'
$shim = @"
# terminal-config auto-generated shim (managed by windows/install.ps1)
# edit global settings in the repo file: git/.gitconfig
[include]
	path = $gitInclude
[core]
	editor = code --wait
"@
Write-Loader $gitShimPath $shim

# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '==> done'
Info 'open a NEW WezTerm window / pwsh session to apply'
Info 'verify: pwsh -NoLogo -Command "starship --version; git config --get core.editor"'
