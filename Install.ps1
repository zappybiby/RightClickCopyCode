<#
.SYNOPSIS
    Installs or uninstalls the “Copy Code” Explorer context-menu entry.

.DESCRIPTION
    • -Install    – Build CopyCode.exe, add the registry keys.  
    • -Uninstall  – Remove the registry keys (and optionally the files).  
    • -Help       – Show this help.  
      With no parameters the script drops into an interactive menu.

    MUST BE RUN AS ADMINISTRATOR.
#>

#Requires -RunAsAdministrator
[CmdletBinding(DefaultParameterSetName = 'Interactive', SupportsShouldProcess)]
param(
    [Parameter(ParameterSetName = 'Install')]
    [switch]$Install,

    [Parameter(ParameterSetName = 'Uninstall')]
    [switch]$Uninstall,

    [Parameter(ParameterSetName = 'Help')]
    [switch]$Help,

    [switch]$Quiet  # suppress confirmations
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ────────────────────────  helpers  ─────────────────────────
function Confirm-Action {
    param([string]$Message,[string]$Default = 'Y')
    if ($Quiet) { return $true }
    $prompt = if ($Default -eq 'Y') { '(Y/n)' } else { '(y/N)' }
    while ($true) {
        $resp = Read-Host "$Message $prompt"
        if ([string]::IsNullOrWhiteSpace($resp)) { $resp = $Default }
        if ($resp -match '^[YyNn]$') { return $resp -match '^[Yy]$' }
    }
}

# ────────────────────────  paths / consts  ──────────────────
$Here             = $PSScriptRoot
$Ps1              = Join-Path $Here 'CopyCode.ps1'
$Exe              = Join-Path $Here 'CopyCode.exe'
$ProgramFilesRoot = [IO.Path]::GetFullPath('C:\Program Files')
$HereFull         = [IO.Path]::GetFullPath($Here)
$RegRelPath       = '*\shell\CopyCode'

# ────────────────────────  registry helpers  ────────────────
function Get-ClassesRoot64 {
    # pre-determine the view to avoid the inline if/else parse issue
    $view = if ([Environment]::Is64BitOperatingSystem) {
        [Microsoft.Win32.RegistryView]::Registry64
    } else {
        [Microsoft.Win32.RegistryView]::Default
    }
    [Microsoft.Win32.RegistryKey]::OpenBaseKey(
        [Microsoft.Win32.RegistryHive]::ClassesRoot,
        $view
    )
}

function Set-ContextMenuEntry {
    param([string]$ExePath)
    $cmd = '"{0}" "%1"' -f $ExePath
    $root = Get-ClassesRoot64
    try { $root.DeleteSubKeyTree($RegRelPath, $false) } catch { }

    $copyKey = $root.CreateSubKey($RegRelPath, $true)
    $copyKey.SetValue('',    'Copy code',          'String')
    $copyKey.SetValue('Icon','imageres.dll,-5302', 'String')

    $cmdKey  = $copyKey.CreateSubKey('command', $true)
    $cmdKey.SetValue('', $cmd, 'String')

    $cmdKey.Close(); $copyKey.Close(); $root.Close()
}

function Remove-ContextMenuEntry {
    $root = Get-ClassesRoot64
    try { $root.DeleteSubKeyTree($RegRelPath, $false) } catch { }
    $root.Close()
}

# ────────────────────────  PS2EXE check  ────────────────────
function Ensure-PS2EXE {
    if (Get-Command Invoke-PS2EXE -ErrorAction SilentlyContinue) { return }
    if (-not (Confirm-Action "The 'PS2EXE' module is required but not found. Install it now?" 'Y')) {
        throw 'Cannot continue without PS2EXE.'
    }
    Write-Host 'Installing PS2EXE…'
    Install-Module PS2EXE -Scope CurrentUser -Force -ErrorAction Stop
    Import-Module  PS2EXE -ErrorAction Stop
}

# ────────────────────────  core actions  ───────────────────
function Do-Install {
    if (-not ($HereFull.TrimEnd('\').ToLower().StartsWith($ProgramFilesRoot.ToLower()))) {
        Write-Warning 'Recommended install location is under "C:\Program Files" for tamper protection.'
        if (-not (Confirm-Action 'Continue installation outside Program Files?' 'N')) { return }
    }
    if (-not (Test-Path $Ps1)) { throw "CopyCode.ps1 not found in $Here." }

    Ensure-PS2EXE

    Write-Host 'Compiling CopyCode.ps1 → CopyCode.exe…'
    Invoke-PS2EXE -InputFile $Ps1 -OutputFile $Exe -NoConsole
    if (-not (Test-Path $Exe)) { throw 'Compilation failed.' }

    Set-ContextMenuEntry -ExePath $Exe
    Write-Host 'Registry updated (PowerShell provider).'

    Write-Host 'Installation complete. You may need to restart Explorer or log off/on to see the new menu.'
}

function Do-Uninstall {
    Remove-ContextMenuEntry
    Write-Host 'Registry entry removed.'
    if (Confirm-Action 'Delete CopyCode files as well?' 'N') {
        Remove-Item -Path $Exe,$Ps1 -Force -ErrorAction SilentlyContinue
        Write-Host 'Files deleted.'
    }
    Write-Host 'Uninstall finished.'
}

# ────────────────────────  interactive menu  ───────────────
function Run-Interactive {
    Write-Host 'Copy Code Installer' -ForegroundColor Cyan
    Write-Host '[I] Install (default)'
    Write-Host '[U] Uninstall'
    Write-Host '[Q] Quit'
    switch ((Read-Host 'Choose an option').ToUpper()) {
        'U' { Do-Uninstall }
        'Q' { return }
        default { Do-Install }
    }
}

# ────────────────────────  entry point  ────────────────────
if ($Help) { Get-Help -Detailed $MyInvocation.MyCommand.Definition; exit }

switch ($PsCmdlet.ParameterSetName) {
    'Install'     { Do-Install }
    'Uninstall'   { Do-Uninstall }
    'Interactive' { Run-Interactive }
}
