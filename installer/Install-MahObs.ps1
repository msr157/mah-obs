#Requires -Version 5.1
<#
.SYNOPSIS
  Installs Mayank After Hours OBS Suite: multi-rtmp + mah-mobile-cam plugins + chat docks + loved layout lock.
.NOTES
  OBS must be fully quit before running.
#>
$ErrorActionPreference = 'Stop'
$Root = Resolve-Path (Join-Path $PSScriptRoot '..')

Write-Host '=== MAH OBS Suite installer ===' -ForegroundColor Cyan
Write-Host "Root: $Root"

if (Get-Process obs64 -ErrorAction SilentlyContinue) {
  Write-Host 'Quit OBS completely first (File → Exit), then run again.' -ForegroundColor Yellow
  exit 1
}

$obsAppData = Join-Path $env:APPDATA 'obs-studio'
$userIni = Join-Path $obsAppData 'user.ini'
if (-not (Test-Path $userIni)) { throw "OBS user.ini not found at $userIni — open OBS once, then quit, then re-run." }

# Backup
$bak = Join-Path $obsAppData ("user.ini.bak-mah-install-{0:yyyyMMddHHmmss}" -f (Get-Date))
Copy-Item $userIni $bak -Force
Write-Host "Backup: $bak"

# 1) Multi-RTMP plugin
$installer = Get-ChildItem (Join-Path $Root 'tools') -Filter '*Installer.exe' | Select-Object -First 1
if ($installer) {
  Write-Host "Running multi-rtmp installer: $($installer.Name)"
  Start-Process -FilePath $installer.FullName -Wait
} else {
  Write-Host 'No installer.exe in tools/ — install obs-multi-rtmp manually, then re-run for docks/layout.' -ForegroundColor Yellow
}

# 1b) MAH Mobile Camera plugin (when built/staged locally)
$obsRoot = Join-Path ${env:ProgramFiles} 'obs-studio'
$pluginBin = Join-Path $obsRoot 'obs-plugins\64bit'
$pluginData = Join-Path $obsRoot 'data\obs-plugins\mah-mobile-cam'

function Install-MahMobileCamFrom([string]$stageRoot) {
  if (-not (Test-Path $stageRoot)) { return $false }
  $dll = Get-ChildItem -Path $stageRoot -Recurse -Filter 'mah-mobile-cam.dll' -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $dll) { return $false }

  if (-not (Test-Path $pluginBin)) {
    Write-Host "OBS plugin folder not found ($pluginBin) — install stock OBS first." -ForegroundColor Yellow
    return $false
  }

  New-Item -ItemType Directory -Force -Path $pluginBin, $pluginData | Out-Null
  Copy-Item $dll.FullName (Join-Path $pluginBin 'mah-mobile-cam.dll') -Force

  $dataSrc = Get-ChildItem -Path $stageRoot -Recurse -Directory -Filter 'data' -ErrorAction SilentlyContinue |
    Where-Object { Test-Path (Join-Path $_.FullName 'locale') } |
    Select-Object -First 1
  if ($dataSrc) {
    Copy-Item (Join-Path $dataSrc.FullName '*') $pluginData -Recurse -Force
  }

  Write-Host "Installed mah-mobile-cam from $stageRoot" -ForegroundColor Green
  return $true
}

$camRoot = Join-Path $Root 'plugins\mah-mobile-cam'
$camInstalled = $false
foreach ($subdir in @('release', 'dist')) {
  if (Install-MahMobileCamFrom (Join-Path $camRoot $subdir)) { $camInstalled = $true; break }
}
if (-not $camInstalled) {
  Write-Host 'No mah-mobile-cam.dll under plugins/mah-mobile-cam/release or dist — build plugin or copy DLL manually.' -ForegroundColor Yellow
}

# 2) Copy help dock HTML to stable path
$dockDir = Join-Path $env:USERPROFILE 'Documents\MayankAfterHours\obs-docks'
New-Item -ItemType Directory -Force -Path $dockDir | Out-Null
Copy-Item (Join-Path $Root 'docks\mah-multichat-help.html') (Join-Path $dockDir 'mah-multichat-help.html') -Force
$helpUrl = ('file:///' + ((Join-Path $dockDir 'mah-multichat-help.html') -replace '\\', '/'))

# 3) Apply ExtraBrowserDocks + SideDocks + Lock + DockState from preset
$preset = Get-Content (Join-Path $Root 'presets\layout-loved.json') -Raw | ConvertFrom-Json
$docks = @(
  @{ title = 'MAH Multichat Help'; url = $helpUrl },
  @{ title = 'Twitch Chat'; url = 'https://www.twitch.tv/popout/mayank_raghuvanshi/chat?popout=' },
  @{ title = 'Kick Chat'; url = 'https://kick.com/popout/mayank-raghuvanshi/chat' },
  @{ title = 'YouTube Chat'; url = 'https://www.youtube.com/signin?next=https%3A%2F%2Fwww.youtube.com%2F' }
) | ConvertTo-Json -Compress

$ini = Get-Content $userIni -Raw
function Set-IniKey([string]$text, [string]$key, [string]$value) {
  if ($text -match "(?m)^$key=") {
    return [regex]::Replace($text, "(?m)^$key=.*$", "$key=$value")
  }
  if ($text -match '(?m)^\[BasicWindow\]') {
    return [regex]::Replace($text, '(?m)^(\[BasicWindow\])', "`$1`r`n$key=$value")
  }
  return $text + "`r`n$key=$value`r`n"
}

$ini = Set-IniKey $ini 'ExtraBrowserDocks' $docks
$ini = Set-IniKey $ini 'SideDocks' 'true'
$ini = Set-IniKey $ini 'DocksLocked' 'true'
if ($preset.DockState) { $ini = Set-IniKey $ini 'DockState' $preset.DockState }
if ($preset.geometry) { $ini = Set-IniKey $ini 'geometry' $preset.geometry }

[System.IO.File]::WriteAllText($userIni, $ini)
Write-Host 'Applied docks + loved layout + Lock Docks' -ForegroundColor Green

Write-Host ''
Write-Host 'Next:' -ForegroundColor Cyan
Write-Host '  1. Open OBS'
Write-Host '  2. Docks → enable Multiple output (from multi-rtmp)'
Write-Host '  3. Docks → Twitch / Kick / YouTube / MAH Multichat Help'
Write-Host '  4. Add 3 Custom RTMP targets (keys from each dashboard — never paste in chat)'
Write-Host '  5. Add MAH Mobile Camera → open Phone URL on phone → Allow camera'
Write-Host '  6. Keep Docks → Lock Docks ON'
Write-Host ''
Write-Host 'Done.'
