#Requires -Version 5.1
<#PSScriptInfo
.VERSION 2026.11.0001
.GUID c7e4a1b9-3f2d-4e8a-9b6c-5d1e2f3a4b7c
.NAME universal-windows-wallpaper-changer
.AUTHOR Marcin Grygiel
.COMPANYNAME FirstEver.tech
.COPYRIGHT (c) 2026 Marcin Grygiel / FirstEver.tech. All rights reserved.
.TAGS wallpaper bing picsum wallhaven flickr immich pexels pixabay unsplash windows automation
.LICENSEURI https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/LICENSE
.PROJECTURI https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
v2026.11.0001 - Initial release
#>

<#
.SYNOPSIS
    Sets a random, free 4K wallpaper on Windows, once or on a schedule.

.DESCRIPTION
    Downloads a random 4K wallpaper from a free image service (or picks
    one from own folder) and applies it as the Windows desktop
    wallpaper. Runs once, or keeps changing the wallpaper in the
    background with a tray icon (every 1-1440 minutes). Works for the
    current user only. No administrator rights are needed.

    Usage: .\universal-windows-wallpaper-changer.ps1 [options]

    Run without options to open the start screen (wizard or one random
    4K wallpaper from a service that needs no API key).

    SOURCES (-Source)
      Random      Bing, Picsum or Wallhaven at random (default)
      Bing        Bing image archive (no key, no query)
      Picsum      Random photos (no key, no query)
      Wallhaven   Wallpaper search, SFW only (no key, query)
      Photos      Windows Pictures folder (local, in place)
      Folder      Folder given with -Folder (local, in place)
      Flickr      API key needed (Pro), query. EXPERIMENTAL
      Immich      Own server, API key + URL. EXPERIMENTAL
      Pexels      API key needed (new keys paused), query
      Pixabay     API key needed, max 1280px, query
      Unsplash    API key needed, 50 requests/hour, query
      URL         Image link or .txt list of links (-URL)

    If a service supports a query and you give none, a random one of
    Nature, Abstract, Minimalist, Anime or Cyberpunk is used.

    OPTIONS
      -help, -h, -?      Display this help and exit.
      -version, -v       Display the tool version and exit.
      -wizard            Step-by-step setup wizard.
      -source <name>     Image source (see above). Default: Random.
      -query <text>      Search phrase, e.g. "nature winter".
      -folder <path>     Folder used by -Source Folder.
      -url <link|file>   Image link, or a .txt list (file or link).
      -minwidth <px>     Minimum image width. Default: 3840 (4K).
      -minpixels <n>     Minimum width x height. Default: 0 (off).
      -minsize <size>    Minimum file size, e.g. 500K, 1M. Default: 0.
      -quality <1-100>   JPEG quality for services that convert.
      -format <jpg|png>  Output format for services that convert.
      -orientation <o>   landscape | portrait | squarish.
      -maxattempts <n>   Images to try before failing (1-20). Default: 5.
      -dir <path>        Where downloaded wallpapers are stored.
      -keep <n>          Keep the last n downloaded files (default 20,
                         0 = keep all).
      -keepcurrentonly   Keep only the current wallpaper.
      -once              Change the wallpaper once and exit.
      -intervalminutes n Change every n min. (1-1440) in background.
      -profile [name]    Run a saved profile. Default name: default.
      -fresh             Discard the stored list of upcoming images.
      -immichurl <url>   Immich server address, e.g. https://photos.lan

    BACKGROUND MODE
      -background <cmd>  Status | Start | Stop | Pause | Resume
                         Stop also removes the start at sign-in and
                         the background settings.

    API KEYS (stored encrypted for the current Windows user)
      -keys              Show which keys are set.
      -setkey <service>  Enter a key (hidden input).
      -removekey <svc>   Remove all or selected API key. Also clears
                         the user environment variable of that service.
                           ALL       = all keys
                           FLICKR    = FLICKR_API_KEY
                           IMMICH    = IMMICH_API_KEY
                           PEXELS    = PEXELS_API_KEY
                           PIXABAY   = PIXABAY_API_KEY
                           UNSPLASH  = UNSPLASH_ACCESS_KEY
                           WALLHAVEN = WALLHAVEN_API_KEY
      Environment variables override stored keys.
      Keys are never accepted on the command line.
      Example:
        .\universal-windows-wallpaper-changer.ps1 -removekey unsplash

    WINDOWS JPEG QUALITY
      -jpegimportquality <Max|Default>
                         Set Windows import quality to 100% (Max)
                         or restore the default 85% (Default).
      -noprompt          Do not check or ask about the JPEG quality.

    OTHER
      -quiet, -q         No screens, no prompts, no credits. For
                         schedulers and scripts.
      -noupdate          Skip the check for a newer version.
      -skipverify, -s    Skip the script self-hash verification.
      -debug, -d         Print diagnostic messages.

    Files: %LOCALAPPDATA%\UniversalWindowsWallpaperChanger
           (log, state, queue, installed copy for background mode)
           %APPDATA%\UniversalWindowsWallpaperChanger\profiles

.EXAMPLE
    .\universal-windows-wallpaper-changer.ps1
    Opens the start screen.

.EXAMPLE
    .\universal-windows-wallpaper-changer.ps1 -Once
    Sets one random 4K wallpaper from Bing, Picsum or Wallhaven.

.EXAMPLE
    .\universal-windows-wallpaper-changer.ps1 -Source Wallhaven -Query "forest" -IntervalMinutes 30
    Changes the wallpaper every 30 minutes in the background.

.EXAMPLE
    .\universal-windows-wallpaper-changer.ps1 -Profile
    Runs the profile saved from the wizard (name: default).

.EXAMPLE
    .\universal-windows-wallpaper-changer.ps1 -Background Status
    Shows the state of the background changer.

.NOTES
    Author:  Marcin Grygiel / FirstEver.tech
    License: MIT

    This tool is not affiliated with any image provider. Respect the
    licence of every image you keep. Bing images are copyrighted and
    meant for personal use. Flickr and Immich support is experimental.
    Use at your own risk.

.LINK
    https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer
#>

# =============================================
# COMMAND-LINE PARAMETERS - MANUAL PARSING
# =============================================
# To disable partial matching, we do not use param() block.
# Instead we parse $args manually.
$rawArgs = $args

$ValidSources = @('Random','Bing','Picsum','Wallhaven','Photos','Folder','Flickr','Immich','Pexels','Pixabay','Unsplash','URL')
$KeyServiceNames = @('Flickr','Immich','Pexels','Pixabay','Unsplash','Wallhaven')

$switchMap = @{
    '-help' = 'Help'; '-h' = 'Help'; '-?' = 'Help'
    '-version' = 'Version'; '-v' = 'Version'
    '-quiet' = 'Quiet'; '-q' = 'Quiet'
    '-debug' = 'Debug'; '-d' = 'Debug'
    '-skipverify' = 'SkipVerify'; '-s' = 'SkipVerify'
    '-noupdate' = 'NoUpdate'
    '-noprompt' = 'NoPrompt'
    '-wizard' = 'Wizard'
    '-once' = 'Once'
    '-fresh' = 'Fresh'
    '-keepcurrentonly' = 'KeepCurrentOnly'
    '-keys' = 'Keys'
    '-tray' = 'Tray'
}

$valueMap = @{
    '-source' = 'Source'; '-query' = 'Query'; '-folder' = 'Folder'; '-url' = 'URL'
    '-minwidth' = 'MinWidth'; '-minpixels' = 'MinPixels'; '-minsize' = 'MinSize'
    '-maxattempts' = 'MaxAttempts'; '-quality' = 'Quality'; '-format' = 'Format'
    '-orientation' = 'Orientation'; '-dir' = 'Dir'; '-keep' = 'Keep'
    '-intervalminutes' = 'IntervalMinutes'; '-immichurl' = 'ImmichUrl'
    '-setkey' = 'SetKey'; '-removekey' = 'RemoveKey'
    '-background' = 'Background'; '-jpegimportquality' = 'JpegImportQuality'
}

$Flags = @{}
foreach ($f in @('Help','Version','Quiet','Debug','SkipVerify','NoUpdate','NoPrompt','Wizard','Once','Fresh','KeepCurrentOnly','Keys','Tray')) { $Flags[$f] = $false }
$Cli = @{}            # values given explicitly on the command line
$ProfileRequested = $false
$ProfileName = 'default'

function Stop-WithArgError {
    param([string[]]$Lines)
    Write-Host ""
    foreach ($l in $Lines) { Write-Host (" " + $l) }
    Write-Host " Use -help or -h to see available options."
    Write-Host ""
    exit 1
}

function Test-ArgValue {
    # Returns the normalized value or $null when invalid.
    param([string]$Key, [string]$Value)
    switch ($Key) {
        'Source' {
            foreach ($s in $ValidSources) { if ($s -ieq $Value) { return $s } }
            return $null
        }
        'Format' {
            if ($Value -imatch '^(jpg|png)$') { return $Value.ToLowerInvariant() }
            return $null
        }
        'Orientation' {
            if ($Value -imatch '^(landscape|portrait|squarish)$') { return $Value.ToLowerInvariant() }
            return $null
        }
        'Background' {
            foreach ($s in @('Status','Start','Stop','Pause','Resume')) { if ($s -ieq $Value) { return $s } }
            return $null
        }
        'JpegImportQuality' {
            foreach ($s in @('Max','Default')) { if ($s -ieq $Value) { return $s } }
            return $null
        }
        'SetKey' {
            foreach ($s in $KeyServiceNames) { if ($s -ieq $Value) { return $s } }
            if ($Value -ieq 'UNSPLASH_ACCESS_KEY') { return 'Unsplash' }
            foreach ($s in $KeyServiceNames) { if (($s + '_API_KEY') -ieq $Value) { return $s } }
            return $null
        }
        'RemoveKey' {
            foreach ($s in ($KeyServiceNames + 'All')) { if ($s -ieq $Value) { return $s } }
            if ($Value -ieq 'UNSPLASH_ACCESS_KEY') { return 'Unsplash' }
            foreach ($s in $KeyServiceNames) { if (($s + '_API_KEY') -ieq $Value) { return $s } }
            return $null
        }
        'MinWidth'        { if ($Value -match '^\d{1,6}$' -and [int]$Value -ge 320 -and [int]$Value -le 16384) { return [int]$Value }; return $null }
        'MinPixels'       { if ($Value -match '^\d{1,9}$' -and [int64]$Value -le 500000000) { return [int]$Value }; return $null }
        'MaxAttempts'     { if ($Value -match '^\d{1,2}$' -and [int]$Value -ge 1 -and [int]$Value -le 20) { return [int]$Value }; return $null }
        'Quality'         { if ($Value -match '^\d{1,3}$' -and [int]$Value -ge 1 -and [int]$Value -le 100) { return [int]$Value }; return $null }
        'Keep'            { if ($Value -match '^\d{1,6}$' -and [int]$Value -ge 0 -and [int]$Value -le 100000) { return [int]$Value }; return $null }
        'IntervalMinutes' { if ($Value -match '^\d{1,4}$' -and [int]$Value -ge 1 -and [int]$Value -le 1440) { return [int]$Value }; return $null }
        'MinSize'         { if ($Value -match '^\d+(\.\d+)?\s*[KkMm]?[Bb]?$') { return $Value.Trim() }; return $null }
        'URL' {
            $u = $Value.Trim().Trim('"')
            if ($u -match '^https?://\S+$' -or $u -match '(?i)\.txt$') { return $u }
            return $null
        }
        'ImmichUrl'       { if ($Value -match '^https?://\S+$') { return $Value.TrimEnd('/') }; return $null }
        'Query'           { return $Value.Trim() }
        default           { if (-not [string]::IsNullOrWhiteSpace($Value)) { return $Value.Trim() }; return $null }
    }
}

for ($i = 0; $i -lt $rawArgs.Count; $i++) {
    $arg = [string]$rawArgs[$i]
    $lower = $arg.ToLowerInvariant()

    if ($switchMap.ContainsKey($lower)) {
        $Flags[$switchMap[$lower]] = $true
    }
    elseif ($valueMap.ContainsKey($lower)) {
        $key = $valueMap[$lower]
        if ($i + 1 -ge $rawArgs.Count) {
            Stop-WithArgError @("Missing value for parameter: $arg")
        }
        $i++
        $val = Test-ArgValue -Key $key -Value ([string]$rawArgs[$i])
        if ($null -eq $val) {
            Stop-WithArgError @("Invalid value for parameter ${arg}: $($rawArgs[$i])")
        }
        $Cli[$key] = $val
    }
    elseif ($lower -eq '-profile') {
        $ProfileRequested = $true
        if ($i + 1 -lt $rawArgs.Count -and ([string]$rawArgs[$i + 1]) -notmatch '^-') {
            $i++
            $ProfileName = [string]$rawArgs[$i]
        }
    }
    else {
        # Unknown switch or positional argument: same plain message for both
        Stop-WithArgError @("Unknown parameter: $arg")
    }
}

if ($ProfileName -notmatch '^[A-Za-z0-9_-]{1,40}$') {
    Stop-WithArgError @("Invalid profile name: $ProfileName", "Allowed: letters, digits, '_' and '-' (max 40).")
}
if ($Flags.Once -and $Cli.ContainsKey('IntervalMinutes')) {
    Stop-WithArgError @("Parameters -once and -intervalminutes cannot be combined.")
}

[bool]$DebugMode = $Flags.Debug
[bool]$QuietMode = ($Flags.Quiet -or $Flags.Tray)
[bool]$SkipSelfHashVerification = $Flags.SkipVerify

# =============================================
# SCRIPT VERSION
# =============================================
$ScriptVersion = "2026.11.0001"
# =============================================

$DisplayVersion = $ScriptVersion
$ToolName       = "UNIVERSAL WINDOWS WALLPAPER CHANGER"
$ToolFileName   = "universal-windows-wallpaper-changer"

# If help requested, show and exit
if ($Flags.Help) {
    $helpWidth = 80
    try { if ($Host.UI.RawUI.WindowSize.Width -ge 60) { $helpWidth = $Host.UI.RawUI.WindowSize.Width - 1 } } catch { }
    $helpText = Get-Help $MyInvocation.MyCommand.Path | Out-String -Width $helpWidth
    $cut = $helpText.IndexOf('REMARKS')
    if ($cut -ge 0) { $helpText = $helpText.Substring(0, $cut) }
    Write-Host $helpText.TrimEnd()
    Write-Host ""
    Write-Host "REMARKS"
    Write-Host "    To see the examples, type:"
    Write-Host "    Get-Help .\$ToolFileName.ps1 -Examples"
    Write-Host ""
    Write-Host "    For more information, type:"
    Write-Host "    Get-Help .\$ToolFileName.ps1 -Detailed"
    Write-Host ""
    Write-Host "    For technical information, type:"
    Write-Host "    Get-Help .\$ToolFileName.ps1 -Full"
    Write-Host ""
    exit 0
}

# If version requested, show and exit
if ($Flags.Version) {
    Clear-Host
    Write-Host ""
    Write-Host " Universal Windows Wallpaper Changer version $DisplayVersion"
    Write-Host ""
    exit 0
}

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch { }

# =============================================
# CONFIGURATION
# =============================================
$githubRawBase     = "https://raw.githubusercontent.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/main/"
$githubReleaseBase = "https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/releases/download/"
$githubReleasesUrl = "https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer"
$versionFileUrl    = $githubRawBase + "src/$ToolFileName.ver"
$creditsMessageUrl = $githubRawBase + "data/$ToolFileName-credits.txt"
$adsUrl            = $githubRawBase + "data/$ToolFileName-ads.txt"
$UserAgent         = "UniversalWindowsWallpaperChanger/$ScriptVersion"

$script:LocalRoot       = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'UniversalWindowsWallpaperChanger'
$script:RoamRoot        = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'UniversalWindowsWallpaperChanger'
$script:ProfileDir      = Join-Path $script:RoamRoot 'profiles'
$script:InstalledScript = Join-Path $script:LocalRoot "$ToolFileName.ps1"
$script:BgConfigFile    = Join-Path $script:LocalRoot 'background.json'
$script:StateFile       = Join-Path $script:LocalRoot 'state.json'
$script:CmdFile         = Join-Path $script:LocalRoot 'command.txt'
$script:LogFile         = Join-Path $script:LocalRoot 'wallpaper.log'
$script:QueueDir        = Join-Path $script:LocalRoot 'queue'
$script:AppRegPath      = 'HKCU:\Software\FirstEverTech\UniversalWindowsWallpaperChanger'
$script:RunRegPath      = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$script:RunValueName    = 'UniversalWindowsWallpaperChanger'
$script:MutexName       = 'Local\FirstEverTech.UniversalWindowsWallpaperChanger.Tray'
$script:DesktopKey      = 'HKCU:\Control Panel\Desktop'
$script:Quiet           = $QuietMode
$script:NavStartAllowed = $true
$script:HeaderNotice    = $null
$script:HeaderNoticeColor = 'Gray'
$global:ScriptStartTime = Get-Date

$ScriptPath = $null
if ($PSCommandPath) { $ScriptPath = $PSCommandPath }
elseif ($MyInvocation.MyCommand.Path) { $ScriptPath = $MyInvocation.MyCommand.Path }

# =============================================
# VERSION MANAGEMENT FUNCTIONS
# =============================================

function Get-VersionNumber {
    param([string]$Version)
    if ($Version -match '^(\d{4})\.(\d{2})\.(\d+)$') {
        return [int]$matches[3]
    }
    throw "Cannot parse version: $Version"
}

function Compare-Versions {
    param([string]$Version1, [string]$Version2)
    $ver1Num = Get-VersionNumber -Version $Version1
    $ver2Num = Get-VersionNumber -Version $Version2
    if ($ver1Num -eq $ver2Num) { return 0 }
    if ($ver1Num -lt $ver2Num) { return -1 }
    return 1
}

# =============================================
# LOGGING FUNCTIONS
# =============================================

function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] [$Type] $Message"
    try {
        if (-not (Test-Path -LiteralPath $script:LocalRoot)) {
            New-Item -ItemType Directory -Force -Path $script:LocalRoot | Out-Null
        }
        if ((Test-Path -LiteralPath $script:LogFile) -and ((Get-Item -LiteralPath $script:LogFile).Length -gt 524288)) {
            $tail = @(Get-Content -LiteralPath $script:LogFile -Tail 1500)
            Set-Content -LiteralPath $script:LogFile -Value $tail -Encoding UTF8
        }
        Add-Content -LiteralPath $script:LogFile -Value $entry -Encoding UTF8
    } catch { }
}

function Write-DebugMessage {
    param([string]$Message, [string]$Color = "Gray")
    Write-Log -Message $Message -Type "DEBUG"
    if ($DebugMode -and -not $script:Quiet) {
        Write-Host " DEBUG: $Message" -ForegroundColor $Color
    }
}

function Write-Warn {
    # Warning visible in interactive runs, always logged.
    param([string]$Message)
    Write-Log -Message $Message -Type "WARN"
    if (-not $script:Quiet) { Write-Host " WARNING: $Message" -ForegroundColor Yellow }
}

function Hide-Secret {
    param([string]$Text)
    if (-not $Text) { return $Text }
    return ($Text -replace '(?i)((?:api_)?key=)[^&\s]+', '$1***')
}

# =============================================
# COLOR LINE PARSING FUNCTION
# =============================================
function Write-ColorLine {
    param([string]$Line)

    # Get all valid console color names
    $validColors = [Enum]::GetNames([ConsoleColor])

    # Start with the console's current colors
    $currentFg = $Host.UI.RawUI.ForegroundColor
    $currentBg = $Host.UI.RawUI.BackgroundColor

    $segments = @()
    $position = 0
    $length = $Line.Length

    while ($position -lt $length) {
        $openBracket = $Line.IndexOf('[', $position)
        if ($openBracket -eq -1) {
            $text = $Line.Substring($position)
            if ($text) {
                $segments += [PSCustomObject]@{ Text = $text; Foreground = $currentFg; Background = $currentBg }
            }
            break
        }

        if ($openBracket -gt $position) {
            $text = $Line.Substring($position, $openBracket - $position)
            $segments += [PSCustomObject]@{ Text = $text; Foreground = $currentFg; Background = $currentBg }
        }

        $closeBracket = $Line.IndexOf(']', $openBracket)
        if ($closeBracket -eq -1) {
            $text = $Line.Substring($openBracket)
            $segments += [PSCustomObject]@{ Text = $text; Foreground = $currentFg; Background = $currentBg }
            break
        }

        $tagContent = $Line.Substring($openBracket + 1, $closeBracket - $openBracket - 1)

        if ($tagContent -match ',') {
            $colors = $tagContent -split ',' | ForEach-Object { $_.Trim() }
            if ($colors.Count -eq 2 -and ($validColors -contains $colors[0]) -and ($validColors -contains $colors[1])) {
                $currentFg = [ConsoleColor]$colors[0]
                $currentBg = [ConsoleColor]$colors[1]
                $position = $closeBracket + 1
                continue
            }
        }

        if ($validColors -contains $tagContent) {
            $currentFg = [ConsoleColor]$tagContent
            $position = $closeBracket + 1
            continue
        }

        $text = $Line.Substring($openBracket, $closeBracket - $openBracket + 1)
        $segments += [PSCustomObject]@{ Text = $text; Foreground = $currentFg; Background = $currentBg }
        $position = $closeBracket + 1
    }

    foreach ($seg in $segments) {
        Write-Host $seg.Text -NoNewline -ForegroundColor $seg.Foreground -BackgroundColor $seg.Background
    }
    Write-Host ""
}

# =============================================
# PARSE KEY AND URL FROM CREDIT LINE
# =============================================
function Get-KeyAndUrlFromLine {
    param([string]$Line)

    $validColors = [Enum]::GetNames([ConsoleColor])
    $colorPattern = '\[(?:' + (($validColors | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')(?:,(?:' + (($validColors | ForEach-Object { [regex]::Escape($_) }) -join '|') + '))?\]'

    $cleanLine = $Line -replace $colorPattern, ''

    if ($cleanLine -match 'press \[([A-Za-z0-9])\]') {
        $key = $matches[1]
        if ($cleanLine -match '(https?://)?([a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(?:/[^\s]*)?)') {
            $urlCandidate = $matches[0]
            if ($urlCandidate -notmatch '^https?://') {
                $urlCandidate = "https://$urlCandidate"
            }
            return @{ Key = $key; Url = $urlCandidate }
        }
    }
    return $null
}

# =============================================
# CONSOLE / HEADER
# =============================================
function Set-ConsoleSize {
    try {
        $Host.UI.RawUI.BackgroundColor = "Black"
        [console]::WindowWidth  = 75
        [console]::WindowHeight = 58
        [console]::BufferWidth  = [console]::WindowWidth
    } catch { }
}

function Show-Header {
    Clear-Host
    Write-Host "/*************************************************************************" -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "**" -NoNewline -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host ("                  {0}                  " -f $ToolName) -NoNewline -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host "**" -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "** --------------------------------------------------------------------- **" -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "**                                                                       **" -ForegroundColor Gray -BackgroundColor DarkBlue

    $paddedVersion = $DisplayVersion.PadRight(14)
    Write-Host "**" -NoNewline -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "                       Tool Version: $paddedVersion                    " -NoNewline -ForegroundColor Yellow -BackgroundColor DarkBlue
    Write-Host "**" -ForegroundColor Gray -BackgroundColor DarkBlue

    Write-Host "**                                                                       **" -ForegroundColor Gray -BackgroundColor DarkBlue
    $authorText =  "           Author: Marcin Grygiel / GitHub.com/FirstEverTech           "
    $padding = [math]::Floor((69 - $authorText.Length) / 2)
    $spaces = " " * [math]::Max(0, $padding)
    Write-Host "**" -NoNewline -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "$spaces$authorText$spaces" -NoNewline -ForegroundColor Green -BackgroundColor DarkBlue
    $totalLength = $spaces.Length + $authorText.Length + $spaces.Length
    if ($totalLength -lt 69) {
        Write-Host (" " * (69 - $totalLength)) -NoNewline -ForegroundColor Green -BackgroundColor DarkBlue
    }
    Write-Host "**" -ForegroundColor Gray -BackgroundColor DarkBlue

    Write-Host "**                                                                       **" -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "**" -NoNewline -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "           Not affiliated with any image provider.                     " -NoNewline -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "**" -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "**" -NoNewline -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "           Most services require your own API key.                     " -NoNewline -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "**" -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "**" -NoNewline -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "           Use at your own risk.                                       " -NoNewline -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "**" -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "**                                                                       **" -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host "*************************************************************************/" -ForegroundColor Gray -BackgroundColor DarkBlue
    Write-Host ""

    if ($script:HeaderNotice) {
        foreach ($n in @($script:HeaderNotice)) { Write-Host $n -ForegroundColor $script:HeaderNoticeColor }
        Write-Host ""
        $script:HeaderNotice = $null
    }
}

function Show-ScreenTitle {
    param([string]$Title)
    Write-Host (" " + $Title) -ForegroundColor Cyan
    Write-Host (" " + ("=" * $Title.Length)) -ForegroundColor Cyan
}

function Read-YesNo {
    param([string]$Prompt)
    while ($true) {
        $a = (Read-Host " $Prompt [Y/N]").Trim().ToUpper()
        if ($a -eq 'Y') { return $true }
        if ($a -eq 'N') { return $false }
        Write-Host " Invalid input. Please enter Y or N." -ForegroundColor Red
    }
}

function Wait-AnyKey {
    param([string]$Text = " Press any key to continue...")
    Write-Host $Text
    try { $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') } catch { $null = Read-Host }
}

function Exit-WithCredits {
    # [X]: show the credits, then close on any key.
    $script:ExitCode = 0
    Show-FinalCredits
}

function Invoke-Nav {
    # [X] exits (with credits), [S] goes back to the start screen.
    param([string]$Text)
    if ($Text -ieq 'X') { Exit-WithCredits }
    if ($Text -ieq 'S' -and $script:NavStartAllowed) { throw 'UWWC_BACK_TO_START' }
}

function Read-Nav {
    param([string]$Prompt)
    $raw = (Read-Host " $Prompt").Trim()
    Invoke-Nav $raw
    return $raw
}

function Read-Validated {
    # $Validate receives the trimmed text and returns @{ Ok = $bool; Value = ... }.
    param([string]$Prompt, [scriptblock]$Validate, [string]$ErrorText, [string]$Default)
    while ($true) {
        $raw = Read-Nav $Prompt
        if ($raw -eq '' -and $PSBoundParameters.ContainsKey('Default')) { $raw = $Default }
        $res = & $Validate $raw
        if ($res.Ok) { return $res.Value }
        Write-Host " $ErrorText" -ForegroundColor Red
    }
}

# =============================================
# CONFIGURATION MODEL AND PROFILES
# =============================================

$ConfigKeys = @('Source','Query','Folder','URL','ImmichUrl','MinWidth','MinPixels','MinSize',
                'MaxAttempts','Quality','Format','Orientation','Dir','Keep',
                'KeepCurrentOnly','IntervalMinutes')

function Get-PicturesFolder {
    $d = [Environment]::GetFolderPath('MyPictures')
    if ([string]::IsNullOrWhiteSpace($d)) { $d = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'Pictures' }
    if ([string]::IsNullOrWhiteSpace($d)) { $d = [IO.Path]::GetTempPath() }
    return $d
}

function New-DefaultConfig {
    return @{
        Source          = 'Random'
        Query           = ''
        Folder          = ''
        ImmichUrl       = ''
        URL             = ''
        MinWidth        = 3840
        MinPixels       = 0
        MinSize         = '0'
        MaxAttempts     = 5
        Quality         = 95
        Format          = 'jpg'
        Orientation     = 'landscape'
        Dir             = (Join-Path (Get-PicturesFolder) 'Universal Windows Wallpapers')
        Keep            = 20
        KeepCurrentOnly = $false
        IntervalMinutes = 0
    }
}

function Merge-Config {
    # Copies known, valid keys from $Over into $Base. Invalid values are ignored.
    param([hashtable]$Base, $Over)
    if ($null -eq $Over) { return $Base }
    foreach ($k in $ConfigKeys) {
        $has = $false; $val = $null
        if ($Over -is [hashtable]) { if ($Over.ContainsKey($k)) { $has = $true; $val = $Over[$k] } }
        elseif ($Over.PSObject.Properties[$k]) { $has = $true; $val = $Over.$k }
        if (-not $has) { continue }
        if ($k -eq 'KeepCurrentOnly') { $Base[$k] = [bool]$val; continue }
        if ($k -eq 'IntervalMinutes') {
            if ($val -is [string] -and $val -eq '') { continue }
            if ([int]$val -eq 0) { $Base[$k] = 0; continue }
        }
        if ($k -in @('Query','Folder','URL','ImmichUrl') -and [string]::IsNullOrWhiteSpace([string]$val)) { $Base[$k] = ''; continue }
        $norm = Test-ArgValue -Key $k -Value ([string]$val)
        if ($null -ne $norm) { $Base[$k] = $norm }
        else { Write-Log "Ignored invalid value for $k in configuration: $val" 'WARN' }
    }
    return $Base
}

function Test-ProfileName {
    param([string]$Name)
    return ($Name -match '^[A-Za-z0-9_-]{1,40}$')
}

function Get-ProfilePath {
    param([string]$Name)
    return (Join-Path $script:ProfileDir "$Name.json")
}

function Save-ConfigFile {
    param([string]$Path, [hashtable]$Cfg)
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $out = [ordered]@{}
    foreach ($k in $ConfigKeys) { $out[$k] = $Cfg[$k] }
    $tmp = "$Path.tmp"
    ($out | ConvertTo-Json -Depth 3) | Set-Content -LiteralPath $tmp -Encoding UTF8
    Move-Item -LiteralPath $tmp -Destination $Path -Force
}

function Read-ConfigFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    try {
        $o = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
        return $o
    } catch {
        Write-Log "Cannot read $Path : $($_.Exception.Message)" 'ERROR'
        return $null
    }
}

function Get-ProfileList {
    if (-not (Test-Path -LiteralPath $script:ProfileDir)) { return @() }
    return @(Get-ChildItem -LiteralPath $script:ProfileDir -Filter '*.json' -File -ErrorAction SilentlyContinue |
        ForEach-Object { $_.BaseName })
}

function Resolve-RunConfig {
    # defaults < profile (when requested) < command line
    $cfg = New-DefaultConfig
    if ($ProfileRequested) {
        $p = Read-ConfigFile -Path (Get-ProfilePath $ProfileName)
        if ($null -eq $p) {
            Write-Host ""
            Write-Host " Profile not found: $ProfileName" -ForegroundColor Red
            Write-Host " Create it with -wizard (option: save settings as a profile)." -ForegroundColor Gray
            Write-Host ""
            exit 1
        }
        $cfg = Merge-Config -Base $cfg -Over $p
    }
    $cfg = Merge-Config -Base $cfg -Over $Cli
    if ($Flags.KeepCurrentOnly) { $cfg.KeepCurrentOnly = $true }
    if ($Flags.Once) { $cfg.IntervalMinutes = 0 }
    return $cfg
}

function ConvertTo-Bytes {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return [int64]0 }
    $v = $Value.Trim().ToUpperInvariant()
    if ($v -match '^([0-9]+(?:\.[0-9]+)?)\s*([KM]?)B?$') {
        $num  = [double]$Matches[1]
        switch ($Matches[2]) {
            'K' { return [int64]($num * 1000) }
            'M' { return [int64]($num * 1000000) }
            default { return [int64]$num }
        }
    }
    return [int64]0
}

function Format-Bytes {
    param([int64]$B)
    if ($B -le 0) { return 'off' }
    if ($B -lt 1000) { return '{0} B' -f $B }
    if ($B -lt 1000000) { return '{0:0.#} KB' -f ($B / 1000.0) }
    return '{0:0.##} MB' -f ($B / 1000000.0)
}

function Get-ServiceName {
    # Provider name -> display name used in files, logs and screens
    param([string]$Source)
    return $Source
}

function Test-SourceSupportsQuery {
    param([string]$Source)
    return ($Source -in @('Wallhaven','Flickr','Pexels','Pixabay','Unsplash'))
}

function Get-RandomQueryPhrase {
    return (Get-Random -InputObject @('Nature','Abstract','Minimalist','Anime','Cyberpunk'))
}

function Get-CommandParts {
    # The command line parts that reproduce $Cfg (only values that differ from defaults).
    param([hashtable]$Cfg)
    $def = New-DefaultConfig
    $parts = @(".\$ToolFileName.ps1")
    $parts += "-Source $($Cfg.Source)"
    if ($Cfg.Query)  { $parts += ('-Query "{0}"' -f $Cfg.Query) }
    if ($Cfg.Source -eq 'Folder' -and $Cfg.Folder) { $parts += ('-Folder "{0}"' -f $Cfg.Folder) }
    if ($Cfg.Source -eq 'URL' -and $Cfg.URL) { $parts += ('-URL "{0}"' -f $Cfg.URL) }
    if ($Cfg.Source -eq 'Immich' -and $Cfg.ImmichUrl) { $parts += ('-ImmichUrl "{0}"' -f $Cfg.ImmichUrl) }
    if ($Cfg.MinWidth -ne $def.MinWidth) { $parts += "-MinWidth $($Cfg.MinWidth)" }
    if ($Cfg.MinPixels -ne $def.MinPixels) { $parts += "-MinPixels $($Cfg.MinPixels)" }
    if ($Cfg.MinSize -ne $def.MinSize) { $parts += "-MinSize $($Cfg.MinSize)" }
    if ($Cfg.Quality -ne $def.Quality) { $parts += "-Quality $($Cfg.Quality)" }
    if ($Cfg.Format -ne $def.Format) { $parts += "-Format $($Cfg.Format)" }
    if ($Cfg.Orientation -ne $def.Orientation) { $parts += "-Orientation $($Cfg.Orientation)" }
    if ($Cfg.MaxAttempts -ne $def.MaxAttempts) { $parts += "-MaxAttempts $($Cfg.MaxAttempts)" }
    if ($Cfg.Dir -ne $def.Dir) { $parts += ('-Dir "{0}"' -f $Cfg.Dir) }
    if ($Cfg.KeepCurrentOnly) { $parts += '-KeepCurrentOnly' }
    elseif ($Cfg.Keep -ne $def.Keep) { $parts += "-Keep $($Cfg.Keep)" }
    if ($Cfg.IntervalMinutes -gt 0) { $parts += "-IntervalMinutes $($Cfg.IntervalMinutes)" }
    else { $parts += '-Once' }
    return $parts
}

function Build-CommandLine {
    param([hashtable]$Cfg)
    return ((Get-CommandParts $Cfg) -join ' ')
}

# =============================================
# API KEYS (DPAPI, separate registry key)
# =============================================

$KeyServices = [ordered]@{
    Flickr    = @{ Env = 'FLICKR_API_KEY';      Note = 'API key for Pro version'; Color = 'Red';        Required = $true  }
    Immich    = @{ Env = 'IMMICH_API_KEY';      Note = 'Self-hosted server only';          Color = 'DarkYellow'; Required = $true  }
    Pexels    = @{ Env = 'PEXELS_API_KEY';      Note = 'New keys paused';                 Color = 'Red';        Required = $true  }
    Pixabay   = @{ Env = 'PIXABAY_API_KEY';     Note = '';                                 Color = 'Gray';       Required = $true  }
    Unsplash  = @{ Env = 'UNSPLASH_ACCESS_KEY'; Note = '';                                 Color = 'Gray';       Required = $true  }
    Wallhaven = @{ Env = 'WALLHAVEN_API_KEY';   Note = 'Optional, higher limits';          Color = 'DarkYellow'; Required = $false }
}

function ConvertFrom-SecureToPlain {
    param([System.Security.SecureString]$Secure)
    $bstr = [IntPtr]::Zero
    try {
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secure)
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    } finally {
        if ($bstr -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
    }
}

function Get-ApiKeySource {
    # 'Environment' | 'Stored' | $null (never returns the key itself)
    param([string]$Service)
    $envName = $KeyServices[$Service].Env
    if (-not [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($envName))) { return 'Environment' }
    try {
        $v = (Get-ItemProperty -Path (Join-Path $script:AppRegPath 'Keys') -Name $envName -ErrorAction Stop).$envName
        if (-not [string]::IsNullOrWhiteSpace($v)) { return 'Stored' }
    } catch { }
    return $null
}

function Get-ApiKey {
    param([string]$Service)
    $envName = $KeyServices[$Service].Env
    $e = [Environment]::GetEnvironmentVariable($envName)
    if (-not [string]::IsNullOrWhiteSpace($e)) { return $e.Trim() }
    $keysPath = Join-Path $script:AppRegPath 'Keys'
    if (-not (Test-Path -Path $keysPath)) { return $null }
    try {
        $item = Get-ItemProperty -Path $keysPath -Name $envName -ErrorAction SilentlyContinue
        $enc = if ($item) { $item.$envName } else { $null }
        if ([string]::IsNullOrWhiteSpace($enc)) { return $null }
        $secure = ConvertTo-SecureString -String $enc -ErrorAction Stop
        return (ConvertFrom-SecureToPlain $secure).Trim()
    } catch {
        Write-Log "Cannot decrypt stored key for $Service : $($_.Exception.Message)" 'ERROR'
        return $null
    }
}

function Set-ApiKey {
    param([string]$Service, [System.Security.SecureString]$Secure)
    $envName = $KeyServices[$Service].Env
    $plain = (ConvertFrom-SecureToPlain $Secure).Trim()
    if ([string]::IsNullOrWhiteSpace($plain)) { return $false }
    $clean = ConvertTo-SecureString -String $plain -AsPlainText -Force
    $enc = ConvertFrom-SecureString -SecureString $clean       # DPAPI, current user
    $path = Join-Path $script:AppRegPath 'Keys'
    if (-not (Test-Path -Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name $envName -Value $enc -Type String
    return $true
}

function Remove-ApiKey {
    param([string]$Service)
    $envName = $KeyServices[$Service].Env
    $path = Join-Path $script:AppRegPath 'Keys'
    Remove-ItemProperty -Path $path -Name $envName -ErrorAction SilentlyContinue
}

function Get-StoredImmichUrl {
    try { return (Get-ItemProperty -Path $script:AppRegPath -Name 'ImmichUrl' -ErrorAction Stop).ImmichUrl } catch { return '' }
}

function Set-StoredImmichUrl {
    param([string]$Url)
    if (-not (Test-Path -Path $script:AppRegPath)) { New-Item -Path $script:AppRegPath -Force | Out-Null }
    Set-ItemProperty -Path $script:AppRegPath -Name 'ImmichUrl' -Value $Url -Type String
}

function Show-KeyTable {
    Write-Host " SERVICE     ENVIRONMENT VARIABLE   STATUS" -ForegroundColor Gray
    foreach ($svc in $KeyServices.Keys) {
        $info = $KeyServices[$svc]
        $src = Get-ApiKeySource $svc
        Write-Host (" {0,-11} {1,-22} " -f $svc, $info.Env) -NoNewline -ForegroundColor White
        if ($src) {
            $label = if ($src -eq 'Environment') { 'SET (env)   ' } else { 'SET (stored)' }
            Write-Host $label -NoNewline -ForegroundColor Green
        } else {
            Write-Host 'NOT SET     ' -NoNewline -ForegroundColor Red
        }
        if ($info.Note) { Write-Host (" " + $info.Note) -ForegroundColor $info.Color } else { Write-Host "" }
    }
}

function Read-ApiKeyInteractive {
    # Returns $true when a key was stored.
    param([string]$Service)
    $secure = Read-Host " $Service API key" -AsSecureString
    if ($null -eq $secure -or $secure.Length -eq 0) { return $false }
    try {
        return (Set-ApiKey -Service $Service -Secure $secure)
    } catch {
        Write-Host " Could not store the key: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# =============================================
# WINDOWS JPEG IMPORT QUALITY
# HKCU\Control Panel\Desktop\JPEGImportQuality
# =============================================

function Get-JpegImportQuality {
    # $null = value absent (Windows default, 85%), otherwise the stored number.
    try {
        $item = Get-ItemProperty -Path $script:DesktopKey -Name 'JPEGImportQuality' -ErrorAction Stop
        return [int]$item.JPEGImportQuality
    } catch { return $null }
}

function Set-JpegImportQuality {
    param([ValidateSet('Default','Max')][string]$Mode)
    if ($Mode -eq 'Max') {
        Set-ItemProperty -Path $script:DesktopKey -Name 'JPEGImportQuality' -Value 100 -Type DWord
    } else {
        Remove-ItemProperty -Path $script:DesktopKey -Name 'JPEGImportQuality' -ErrorAction SilentlyContinue
    }
}

function Format-JpegImportQuality {
    param($Value)
    if ($null -eq $Value) { return 'default (85%)' }
    return ('{0}%' -f $Value)
}

function Invoke-JpegImportQualityCommand {
    # -JpegImportQuality Default|Max : apply and exit (no wallpaper change).
    $mode = $Cli.JpegImportQuality
    try {
        $before = Get-JpegImportQuality
        Set-JpegImportQuality -Mode $mode
        $after = Get-JpegImportQuality
        Write-Host ''
        Write-Host (' JPEGImportQuality: {0} -> {1}' -f (Format-JpegImportQuality $before), (Format-JpegImportQuality $after))
        if ($mode -eq 'Max' -and $before -eq 100) {
            Write-Host ' Already at maximum - nothing changed.'
        } elseif ($mode -eq 'Default' -and $null -eq $before) {
            Write-Host ' Already at default - nothing changed.'
        } else {
            Write-Host ' Sign out and back in (or restart Windows) and set the wallpaper again.'
        }
        Write-Host ''
        return 0
    } catch {
        Write-Host (' Could not change JPEGImportQuality: {0}' -f $_.Exception.Message) -ForegroundColor Red
        return 1
    }
}

function Test-JpegPrecheckNeeded {
    if ($Flags.NoPrompt -or $script:Quiet) { return $false }
    if ($Cli.ContainsKey('Format') -and $Cli.Format -eq 'png') { return $false }
    if ([Console]::IsInputRedirected) { return $false }
    $q = Get-JpegImportQuality
    if ($null -ne $q -and $q -ge 100) { return $false }
    return $true
}

function Show-JpegPrecheck {
    Show-Header
    $q = Get-JpegImportQuality
    Show-ScreenTitle '[PRE-CHECK] WINDOWS WALLPAPER QUALITY'
    Write-Host ''
    Write-Host ' PATCH AVAILABLE:' -ForegroundColor Yellow
    Write-Host ''
    $current = if ($null -eq $q) { 85 } else { $q }
    Write-Host (' Windows 11 and older recompress JPEG wallpapers to {0}% quality.' -f $current) -ForegroundColor Yellow
    Write-Host ' If you want the best wallpaper quality, change it to 100%.' -ForegroundColor Yellow
    Write-Host ''
    Write-Host ' You can restore the default settings with: -JpegImportQuality Default' -ForegroundColor Gray
    Write-Host ' You can hide this question with: -NoPrompt' -ForegroundColor Gray
    Write-Host ''
    if (Read-YesNo 'Do you want to do this?') {
        try {
            Set-JpegImportQuality -Mode 'Max'
            $script:HeaderNotice = @(
                ' Windows wallpaper quality set to 100%.',
                ' Sign out and back in (or restart Windows), then set the wallpaper again.'
            )
            $script:HeaderNoticeColor = 'Green'
        } catch {
            $script:HeaderNotice = (' Could not set JPEGImportQuality: {0}' -f $_.Exception.Message)
            $script:HeaderNoticeColor = 'Red'
        }
    } else {
        $script:HeaderNotice = ' JPEG quality left unchanged. Use -NoPrompt to stop this question.'
        $script:HeaderNoticeColor = 'Gray'
    }
}

# =============================================
# WEB HELPERS
# =============================================

function Get-WebText {
    param([string]$Url, [int]$TimeoutSec = 10)
    $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec $TimeoutSec -ErrorAction Stop -UserAgent $UserAgent
    if ($r.Content -is [byte[]]) { return [System.Text.Encoding]::UTF8.GetString($r.Content).Trim().TrimStart([char]0xFEFF) }
    return $r.Content.ToString().Trim().TrimStart([char]0xFEFF)
}

function ConvertTo-ArgString {
    param([string[]]$Items)
    $out = foreach ($a in $Items) {
        if ($a -match '[\s"]') { '"' + ($a -replace '"', '\"') + '"' } else { $a }
    }
    return ($out -join ' ')
}

# =============================================
# SCREEN 1: INITIALIZATION AND SECURITY CHECKS
# =============================================

function Show-StartupChecks {
    # Returns $true when GitHub is reachable.
    Show-Header
    Show-ScreenTitle '[STARTUP] INITIALIZATION AND SECURITY CHECKS'

    if ($DebugMode) {
        Write-Host " DEBUG MODE: ENABLED" -ForegroundColor Magenta
    }
    if ($SkipSelfHashVerification) {
        Write-Host "`n SELF-HASH VERIFICATION: DISABLED (Testing Mode)" -ForegroundColor Yellow
    }

    Write-Host ""

    $build = 0
    $netRelease = 0
    $githubOk = $false

    Write-Host " Checking Windows system requirements..." -ForegroundColor Yellow
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $build = [int]$os.BuildNumber

        if ($build -lt 17763) {
            Write-Host " [WARNING] Windows 10 LTSB 2015/2016 detected." -ForegroundColor Red
            Write-Host " TLS 1.2 may not work properly." -ForegroundColor Gray
            Write-Host " Some features may be limited." -ForegroundColor Gray
        } else {
            Write-Host " Windows Build: $build" -ForegroundColor Gray
            Write-Host " Operating system compatibility: PASSED" -ForegroundColor Green
        }
    } catch {
        $build = 17763
        Write-Host " [INFO] Could not determine Windows build." -ForegroundColor Gray
    }
    Write-Host ""

    Write-Host " Checking .NET Framework prerequisites..." -ForegroundColor Yellow
    try {
        $netRelease = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -Name "Release" -ErrorAction Stop
        if ($netRelease -ge 461808) {
            Write-Host " .NET Framework 4.7.2 or newer detected: PASSED" -ForegroundColor Green
        } else {
            Write-Host " [WARNING] .NET Framework older than 4.7.2" -ForegroundColor Red
        }
    } catch {
        Write-Host " [WARNING] .NET Framework 4.7.2+ not found or couldn't be checked" -ForegroundColor Red
        Write-Host " This may affect GitHub connectivity." -ForegroundColor Gray
    }
    Write-Host ""

    Write-Host " Testing GitHub connectivity..." -ForegroundColor Yellow
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $null = Invoke-WebRequest -Uri "https://raw.githubusercontent.com" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-Host " Repository access verification: PASSED" -ForegroundColor Green
        $githubOk = $true
    } catch {
        Write-Host " [WARNING] Cannot reach GitHub servers" -ForegroundColor Red
        Write-Host " Self-hash verification and update check will be skipped." -ForegroundColor Gray
    }
    Write-Host ""

    Write-Host " Pre-check summary..." -ForegroundColor Yellow
    if ($build -lt 17763 -or $netRelease -lt 461808) {
        Write-Host " [IMPORTANT] Some issues were detected." -ForegroundColor Yellow
        Write-Host ""
        Write-Host " If you experience problems:" -ForegroundColor Gray
        Write-Host " 1. For LTSB/LTSC users: Install .NET Framework 4.8" -ForegroundColor Gray
        Write-Host " 2. For GitHub issues: Check firewall/proxy settings" -ForegroundColor Gray
        Write-Host ""

        if (-not (Read-YesNo 'Continue despite warnings?')) {
            Write-Host " Operation cancelled." -ForegroundColor Red
            Wait-AnyKey " Press any key to exit..."
            exit 0
        }
        Write-Host " Continuing with limited functionality..." -ForegroundColor Yellow
        Write-Host ""
    } else {
        Write-Host " All system requirements verified successfully." -ForegroundColor Green
    }
    Write-Host ""
    return $githubOk
}

# =============================================
# SELF-HASH VERIFICATION
# =============================================

function Test-ScriptHash {
    # Returns 'Passed' | 'Skipped' | 'Unavailable' | 'Failed'
    if ($SkipSelfHashVerification) {
        Write-Host " SKIPPED: Self-hash verification disabled (Testing Mode)." -ForegroundColor Yellow
        Write-Host ""
        return 'Skipped'
    }

    Write-Host " Verifying script file integrity..." -ForegroundColor Yellow

    if (Test-GalleryInstall) {
        Write-Host " SKIPPED: Installed from PowerShell Gallery (verified by PowerShellGet)." -ForegroundColor Yellow
        Write-Host ""
        return 'Skipped'
    }

    if (-not $ScriptPath -or -not (Test-Path -LiteralPath $ScriptPath)) {
        Write-Host " [WARNING] Cannot locate the script file for verification." -ForegroundColor Yellow
        Write-Host ""
        return 'Unavailable'
    }
    Write-DebugMessage "Script path: $ScriptPath"

    $currentHash = $null
    for ($try = 1; $try -le 3 -and -not $currentHash; $try++) {
        try { $currentHash = (Get-FileHash -LiteralPath $ScriptPath -Algorithm SHA256).Hash.ToUpper() }
        catch { Start-Sleep -Milliseconds 500 }
    }
    if (-not $currentHash) {
        Write-Host " FAIL: Could not calculate the script hash." -ForegroundColor Red
        return 'Failed'
    }

    $hashFileUrl = "{0}v{1}/{2}-{1}-ps1.sha256" -f $githubReleaseBase, $ScriptVersion, $ToolFileName
    Write-DebugMessage "Downloading hash from: $hashFileUrl"

    try {
        $line = Get-WebText -Url $hashFileUrl
    } catch {
        Write-Host " [WARNING] Could not download the reference hash." -ForegroundColor Yellow
        Write-Host " Verification skipped. Official downloads:" -ForegroundColor Gray
        Write-Host " $githubReleasesUrl" -ForegroundColor Gray
        Write-DebugMessage "Hash download error: $($_.Exception.Message)"
        Write-Host ""
        return 'Unavailable'
    }

    if ($line -notmatch '^([A-Fa-f0-9]{64})(?:\s+\*?(\S+))?$') {
        Write-Host " FAIL: Could not parse the reference hash." -ForegroundColor Red
        return 'Failed'
    }
    $expected = $matches[1].ToUpper()
    Write-DebugMessage "Expected hash: $expected"
    Write-DebugMessage "Current hash:  $currentHash"

    if ($currentHash -eq $expected) {
        Write-Host " Script hash verification: PASSED" -ForegroundColor Green
        Write-Host ""
        return 'Passed'
    }

    Write-Host " FAIL: Script hash verification failed. Hash doesn't match." -ForegroundColor Red
    Write-Host "`n WARNING: The script file may have been modified or corrupted!" -ForegroundColor Red
    Write-Host " Please download it from the official source:" -ForegroundColor Red
    Write-Host " $githubReleasesUrl" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " Source: $expected" -ForegroundColor Green
    Write-Host " Actual: $currentHash" -ForegroundColor Red
    return 'Failed'
}

# =============================================
# UPDATE CHECK AND SELF-UPDATE
# =============================================

function Test-GalleryInstall {
    # $true when this file was installed with Install-Script (PowerShell Gallery).
    if ($null -ne $script:GalleryInstall) { return $script:GalleryInstall }
    $script:GalleryInstall = $false
    if (-not $ScriptPath) { return $false }
    try {
        if (Get-Command Get-InstalledScript -ErrorAction SilentlyContinue) {
            $inst = Get-InstalledScript -Name $ToolFileName -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($inst -and $inst.InstalledLocation) {
                $galleryFile = Join-Path $inst.InstalledLocation "$ToolFileName.ps1"
                if ($galleryFile -ieq $ScriptPath) { $script:GalleryInstall = $true }
            }
        }
    } catch { Write-DebugMessage "Gallery detection error: $($_.Exception.Message)" }
    Write-DebugMessage "PowerShell Gallery install: $($script:GalleryInstall)"
    return $script:GalleryInstall
}

function Get-LatestVersion {
    # Returns the latest published version string or $null.
    if (Test-GalleryInstall) {
        try {
            $found = Find-Script -Name $ToolFileName -Repository PSGallery -ErrorAction Stop | Select-Object -First 1
            $v = [string]$found.Version
            if ($v -match '^\d{4}\.\d{2}\.\d+$') { return $v }
            Write-DebugMessage "Unexpected Gallery version format: $v"
        } catch { Write-DebugMessage "Gallery version check error: $($_.Exception.Message)" }
        return $null
    }
    try {
        $v = Get-WebText -Url $versionFileUrl
        if ($v -match '^\d{4}\.\d{2}\.\d+$') { return $v }
    } catch { Write-DebugMessage "Version check error: $($_.Exception.Message)" }
    return $null
}

function Install-GalleryUpdate {
    param([string]$LatestVersion)
    try {
        Write-Host " Updating version $LatestVersion with Update-Script..." -ForegroundColor Yellow
        Update-Script -Name $ToolFileName -Force -ErrorAction Stop
        Write-Host " Update from PowerShell Gallery: DONE" -ForegroundColor Green

        # Keep the installed copy used by background mode in step.
        if ((Test-Path -LiteralPath $script:InstalledScript) -and ($script:InstalledScript -ne $ScriptPath)) {
            try {
                $wasRunning = Test-TrayRunning
                if ($wasRunning) { Stop-Tray | Out-Null }
                Copy-Item -LiteralPath $ScriptPath -Destination $script:InstalledScript -Force -ErrorAction Stop
                if ($wasRunning) { Start-Tray | Out-Null }
            } catch { Write-DebugMessage "Installed copy not refreshed: $($_.Exception.Message)" }
        }
        Write-Log "Updated to version $LatestVersion (PowerShell Gallery)" 'INFO'
        return $true
    } catch {
        Write-Host " ERROR: Update failed - $($_.Exception.Message)" -ForegroundColor Red
        Write-Host " Try in an elevated PowerShell:" -ForegroundColor Yellow
        Write-Host " Update-Script -Name $ToolFileName -Force" -ForegroundColor Yellow
        return $false
    }
}

function Install-ScriptUpdate {
    param([string]$LatestVersion)

    if (Test-GalleryInstall) { return (Install-GalleryUpdate -LatestVersion $LatestVersion) }

    if (-not $ScriptPath) {
        Write-Host " Cannot update: the script path is unknown." -ForegroundColor Red
        Write-Host " Download it from: $githubReleasesUrl" -ForegroundColor Yellow
        return $false
    }

    $tmp = Join-Path ([IO.Path]::GetTempPath()) ('uwwc_update_' + [guid]::NewGuid().ToString('N') + '.ps1')
    try {
        $base = "{0}v{1}/" -f $githubReleaseBase, $LatestVersion
        Write-Host " Downloading version $LatestVersion..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri ($base + "$ToolFileName.ps1") -OutFile $tmp -UseBasicParsing -TimeoutSec 60 -ErrorAction Stop -UserAgent $UserAgent

        $line = Get-WebText -Url ($base + "$ToolFileName-$LatestVersion-ps1.sha256")
        if ($line -notmatch '^([A-Fa-f0-9]{64})') { throw "Could not parse the reference hash." }
        $expected = $matches[1].ToUpper()
        $actual = (Get-FileHash -LiteralPath $tmp -Algorithm SHA256).Hash.ToUpper()
        if ($actual -ne $expected) {
            Write-Host " FAIL: Hash of the downloaded file does not match." -ForegroundColor Red
            Write-Host " The update was NOT installed." -ForegroundColor Red
            return $false
        }
        Write-Host " Hash verification of the new version: PASSED" -ForegroundColor Green

        try {
            Copy-Item -LiteralPath $tmp -Destination $ScriptPath -Force -ErrorAction Stop
        } catch {
            $alt = Join-Path (Split-Path -Parent $ScriptPath) "$ToolFileName-$LatestVersion.ps1"
            Copy-Item -LiteralPath $tmp -Destination $alt -Force
            Write-Host " Could not overwrite the current file. New version saved as:" -ForegroundColor Yellow
            Write-Host " $alt" -ForegroundColor Yellow
            return $false
        }

        # Keep the installed copy used by background mode in step.
        if ((Test-Path -LiteralPath $script:InstalledScript) -and ($script:InstalledScript -ne $ScriptPath)) {
            try {
                $wasRunning = Test-TrayRunning
                if ($wasRunning) { Stop-Tray | Out-Null }
                Copy-Item -LiteralPath $tmp -Destination $script:InstalledScript -Force -ErrorAction Stop
                if ($wasRunning) { Start-Tray | Out-Null }
            } catch { Write-DebugMessage "Installed copy not refreshed: $($_.Exception.Message)" }
        }
        Write-Log "Updated to version $LatestVersion" 'INFO'
        return $true
    } catch {
        Write-Host " ERROR: Update failed - $($_.Exception.Message)" -ForegroundColor Red
        Write-Host " Download manually from: $githubReleasesUrl" -ForegroundColor Yellow
        return $false
    } finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
}

function Invoke-UpdateCheck {
    Write-Host " Checking for newer version..." -ForegroundColor Yellow
    $latest = Get-LatestVersion
    if (-not $latest) {
        Write-Host " [WARNING] Could not check for updates." -ForegroundColor Yellow
        Write-Host ""
        return
    }
    $cmp = Compare-Versions -Version1 $ScriptVersion -Version2 $latest
    Write-DebugMessage "Current version: $ScriptVersion, latest: $latest, comparison: $cmp"

    if ($cmp -ge 0) {
        if ($cmp -eq 0) { Write-Host " Status: Already on latest version." -ForegroundColor Green }
        else { Write-Host " Status: Current version appears newer than latest." -ForegroundColor Cyan }
        Write-Host ""
        return
    }

    Write-Host " A new version $latest is available (current: $ScriptVersion)." -ForegroundColor Yellow
    Write-Host ""
    if (-not (Read-YesNo 'Download and install it now?')) {
        Write-Host " Continuing with the current version." -ForegroundColor Gray
        Write-Host ""
        return
    }

    if (Install-ScriptUpdate -LatestVersion $latest) {
        Write-Host " Starting the new version and closing this window..." -ForegroundColor Green
        Start-Sleep -Seconds 2
        $argString = ConvertTo-ArgString (@($rawArgs | ForEach-Object { [string]$_ }) + '-NoUpdate')
        Start-Process -FilePath "powershell.exe" -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -NoExit -File "{0}" {1}' -f $ScriptPath, $argString)
        exit 100
    }
    Write-Host " Continuing with the current version." -ForegroundColor Yellow
    Write-Host ""
}

# =============================================
# FINAL CREDITS (interactive single run only)
# =============================================

function Show-FinalCredits {
    param([int]$TimeoutSeconds = 0)
    Show-Header

    Write-Host " THANK YOU FOR USING UNIVERSAL WINDOWS WALLPAPER CHANGER" -ForegroundColor Cyan
    Write-Host " =======================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " I hope you enjoy your new wallpaper." -ForegroundColor Yellow
    Write-Host ""

    $keyActions = @{}

    # Ad links (A-E keys). File format, one per line:  A = https://...
    $cacheBuster = "?t=$(Get-Date -Format 'yyyyMMddHHmmss')"
    try {
        $adsContent = Get-WebText -Url ($adsUrl + $cacheBuster) -TimeoutSec 5
        foreach ($adLine in ($adsContent -split "`r?`n")) {
            if ($adLine -match '^\s*([A-Ea-e])\s*=\s*(https?://\S+)\s*$') {
                $adKey = $matches[1].ToUpper()
                $keyActions[$adKey]           = $matches[2]
                $keyActions[$adKey.ToLower()] = $matches[2]
            }
        }
    } catch { }

    try {
        $lines = (Get-WebText -Url ($creditsMessageUrl + $cacheBuster) -TimeoutSec 5) -split "`r?`n"
    } catch {
        # Fallback embedded credits
        $lines = @(
            "[Magenta]",
            "[Magenta] SUPPORT THIS PROJECT",
            "[Magenta] ====================",
            "",
            " This project is maintained in my free time.",
            " Your support ensures regular updates and compatibility.",
            "",
            " Support options:",
            "",
            "[Green] - Support Patreon:[Yellow] tinyurl.com/fet-patron[Gray] - press [Black,Gray][1][Gray,Black] key",
            "[Green] - Support PayPal: [Yellow] tinyurl.com/fet-paypal[Gray] - press [Black,Gray][2][Gray,Black] key",
            "[Green] - Support Coffee: [Yellow] tinyurl.com/fet-coffee[Gray] - press [Black,Gray][3][Gray,Black] key",
            "[Green] - Support Ko-Fi:  [Yellow] tinyurl.com/fet-mykofi[Gray] - press [Black,Gray][4][Gray,Black] key",
            "[Green] - Support GitHub: [Yellow] tinyurl.com/fet-github[Gray] - press [Black,Gray][5][Gray,Black] key",
            "",
            " If this project helped you, please consider:",
            "",
            "[Green] - Giving it a STAR on GitHub",
            "[Green] - Sharing with friends and colleagues",
            "[Green] - Reporting issues or suggesting features",
            "[Green] - Supporting development financially",
            "",
            "[Magenta]",
            "[Magenta] CAREER OPPORTUNITY",
            "[Magenta] ==================",
            "",
            " I'm currently seeking new challenges where I can apply my expertise",
            " in solving complex IT infrastructure problems. If your organization",
            " struggles with system compatibility, automation, or tooling gaps,",
            " let's discuss how I can help.",
            "",
            " I specialize in Windows deployment, driver automation, hardware",
            " compatibility, infrastructure analysis, and custom IT tooling.",
            "",
            "[Green] - Connect with me:[Yellow] linkedin.com/in/marcin-grygiel[Gray] - press [Black,Gray][L][Gray,Black] key"
        )
    }

    foreach ($line in $lines) {
        Write-ColorLine $line
        $keyInfo = Get-KeyAndUrlFromLine -Line $line
        if ($keyInfo) {
            if ($keyInfo.Key -match '[a-zA-Z]') {
                $keyActions[$keyInfo.Key.ToUpper()] = $keyInfo.Url
                $keyActions[$keyInfo.Key.ToLower()] = $keyInfo.Url
            } else {
                $keyActions[$keyInfo.Key] = $keyInfo.Url
            }
        }
    }

    Write-Host "`n Press " -NoNewline -ForegroundColor Gray
    Write-Host "1" -NoNewline -ForegroundColor Yellow
    Write-Host "=Patreon, " -NoNewline -ForegroundColor Gray
    Write-Host "2" -NoNewline -ForegroundColor Yellow
    Write-Host "=PayPal, " -NoNewline -ForegroundColor Gray
    Write-Host "3" -NoNewline -ForegroundColor Yellow
    Write-Host "=Coffee, " -NoNewline -ForegroundColor Gray
    Write-Host "4" -NoNewline -ForegroundColor Yellow
    Write-Host "=Ko-Fi, " -NoNewline -ForegroundColor Gray
    Write-Host "5" -NoNewline -ForegroundColor Yellow
    Write-Host "=GitHub, other key = Exit." -ForegroundColor Gray

    $pressed = ''
    try {
        if ($TimeoutSeconds -gt 0) {
            $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
            while ((Get-Date) -lt $deadline -and -not $Host.UI.RawUI.KeyAvailable) { Start-Sleep -Milliseconds 100 }
            if ($Host.UI.RawUI.KeyAvailable) {
                $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                $pressed = $key.Character.ToString()
            }
        } else {
            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            $pressed = $key.Character.ToString()
        }
    } catch { }

    if ($keyActions.ContainsKey($pressed) -and $keyActions[$pressed]) {
        Start-Process $keyActions[$pressed]
    }
    Clear-Host
    Write-Host "`n Thank you for using Universal Windows Wallpaper Changer!`n" -ForegroundColor Cyan
    exit $script:ExitCode
}

# =============================================
# HTTP AND RATE LIMITS
# =============================================

$RateLimitMinutes = @{ Unsplash = 55; Pexels = 55; Pixabay = 2; Flickr = 30; Wallhaven = 2 }

function Get-RateLimitFile {
    param([string]$Provider)
    return (Join-Path $script:LocalRoot ("ratelimit_{0}.txt" -f $Provider.ToLower()))
}

function Test-ProviderRateLimited {
    param([string]$Provider)
    $f = Get-RateLimitFile $Provider
    if (-not (Test-Path -LiteralPath $f)) { return $null }
    try { $until = [datetime](Get-Content -LiteralPath $f -Raw) }
    catch { Remove-Item -LiteralPath $f -Force -ErrorAction SilentlyContinue; return $null }
    if ((Get-Date) -lt $until) { return $until }
    Remove-Item -LiteralPath $f -Force -ErrorAction SilentlyContinue
    return $null
}

function Set-ProviderRateLimited {
    param([string]$Provider)
    $minutes = if ($RateLimitMinutes.ContainsKey($Provider)) { $RateLimitMinutes[$Provider] } else { 5 }
    try {
        if (-not (Test-Path -LiteralPath $script:LocalRoot)) { New-Item -ItemType Directory -Force -Path $script:LocalRoot | Out-Null }
        Set-Content -LiteralPath (Get-RateLimitFile $Provider) -Value (Get-Date).AddMinutes($minutes).ToString('o')
    } catch { }
}

function Get-HttpStatusCode {
    param($ErrorRecord)
    try {
        $resp = $ErrorRecord.Exception.Response
        if ($resp) { return [int]$resp.StatusCode }
    } catch { }
    return 0
}

function Invoke-Api {
    param(
        [string]$Uri,
        [string]$Provider,
        [hashtable]$Headers = @{},
        [string]$Method = 'Get',
        [string]$Body = $null,
        [int]$MaxRetries = 3
    )
    Write-DebugMessage ("{0} {1}" -f $Method.ToUpper(), (Hide-Secret $Uri))
    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            if ($Body) {
                return Invoke-RestMethod -Uri $Uri -Headers $Headers -Method $Method -Body $Body -ContentType 'application/json' -UserAgent $UserAgent -TimeoutSec 30 -Verbose:$false
            }
            return Invoke-RestMethod -Uri $Uri -Headers $Headers -Method $Method -UserAgent $UserAgent -TimeoutSec 30 -Verbose:$false
        } catch {
            $code = Get-HttpStatusCode $_
            if ($code -eq 429 -or ($code -eq 403 -and $Provider -eq 'Unsplash')) {
                Set-ProviderRateLimited $Provider
                throw "$Provider rate limit reached (HTTP $code)."
            }
            if ($code -in @(400, 401, 403, 404)) {
                throw ("{0} request failed (HTTP {1}). Check the key, address and query." -f $Provider, $code)
            }
            if ($i -eq $MaxRetries) { throw (Hide-Secret $_.Exception.Message) }
            Write-Log ("Retry {0}/{1} ({2}): {3}" -f $i, $MaxRetries, $Provider, (Hide-Secret $_.Exception.Message)) 'WARN'
            Start-Sleep -Seconds (2 * $i)
        }
    }
}

function Expand-Response {
    # Windows PowerShell 5.1 can return a JSON array as ONE nested object; flatten fully.
    param($Raw)
    return @(foreach ($x in @($Raw)) { foreach ($y in @($x)) { $y } })
}

# =============================================
# IMAGE HELPERS
# =============================================

function New-Photo {
    param(
        [string]$Provider, [string]$Id, [string]$Raw, [string]$PageUrl = '',
        [string]$Author = '', [string]$AuthorUrl = '', $Width = 0, $Height = 0,
        [string]$Download = '', [bool]$IsLocal = $false, [int]$MinWidth = 0
    )
    if ([string]::IsNullOrWhiteSpace($Raw)) { return $null }
    if (-not $IsLocal -and $Raw -notmatch '^https?://') { return $null }
    $w = 0; $h = 0
    [void][int]::TryParse([string]$Width, [ref]$w)
    [void][int]::TryParse([string]$Height, [ref]$h)
    return [pscustomobject]@{
        Provider = $Provider; Id = $Id; Raw = $Raw; PageUrl = $PageUrl
        Author = $Author; AuthorUrl = $AuthorUrl; Width = $w; Height = $h
        Download = $Download; IsLocal = $IsLocal; MinWidth = $MinWidth
    }
}

function Get-LongSideMeasure {
    # MinWidth applies to the width, or to the height for portrait images.
    param([int]$W, [int]$H, [string]$Orientation)
    if ($Orientation -eq 'portrait') { return $H }
    return $W
}

function Test-OrientationOk {
    param([int]$W, [int]$H, [string]$Orientation)
    if ($W -le 0 -or $H -le 0) { return $true }
    switch ($Orientation) {
        'landscape' { return ($W -gt $H) }
        'portrait'  { return ($H -gt $W) }
        default     { $r = $W / $H; return ($r -ge 0.8 -and $r -le 1.25) }
    }
}

function Test-DimensionsOk {
    # Used for metadata known before download (0 = unknown = pass).
    param([hashtable]$Cfg, [int]$W, [int]$H, [int]$MinWidthOverride = 0)
    if ($W -le 0 -or $H -le 0) { return $true }
    $min = if ($MinWidthOverride -gt 0) { $MinWidthOverride } else { $Cfg.MinWidth }
    if ((Get-LongSideMeasure $W $H $Cfg.Orientation) -lt $min) { return $false }
    if ($Cfg.MinPixels -gt 0 -and ($W * $H) -lt $Cfg.MinPixels) { return $false }
    return (Test-OrientationOk $W $H $Cfg.Orientation)
}

function Get-ImageFileInfo {
    # Real dimensions via System.Drawing; $null when unreadable.
    param([string]$Path)
    try {
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        $img = [System.Drawing.Image]::FromFile($Path)
        try { return @{ W = [int]$img.Width; H = [int]$img.Height } }
        finally { $img.Dispose() }
    } catch { return $null }
}

function Get-ImageExtension {
    # Detects the real type from the first bytes. $null = unsupported.
    param([string]$Path)
    try {
        $fs = [IO.File]::OpenRead($Path)
        try {
            $buf = New-Object byte[] 12
            $n = $fs.Read($buf, 0, 12)
        } finally { $fs.Dispose() }
        if ($n -ge 3 -and $buf[0] -eq 0xFF -and $buf[1] -eq 0xD8 -and $buf[2] -eq 0xFF) { return 'jpg' }
        if ($n -ge 4 -and $buf[0] -eq 0x89 -and $buf[1] -eq 0x50 -and $buf[2] -eq 0x4E -and $buf[3] -eq 0x47) { return 'png' }
        if ($n -ge 2 -and $buf[0] -eq 0x42 -and $buf[1] -eq 0x4D) { return 'bmp' }
    } catch { }
    return $null
}

function Test-ImageFile {
    # Checks size, real dimensions and orientation. Returns @{ Ok; W; H; Reason }.
    param([string]$Path, [hashtable]$Cfg, [int]$MinWidthOverride = 0)
    $minBytes = ConvertTo-Bytes $Cfg.MinSize
    $len = (Get-Item -LiteralPath $Path).Length
    if ($minBytes -gt 0 -and $len -lt $minBytes) {
        return @{ Ok = $false; W = 0; H = 0; Reason = ("file too small ({0})" -f (Format-Bytes $len)) }
    }
    $info = Get-ImageFileInfo $Path
    if ($null -eq $info) { return @{ Ok = $false; W = 0; H = 0; Reason = 'unreadable image' } }
    $min = if ($MinWidthOverride -gt 0) { $MinWidthOverride } else { $Cfg.MinWidth }
    $measure = Get-LongSideMeasure $info.W $info.H $Cfg.Orientation
    if ($measure -lt $min) {
        return @{ Ok = $false; W = $info.W; H = $info.H; Reason = ("too small ({0}x{1})" -f $info.W, $info.H) }
    }
    if ($Cfg.MinPixels -gt 0 -and ($info.W * $info.H) -lt $Cfg.MinPixels) {
        return @{ Ok = $false; W = $info.W; H = $info.H; Reason = ("too few pixels ({0}x{1})" -f $info.W, $info.H) }
    }
    if (-not (Test-OrientationOk $info.W $info.H $Cfg.Orientation)) {
        return @{ Ok = $false; W = $info.W; H = $info.H; Reason = ("wrong orientation ({0}x{1})" -f $info.W, $info.H) }
    }
    return @{ Ok = $true; W = $info.W; H = $info.H; Reason = '' }
}

# =============================================
# PROVIDERS - each returns an array of photo objects
# =============================================

function Get-BingBatch {
    param([hashtable]$Cfg)
    if ($Cfg.Orientation -ne 'landscape') { throw 'Bing provides landscape images only.' }
    if ($Cfg.MinWidth -gt 3840) { throw 'Bing images are at most 3840 px wide.' }
    $markets = @('en-US','en-GB','de-DE','fr-FR','ja-JP','en-IN','en-AU','en-CA','pt-BR','it-IT','es-ES','zh-CN')
    $mkt = Get-Random -InputObject $markets
    $idx = Get-Random -Minimum 0 -Maximum 8
    $uri = 'https://www.bing.com/HPImageArchive.aspx?format=js&idx={0}&n=8&mkt={1}' -f $idx, $mkt
    $r = Invoke-Api -Uri $uri -Provider 'Bing'
    $images = @($r.images)
    if ($images.Count -eq 0) { throw 'Bing returned no images.' }
    $items = @($images | ForEach-Object {
        if (-not $_.urlbase) { return }
        $page = [string]$_.copyrightlink
        if ($page -and $page -notmatch '^https?://') { $page = 'https://www.bing.com' + $page }
        $id = if ($_.hsh) { [string]$_.hsh } else { '{0}-{1}' -f $_.startdate, $mkt }
        New-Photo -Provider 'Bing' -Id $id -Raw ('https://www.bing.com{0}_UHD.jpg' -f $_.urlbase) `
            -PageUrl $page -Author ([string]$_.copyright) -AuthorUrl 'https://www.bing.com' -Width 3840 -Height 2160
    } | Where-Object { $_ })
    if ($items.Count -eq 0) { throw 'Bing: no usable images.' }
    return @($items | Sort-Object { Get-Random })
}

function Get-PicsumBatch {
    param([hashtable]$Cfg)
    $min = $Cfg.MinWidth
    $items = @()
    try {
        $page = Get-Random -Minimum 1 -Maximum 11
        $r = Invoke-Api -Uri ("https://picsum.photos/v2/list?page={0}&limit=100" -f $page) -Provider 'Picsum'
        $list = Expand-Response $r
        $items = @($list | Where-Object { $_.id -and $_.download_url } | ForEach-Object {
            if (-not (Test-DimensionsOk $Cfg ([int]$_.width) ([int]$_.height))) { return }
            New-Photo -Provider 'Picsum' -Id ('picsum-' + $_.id) -Raw ([string]$_.download_url) `
                -PageUrl ([string]$_.url) -Author ([string]$_.author) -AuthorUrl 'https://picsum.photos' `
                -Width $_.width -Height $_.height
        } | Where-Object { $_ })
    } catch { Write-DebugMessage "Picsum list unavailable: $($_.Exception.Message)" }

    if ($items.Count -eq 0) {
        # Fallback: server-side crop to the requested size.
        $w = [math]::Min($min, 5000)
        $h = [int][math]::Ceiling($w * 9 / 16)
        switch ($Cfg.Orientation) {
            'portrait' { $t = $w; $w = $h; $h = $t }
            'squarish' { $h = $w }
        }
        if ($Cfg.MinPixels -gt ($w * $h)) {
            $ratio = [math]::Sqrt($Cfg.MinPixels / ($w * $h))
            $w = [math]::Min([int][math]::Ceiling($w * $ratio), 5000)
            $h = [math]::Min([int][math]::Ceiling($h * $ratio), 5000)
        }
        $items = @(1..15 | ForEach-Object {
            $seed = Get-Random -Minimum 1 -Maximum 1000000
            New-Photo -Provider 'Picsum' -Id "picsum-seed-$seed" -Raw "https://picsum.photos/seed/$seed/$w/$h" `
                -PageUrl "https://picsum.photos/seed/$seed/info" -Author 'Picsum' -AuthorUrl 'https://picsum.photos' `
                -Width $w -Height $h
        } | Where-Object { $_ })
    }
    return @($items | Sort-Object { Get-Random })
}

function Get-WallhavenBatch {
    param([hashtable]$Cfg, [string]$Query)
    $headers = @{}
    $key = Get-ApiKey 'Wallhaven'
    if ($key) { $headers['X-API-Key'] = $key }
    $ratios = switch ($Cfg.Orientation) { 'portrait' { 'portrait' } 'squarish' { '1x1' } default { 'landscape' } }
    # purity=100 -> SFW only, always
    $uri = 'https://wallhaven.cc/api/v1/search?q={0}&categories=110&purity=100&sorting=random&ratios={1}&page=1' -f `
        [uri]::EscapeDataString($Query), $ratios
    if ($Cfg.Orientation -eq 'landscape') {
        $uri += '&atleast={0}x{1}' -f $Cfg.MinWidth, [int][math]::Ceiling($Cfg.MinWidth * 9 / 16)
    }
    $r = Invoke-Api -Uri $uri -Provider 'Wallhaven' -Headers $headers
    $data = @($r.data)
    if ($data.Count -eq 0) { throw "Wallhaven: no results for '$Query'." }
    $items = @($data | ForEach-Object {
        if (-not (Test-DimensionsOk $Cfg ([int]$_.dimension_x) ([int]$_.dimension_y))) { return }
        New-Photo -Provider 'Wallhaven' -Id ([string]$_.id) -Raw ([string]$_.path) -PageUrl ([string]$_.url) `
            -Author 'Wallhaven' -AuthorUrl 'https://wallhaven.cc' -Width $_.dimension_x -Height $_.dimension_y
    } | Where-Object { $_ })
    if ($items.Count -eq 0) { throw "Wallhaven: no results for '$Query' matching the filters." }
    return @($items | Sort-Object { Get-Random })
}

function Get-LocalBatch {
    param([hashtable]$Cfg, [string]$Provider)
    $root = if ($Provider -eq 'Photos') { Get-PicturesFolder } else { $Cfg.Folder }
    if ([string]::IsNullOrWhiteSpace($root)) { throw 'No folder given. Use -Folder <path>.' }
    if (-not (Test-Path -LiteralPath $root -PathType Container)) { throw "Folder not found: $root" }
    $exts = @('.jpg', '.jpeg', '.png', '.bmp')
    $minBytes = ConvertTo-Bytes $Cfg.MinSize
    $own = [IO.Path]::GetFullPath($Cfg.Dir).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    $files = @(Get-ChildItem -LiteralPath $root -File -Recurse -ErrorAction SilentlyContinue | Where-Object {
        ($exts -contains $_.Extension.ToLower()) -and
        ($minBytes -le 0 -or $_.Length -ge $minBytes) -and
        ($Provider -ne 'Photos' -or -not $_.FullName.StartsWith($own, [StringComparison]::OrdinalIgnoreCase))
    })
    if ($files.Count -eq 0) { throw "No usable images (jpg, png, bmp) in $root" }
    return @($files | Sort-Object { Get-Random } | ForEach-Object {
        New-Photo -Provider $Provider -Id $_.BaseName -Raw $_.FullName -PageUrl $_.FullName -Author 'local' `
            -AuthorUrl $root -IsLocal $true
    } | Where-Object { $_ })
}

function Get-UrlBatch {
    # -Source URL: one image link, or a .txt list (file or link) with one link per line.
    param([hashtable]$Cfg)
    $src = [string]$Cfg.Url
    if ([string]::IsNullOrWhiteSpace($src)) { throw 'No link given. Use -URL <image link or .txt list>.' }
    if ($src -match '^https?://') {
        if ((($src -split '[?#]')[0]) -imatch '\.txt$') {
            $links = @((Get-WebText -Url $src -TimeoutSec 30) -split "`r?`n")
        } else { $links = @($src) }
    } else {
        if (-not (Test-Path -LiteralPath $src -PathType Leaf)) { throw "List file not found: $src" }
        $links = @(Get-Content -LiteralPath $src -Encoding UTF8)
    }
    $clean = @($links | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^https?://\S+$' } |
               ForEach-Object { $_ -replace '(?i)(dropbox\.com/\S*[?&]dl)=0', '$1=1' } |
               Select-Object -Unique | Select-Object -First 2000)
    if ($clean.Count -eq 0) { throw 'No links (http:// or https://) found in the list.' }
    return @($clean | Sort-Object { Get-Random } | ForEach-Object {
        $hostName = $_ -replace '^https?://([^/?#]+).*$', '$1'
        New-Photo -Provider 'URL' -Id ('url-' + [math]::Abs($_.GetHashCode())) -Raw $_ -PageUrl $_ `
            -Author $hostName -AuthorUrl ('https://' + $hostName)
    } | Where-Object { $_ })
}

function Get-FlickrBatch {
    # EXPERIMENTAL: not verified against a live account.
    param([hashtable]$Cfg, [string]$Query)
    $key = Get-ApiKey 'Flickr'
    if (-not $key) { throw 'FLICKR_API_KEY not set.' }
    $page = Get-Random -Minimum 1 -Maximum 11
    $uri = ('https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key={0}&text={1}' +
            '&sort=interestingness-desc&license=4,5,6,7,8,9,10&media=photos&content_type=1&safe_search=1' +
            '&extras=url_o,o_dims,owner_name&per_page=100&page={2}&format=json&nojsoncallback=1') -f `
            $key, [uri]::EscapeDataString($Query), $page
    $r = Invoke-Api -Uri $uri -Provider 'Flickr'
    if ($r.stat -ne 'ok') { throw "Flickr: $($r.message)" }
    $photos = @($r.photos.photo)
    if ($photos.Count -eq 0) { throw "Flickr: no results for '$Query'." }
    $items = @($photos | ForEach-Object {
        if (-not $_.url_o) { return }
        if (-not (Test-DimensionsOk $Cfg ([int]$_.width_o) ([int]$_.height_o))) { return }
        New-Photo -Provider 'Flickr' -Id ([string]$_.id) -Raw ([string]$_.url_o) `
            -PageUrl ('https://www.flickr.com/photos/{0}/{1}' -f $_.owner, $_.id) `
            -Author ([string]$_.ownername) -AuthorUrl ('https://www.flickr.com/people/{0}' -f $_.owner) `
            -Width $_.width_o -Height $_.height_o
    } | Where-Object { $_ })
    if ($items.Count -eq 0) { throw "Flickr: no original-size photos for '$Query' matching the filters." }
    return @($items | Sort-Object { Get-Random })
}

function Resolve-ImmichUrl {
    param([hashtable]$Cfg)
    $u = $Cfg.ImmichUrl
    if ([string]::IsNullOrWhiteSpace($u)) { $u = Get-StoredImmichUrl }
    if ([string]::IsNullOrWhiteSpace($u)) { return '' }
    return $u.TrimEnd('/')
}

function Get-ImmichBatch {
    # EXPERIMENTAL: not verified against a live server.
    param([hashtable]$Cfg)
    $key = Get-ApiKey 'Immich'
    if (-not $key) { throw 'IMMICH_API_KEY not set.' }
    $url = Resolve-ImmichUrl $Cfg
    if (-not $url) { throw 'Immich server address not set. Use -ImmichUrl <url>.' }
    $r = Invoke-Api -Uri "$url/api/search/random" -Provider 'Immich' -Method 'Post' `
        -Headers @{ 'x-api-key' = $key; 'Accept' = 'application/json' } -Body '{"size":50,"type":"IMAGE"}'
    $assets = Expand-Response $r
    $items = @($assets | Where-Object { $_.id } | ForEach-Object {
        $w = 0; $h = 0
        if ($_.exifInfo) { $w = [int]$_.exifInfo.exifImageWidth; $h = [int]$_.exifInfo.exifImageHeight }
        if (-not (Test-DimensionsOk $Cfg $w $h)) { return }
        New-Photo -Provider 'Immich' -Id ([string]$_.id) -Raw ("$url/api/assets/$($_.id)/original") `
            -PageUrl "$url/photos/$($_.id)" -Author ([string]$_.originalFileName) -AuthorUrl $url -Width $w -Height $h
    } | Where-Object { $_ })
    if ($items.Count -eq 0) { throw 'Immich: no images matching the filters.' }
    return @($items | Sort-Object { Get-Random })
}

function Get-PexelsBatch {
    param([hashtable]$Cfg, [string]$Query)
    $key = Get-ApiKey 'Pexels'
    if (-not $key) { throw 'PEXELS_API_KEY not set.' }
    $orient = switch ($Cfg.Orientation) { 'portrait' { 'portrait' } 'squarish' { 'square' } default { 'landscape' } }
    $photos = @()
    foreach ($page in @((Get-Random -Minimum 1 -Maximum 21), 1)) {
        $uri = 'https://api.pexels.com/v1/search?query={0}&orientation={1}&per_page=80&page={2}' -f `
            [uri]::EscapeDataString($Query), $orient, $page
        $r = Invoke-Api -Uri $uri -Provider 'Pexels' -Headers @{ Authorization = $key }
        $photos = @($r.photos)
        if ($photos.Count -gt 0) { break }
    }
    if ($photos.Count -eq 0) { throw "Pexels: no results for '$Query'." }
    $items = @($photos | ForEach-Object {
        if (-not (Test-DimensionsOk $Cfg ([int]$_.width) ([int]$_.height))) { return }
        New-Photo -Provider 'Pexels' -Id ([string]$_.id) -Raw ([string]$_.src.original) -PageUrl ([string]$_.url) `
            -Author ([string]$_.photographer) -AuthorUrl ([string]$_.photographer_url) -Width $_.width -Height $_.height
    } | Where-Object { $_ })
    if ($items.Count -eq 0) { throw "Pexels: no results for '$Query' matching the filters." }
    return @($items | Sort-Object { Get-Random })
}

function Get-PixabayBatch {
    param([hashtable]$Cfg, [string]$Query)
    $key = Get-ApiKey 'Pixabay'
    if (-not $key) { throw 'PIXABAY_API_KEY not set.' }
    $freeMax = 1280
    $effective = $Cfg.MinWidth
    if ($effective -gt $freeMax) {
        Write-Warn ("Pixabay free API returns at most {0}px; using {0}px as the minimum." -f $freeMax)
        $effective = $freeMax
    }
    $orient = switch ($Cfg.Orientation) { 'portrait' { 'vertical' } 'squarish' { 'all' } default { 'horizontal' } }
    $hits = @()
    foreach ($page in @((Get-Random -Minimum 1 -Maximum 11), 1)) {
        $uri = 'https://pixabay.com/api/?key={0}&q={1}&image_type=photo&orientation={2}&per_page=100&page={3}&safesearch=true' -f `
            $key, [uri]::EscapeDataString($Query), $orient, $page
        $r = Invoke-Api -Uri $uri -Provider 'Pixabay'
        $hits = @($r.hits)
        if ($hits.Count -gt 0) { break }
    }
    if ($hits.Count -eq 0) { throw "Pixabay: no results for '$Query'." }
    $items = @($hits | ForEach-Object {
        $raw = if ($_.fullHDURL) { $_.fullHDURL } else { $_.largeImageURL }
        if (-not (Test-DimensionsOk $Cfg ([int]$_.imageWidth) ([int]$_.imageHeight) $effective)) { return }
        New-Photo -Provider 'Pixabay' -Id ([string]$_.id) -Raw ([string]$raw) -PageUrl ([string]$_.pageURL) `
            -Author ([string]$_.user) -AuthorUrl ([string]$_.pageURL) -Width $_.imageWidth -Height $_.imageHeight -MinWidth $effective
    } | Where-Object { $_ })
    if ($items.Count -eq 0) { throw "Pixabay: no results for '$Query' >= $effective px." }
    return @($items | Sort-Object { Get-Random })
}

function Get-UnsplashBatch {
    param([hashtable]$Cfg, [string]$Query)
    $key = Get-ApiKey 'Unsplash'
    if (-not $key) { throw 'UNSPLASH_ACCESS_KEY not set.' }
    $h = @{ Authorization = "Client-ID $key"; 'Accept-Version' = 'v1' }
    $results = @()
    foreach ($page in @((Get-Random -Minimum 1 -Maximum 41), 1)) {
        $uri = 'https://api.unsplash.com/search/photos?query={0}&orientation={1}&per_page=30&page={2}' -f `
            [uri]::EscapeDataString($Query), $Cfg.Orientation, $page
        $r = Invoke-Api -Uri $uri -Provider 'Unsplash' -Headers $h
        $results = @($r.results)
        if ($results.Count -gt 0) { break }
    }
    if ($results.Count -eq 0) { throw "Unsplash: no results for '$Query'." }
    $items = @($results | ForEach-Object {
        if (-not (Test-DimensionsOk $Cfg ([int]$_.width) ([int]$_.height))) { return }
        New-Photo -Provider 'Unsplash' -Id ([string]$_.id) -Raw ([string]$_.urls.raw) -PageUrl ([string]$_.links.html) `
            -Author ([string]$_.user.name) -AuthorUrl ([string]$_.user.links.html) -Width $_.width -Height $_.height `
            -Download ([string]$_.links.download_location)
    } | Where-Object { $_ })
    if ($items.Count -eq 0) { throw "Unsplash: no results for '$Query' matching the filters." }
    return @($items | Sort-Object { Get-Random })
}

function Get-ProviderBatch {
    param([hashtable]$Cfg, [string]$Provider, [string]$Query)
    switch ($Provider) {
        'Bing'      { return @(Get-BingBatch $Cfg) }
        'Picsum'    { return @(Get-PicsumBatch $Cfg) }
        'Wallhaven' { return @(Get-WallhavenBatch $Cfg $Query) }
        'Photos'    { return @(Get-LocalBatch $Cfg 'Photos') }
        'Folder'    { return @(Get-LocalBatch $Cfg 'Folder') }
        'Flickr'    { return @(Get-FlickrBatch $Cfg $Query) }
        'Immich'    { return @(Get-ImmichBatch $Cfg) }
        'Pexels'    { return @(Get-PexelsBatch $Cfg $Query) }
        'Pixabay'   { return @(Get-PixabayBatch $Cfg $Query) }
        'Unsplash'  { return @(Get-UnsplashBatch $Cfg $Query) }
        'URL'       { return @(Get-UrlBatch $Cfg) }
        default     { throw "Unknown source: $Provider" }
    }
}

# =============================================
# QUEUE (upcoming images per provider and filters)
# =============================================

function Get-QueueFile {
    param([hashtable]$Cfg, [string]$Provider, [string]$Query)
    $q = ($Query -replace '[^\w]', '_')
    $name = '{0}_{1}_{2}_{3}.clixml' -f $Provider.ToLower(), $q, $Cfg.MinWidth, $Cfg.Orientation
    return (Join-Path $script:QueueDir $name)
}

function Test-QueueAllowed {
    param([string]$Provider)
    return ($Provider -notin @('Photos', 'Folder', 'Immich', 'URL'))
}

function Read-Queue {
    param([string]$File)
    if (-not (Test-Path -LiteralPath $File)) { return @() }
    try {
        return @(Import-Clixml -LiteralPath $File -ErrorAction Stop | Where-Object {
            $_ -and $_.PSObject.Properties['Raw'] -and $_.Raw -match '^https?://' -and $_.PSObject.Properties['Provider']
        })
    } catch {
        Remove-Item -LiteralPath $File -Force -ErrorAction SilentlyContinue
        return @()
    }
}

function Write-Queue {
    param([string]$File, [object[]]$Items)
    if (-not $Items -or $Items.Count -eq 0) {
        Remove-Item -LiteralPath $File -Force -ErrorAction SilentlyContinue
        return
    }
    if (-not (Test-Path -LiteralPath $script:QueueDir)) { New-Item -ItemType Directory -Force -Path $script:QueueDir | Out-Null }
    $tmp = "$File.tmp"
    Export-Clixml -InputObject $Items -LiteralPath $tmp -Depth 4
    Move-Item -LiteralPath $tmp -Destination $File -Force
}

# =============================================
# WALLPAPER, FILE NAMES, LOG, CLEANUP
# =============================================

function Initialize-NativeType {
    if (-not ('UWWC.Native' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
namespace UWWC {
    public static class Native {
        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni);
    }
}
'@
    }
}

function Set-Wallpaper {
    param([string]$Path)
    Initialize-NativeType
    Set-ItemProperty -Path $script:DesktopKey -Name WallpaperStyle -Value '10'   # Fill
    Set-ItemProperty -Path $script:DesktopKey -Name TileWallpaper -Value '0'
    # SPI_SETDESKWALLPAPER = 0x0014; SPIF_UPDATEINIFILE | SPIF_SENDCHANGE = 0x03
    if (-not [UWWC.Native]::SystemParametersInfo(0x0014, 0, $Path, 0x03)) {
        throw ('SystemParametersInfo failed, Win32 error {0}' -f [Runtime.InteropServices.Marshal]::GetLastWin32Error())
    }
}

function Get-NextFileName {
    # <provider>_img_<yyyyMMdd>_<N>.<ext>; N = highest existing number for that prefix + 1.
    param([string]$Dir, [string]$Provider, [string]$Extension)
    $prefix = '{0}_img_{1}_' -f $Provider.ToLower(), (Get-Date -Format 'yyyyMMdd')
    $max = 0
    foreach ($f in @(Get-ChildItem -LiteralPath $Dir -File -ErrorAction SilentlyContinue)) {
        if ($f.Name.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase) -and $f.BaseName -match '_(\d+)$') {
            $n = [int]$Matches[1]
            if ($n -gt $max) { $max = $n }
        }
    }
    return ('{0}{1}.{2}' -f $prefix, ($max + 1), $Extension)
}

function Move-LegacyDirFiles {
    # Housekeeping files used to live next to the images; they belong in LocalRoot.
    param([string]$Dir)
    try {
        if (-not (Test-Path -LiteralPath $Dir -PathType Container)) { return }
        if (-not (Test-Path -LiteralPath $script:LocalRoot)) { New-Item -ItemType Directory -Force -Path $script:LocalRoot | Out-Null }
        $oldLog = Join-Path $Dir 'attribution.log'
        if (Test-Path -LiteralPath $oldLog) {
            $newLog = Join-Path $script:LocalRoot 'attribution.log'
            Get-Content -LiteralPath $oldLog -Encoding UTF8 | Add-Content -LiteralPath $newLog -Encoding UTF8
            Remove-Item -LiteralPath $oldLog -Force
        }
        Get-ChildItem -LiteralPath $Dir -Filter 'queue_*.clixml' -File -ErrorAction SilentlyContinue |
            Remove-Item -Force -ErrorAction SilentlyContinue
    } catch { Write-DebugMessage "Legacy file move failed: $($_.Exception.Message)" }
}

function Write-AttributionLog {
    param([hashtable]$Cfg, $Photo, [string]$File)
    try {
        $fields = @((Get-Date -Format 's'), $Photo.Provider, $Photo.Id, $Photo.Author,
                    $Photo.PageUrl, $Photo.AuthorUrl, (Split-Path $File -Leaf))
        Add-Content -LiteralPath (Join-Path $script:LocalRoot 'attribution.log') -Value ($fields -join "`t") -Encoding UTF8
    } catch { Write-Log "Attribution log failed: $($_.Exception.Message)" 'WARN' }
}

function Send-UnsplashDownloadPing {
    # Unsplash API guideline: report the download of every photo that is used.
    param($Photo)
    if ($Photo.Provider -ne 'Unsplash' -or -not $Photo.Download) { return }
    if ($Photo.Download -notmatch '^https://api\.unsplash\.com/') { return }
    $key = Get-ApiKey 'Unsplash'
    if (-not $key) { return }
    try {
        Invoke-RestMethod -Uri $Photo.Download -Method Get -Verbose:$false -UserAgent $UserAgent -TimeoutSec 15 `
            -Headers @{ Authorization = "Client-ID $key"; 'Accept-Version' = 'v1' } | Out-Null
    } catch {
        $code = Get-HttpStatusCode $_
        if ($code -eq 403 -or $code -eq 429) { Set-ProviderRateLimited 'Unsplash' }
        Write-Log "Unsplash download ping failed: $($_.Exception.Message)" 'WARN'
    }
}

function Invoke-OwnFileCleanup {
    # Only files named like this script's downloads (<service>_img_... or the
    # older <service>-img_...) in -Dir are counted, newest by CreationTime kept.
    # The current wallpaper is never deleted. Local sources never reach this.
    param([hashtable]$Cfg, [string]$CurrentFile)
    try {
        $own = @(Get-ChildItem -LiteralPath $Cfg.Dir -File -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -match '^[A-Za-z]+[-_]img_\d' -and
            $_.Extension -in @('.jpg', '.png', '.bmp') -and
            $_.FullName -ne $CurrentFile
        })
        if ($Cfg.KeepCurrentOnly) {
            $own | Remove-Item -Force -ErrorAction SilentlyContinue
        } elseif ($Cfg.Keep -gt 0) {
            $own | Sort-Object CreationTime -Descending | Select-Object -Skip ([math]::Max($Cfg.Keep - 1, 0)) |
                Remove-Item -Force -ErrorAction SilentlyContinue
        }
    } catch { Write-Log "Cleanup failed: $($_.Exception.Message)" 'WARN' }
}

# =============================================
# ONE WALLPAPER CYCLE
# =============================================

function Get-UnsplashImageUrl {
    param($Photo, [hashtable]$Cfg)
    $sep = if ($Photo.Raw.Contains('?')) { '&' } else { '?' }
    $dim = if ($Cfg.Orientation -eq 'portrait') { "h=$($Cfg.MinWidth)" } else { "w=$($Cfg.MinWidth)" }
    $fmt = if ($Cfg.Format -eq 'png') { 'fm=png' } else { "fm=jpg&q=$($Cfg.Quality)" }
    return ('{0}{1}{2}&fit=max&{3}' -f $Photo.Raw, $sep, $dim, $fmt)
}

function Save-RemoteImage {
    param($Photo, [hashtable]$Cfg, [string]$Destination)
    $url = $Photo.Raw
    $headers = @{}
    if ($Photo.Provider -eq 'Unsplash') { $url = Get-UnsplashImageUrl $Photo $Cfg }
    if ($Photo.Provider -eq 'Immich') {
        $k = Get-ApiKey 'Immich'
        if ($k) { $headers['x-api-key'] = $k }
    }
    $agent = $UserAgent
    if ($Photo.Provider -eq 'URL') {
        # Many sites refuse hot-linked images without a Referer or a browser-like agent.
        $origin = $url -replace '^(https?://[^/?#]+).*$', '$1'
        $headers['Referer'] = $origin + '/'
        $agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36'
    }
    Write-DebugMessage ("Download: {0}" -f (Hide-Secret $url))
    try {
        Invoke-WebRequest -Uri $url -OutFile $Destination -Headers $headers -UseBasicParsing -TimeoutSec 180 -UserAgent $agent -Verbose:$false
    } catch {
        $code = Get-HttpStatusCode $_
        if ($code -eq 429) { Set-ProviderRateLimited $Photo.Provider }
        $body = ''
        try { $body = [string]$_.ErrorDetails.Message } catch { }
        if ($Photo.Provider -eq 'URL' -and $code -in @(403, 503) -and $body -match 'Just a moment|_cf_chl|cf-browser-verification') {
            throw 'Blocked by the site. Download the file in a browser and use -Source Folder.'
        }
        throw
    }
}

function Invoke-ProviderCycle {
    param([hashtable]$Cfg, [string]$Provider)

    $isLocal = $Provider -in @('Photos', 'Folder')
    $script:CycleAttempt = 0
    $script:CycleMax = $Cfg.MaxAttempts
    $until = Test-ProviderRateLimited $Provider
    if ($until) { throw ("{0} is rate limited until {1}." -f $Provider, $until.ToString('HH:mm')) }

    $query = ''
    if (Test-SourceSupportsQuery $Provider) {
        $query = if ($Cfg.Query) { $Cfg.Query } else { Get-RandomQueryPhrase }
    }
    $queueOk = Test-QueueAllowed $Provider
    $queueFile = Get-QueueFile $Cfg $Provider $query
    if ($Flags.Fresh -and $queueOk) { Remove-Item -LiteralPath $queueFile -Force -ErrorAction SilentlyContinue }

    if (-not $isLocal -and -not (Test-Path -LiteralPath $Cfg.Dir)) {
        New-Item -ItemType Directory -Force -Path $Cfg.Dir | Out-Null
    }
    if (-not $isLocal) { Move-LegacyDirFiles $Cfg.Dir }

    $maxAttempts = if ($isLocal) { [math]::Max($Cfg.MaxAttempts, 30) } else { $Cfg.MaxAttempts }
    $items = @(); $fresh = $false
    if ($queueOk) { $items = @(Read-Queue $queueFile) }
    Write-DebugMessage ("Queue {0}: {1} item(s) loaded" -f (Split-Path $queueFile -Leaf), $items.Count)
    if ($items.Count -eq 0) { $items = @(Get-ProviderBatch $Cfg $Provider $query); $fresh = $true }

    $idx = 0; $attempt = 0; $reasons = @()
    $accepted = $null; $file = $null; $check = $null

    while ($attempt -lt $maxAttempts) {
        if ($idx -ge $items.Count) {
            if ($fresh) { break }
            $items = @(Get-ProviderBatch $Cfg $Provider $query); $fresh = $true; $idx = 0
            if ($items.Count -eq 0) { break }
        }
        $p = $items[$idx]; $idx++; $attempt++

        if ($isLocal) {
            $c = Test-ImageFile -Path $p.Raw -Cfg $Cfg
            if ($c.Ok) { $accepted = $p; $file = $p.Raw; $check = $c; break }
            $reasons += $c.Reason
            continue
        }

        $tmp = Join-Path $Cfg.Dir ('download_' + [guid]::NewGuid().ToString('N') + '.tmp')
        try {
            Save-RemoteImage -Photo $p -Cfg $Cfg -Destination $tmp
            $ext = Get-ImageExtension $tmp
            if (-not $ext) { $reasons += 'unsupported image type'; continue }
            $c = Test-ImageFile -Path $tmp -Cfg $Cfg -MinWidthOverride $p.MinWidth
            if (-not $c.Ok) { $reasons += $c.Reason; continue }
            $final = Join-Path $Cfg.Dir (Get-NextFileName -Dir $Cfg.Dir -Provider $Provider -Extension $ext)
            Move-Item -LiteralPath $tmp -Destination $final -Force
            $accepted = $p; $file = $final; $check = $c
            break
        } catch {
            $reasons += (Hide-Secret $_.Exception.Message)
            Write-Log ("Attempt {0}: {1}" -f $attempt, (Hide-Secret $_.Exception.Message)) 'WARN'
        } finally {
            Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
        }
    }

    $script:CycleAttempt = $attempt
    $script:CycleMax = $maxAttempts
    if ($queueOk) {
        $rest = @($items | Select-Object -Skip $idx)
        Write-Queue $queueFile $rest
        Write-DebugMessage ("Queue {0}: {1} item(s) saved" -f (Split-Path $queueFile -Leaf), $rest.Count)
    }

    if (-not $file) {
        $summary = if ($reasons.Count -gt 0) { ($reasons | Select-Object -Unique | Select-Object -First 3) -join '; ' } else { 'no candidates' }
        throw ("No acceptable image from {0} after {1} attempt(s): {2}" -f $Provider, $attempt, $summary)
    }

    Set-Wallpaper -Path $file
    if (-not $isLocal) {
        Write-AttributionLog -Cfg $Cfg -Photo $accepted -File $file
        Send-UnsplashDownloadPing -Photo $accepted
        Invoke-OwnFileCleanup -Cfg $Cfg -CurrentFile $file
    }
    $len = (Get-Item -LiteralPath $file).Length
    Write-Log ("Wallpaper set: {0} ({1}x{2}, {3}) from {4}" -f $file, $check.W, $check.H, (Format-Bytes $len), $Provider) 'INFO'
    try {
        $who = if ($isLocal) { '' } else { [string]$accepted.Author }
        Write-TrayState @{ LastImage = (Split-Path $file -Leaf); LastAuthor = $who; LastFile = $file; LastProvider = $Provider
                           LastWidth = $check.W; LastHeight = $check.H; LastSize = $len }
    } catch { }

    return @{
        Ok = $true; Provider = $Provider; File = $file; Photo = $accepted
        Width = $check.W; Height = $check.H; Size = $len
        Attempt = $attempt; MaxAttempts = $maxAttempts; InPlace = $isLocal; Query = $query
    }
}

function Invoke-Cycle {
    # Returns @{ Ok = $true; ... } or @{ Ok = $false; Error = '...' }.
    param([hashtable]$Cfg)
    $providers = if ($Cfg.Source -eq 'Random') {
        @(@('Bing', 'Picsum', 'Wallhaven') | Sort-Object { Get-Random })
    } else { @($Cfg.Source) }

    $errors = @()
    foreach ($prov in $providers) {
        try {
            $res = Invoke-ProviderCycle -Cfg $Cfg -Provider $prov
            if ($res.Ok) { return $res }
        } catch {
            $msg = Hide-Secret $_.Exception.Message
            $errors += $msg
            Write-Log ("{0}: {1}" -f $prov, $msg) 'WARN'
            if ($providers.Count -gt 1) { Write-DebugMessage "Falling back from $prov : $msg" 'Yellow' }
        }
    }
    $text = ($errors | Select-Object -Unique) -join ' | '
    Write-Log "Cycle failed: $text" 'ERROR'
    return @{ Ok = $false; Error = $text }
}

# =============================================
# BACKGROUND MODE: INSTALLED COPY, AUTOSTART, STATE
# =============================================

function Install-ScriptCopy {
    # Stable copy that survives moving or deleting the downloaded script.
    if (-not $ScriptPath) { throw 'The script path is unknown; cannot install the background copy.' }
    if (-not (Test-Path -LiteralPath $script:LocalRoot)) { New-Item -ItemType Directory -Force -Path $script:LocalRoot | Out-Null }
    if ($ScriptPath -ieq $script:InstalledScript) { return }
    Copy-Item -LiteralPath $ScriptPath -Destination $script:InstalledScript -Force
    Write-Log "Installed script copy: $script:InstalledScript" 'INFO'
}

function Get-AutostartCommand {
    $ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    return ('"{0}" -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{1}" -Tray' -f $ps, $script:InstalledScript)
}

function Set-Autostart {
    Set-ItemProperty -Path $script:RunRegPath -Name $script:RunValueName -Value (Get-AutostartCommand) -Type String
}

function Remove-Autostart {
    Remove-ItemProperty -Path $script:RunRegPath -Name $script:RunValueName -ErrorAction SilentlyContinue
}

function Test-AutostartEnabled {
    try {
        $v = (Get-ItemProperty -Path $script:RunRegPath -Name $script:RunValueName -ErrorAction Stop).$($script:RunValueName)
        return (-not [string]::IsNullOrWhiteSpace($v))
    } catch { return $false }
}

function Get-BackgroundConfig {
    $o = Read-ConfigFile -Path $script:BgConfigFile
    if ($null -eq $o) { return $null }
    return (Merge-Config -Base (New-DefaultConfig) -Over $o)
}

function Read-TrayState {
    try {
        if (Test-Path -LiteralPath $script:StateFile) {
            return (Get-Content -LiteralPath $script:StateFile -Raw -Encoding UTF8 | ConvertFrom-Json)
        }
    } catch { }
    return $null
}

function Write-TrayState {
    param([hashtable]$Values)
    try {
        $cur = @{}
        $o = Read-TrayState
        if ($o) { foreach ($p in $o.PSObject.Properties) { $cur[$p.Name] = $p.Value } }
        foreach ($k in $Values.Keys) { $cur[$k] = $Values[$k] }
        if (-not (Test-Path -LiteralPath $script:LocalRoot)) { New-Item -ItemType Directory -Force -Path $script:LocalRoot | Out-Null }
        ($cur | ConvertTo-Json -Depth 3) | Set-Content -LiteralPath $script:StateFile -Encoding UTF8
    } catch { }
}

function Test-TrayRunning {
    $m = $null
    try {
        if ([System.Threading.Mutex]::TryOpenExisting($script:MutexName, [ref]$m)) {
            $m.Dispose()
            return $true
        }
    } catch { }
    return $false
}

function Send-TrayCommand {
    param([ValidateSet('stop','pause','resume','change')][string]$Command)
    if (-not (Test-Path -LiteralPath $script:LocalRoot)) { New-Item -ItemType Directory -Force -Path $script:LocalRoot | Out-Null }
    Set-Content -LiteralPath $script:CmdFile -Value $Command -Encoding ASCII
}

function Stop-Tray {
    if (-not (Test-TrayRunning)) { return $true }
    Send-TrayCommand 'stop'
    for ($i = 0; $i -lt 40; $i++) {
        Start-Sleep -Milliseconds 500
        if (-not (Test-TrayRunning)) { return $true }
    }
    $st = Read-TrayState
    if ($st -and $st.Pid) {
        try { Stop-Process -Id ([int]$st.Pid) -Force -ErrorAction Stop } catch { }
        Start-Sleep -Seconds 1
    }
    return (-not (Test-TrayRunning))
}

function Start-Tray {
    if (Test-TrayRunning) { return $true }
    if (-not (Test-Path -LiteralPath $script:InstalledScript) -or -not (Test-Path -LiteralPath $script:BgConfigFile)) { return $false }
    Remove-Item -LiteralPath $script:CmdFile -Force -ErrorAction SilentlyContinue
    $ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    Start-Process -FilePath $ps -WindowStyle Hidden -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}" -Tray' -f $script:InstalledScript)
    for ($i = 0; $i -lt 24; $i++) {
        Start-Sleep -Milliseconds 500
        if (Test-TrayRunning) { return $true }
    }
    return $false
}

function Initialize-Background {
    # Installs the copy, stores the configuration, enables start at sign-in and (re)starts the tray process.
    param([hashtable]$Cfg)
    Install-ScriptCopy
    Save-ConfigFile -Path $script:BgConfigFile -Cfg $Cfg
    Set-Autostart
    Write-TrayState @{ Paused = $false; LastRun = $null; StartNow = $true }
    if (Test-TrayRunning) {
        if (-not (Stop-Tray)) { throw 'The running background changer did not stop.' }
    }
    if (-not (Start-Tray)) { throw 'The background changer did not start. See the log file.' }
    Write-Log ("Background changer configured: {0}, every {1} min" -f $Cfg.Source, $Cfg.IntervalMinutes) 'INFO'
}

function Get-ShortPath {
    # %LOCALAPPDATA%-style display path.
    param([string]$Path)
    $pairs = @(
        @([Environment]::GetFolderPath('LocalApplicationData'), '%LOCALAPPDATA%'),
        @([Environment]::GetFolderPath('ApplicationData'), '%APPDATA%'),
        @([Environment]::GetFolderPath('UserProfile'), '%USERPROFILE%')
    )
    foreach ($pair in $pairs) {
        if ($pair[0] -and $Path.StartsWith($pair[0], [StringComparison]::OrdinalIgnoreCase)) {
            return ($pair[1] + $Path.Substring($pair[0].Length))
        }
    }
    return $Path
}

function Write-StatusRow {
    param([string]$Label, [string]$Value, [string]$Color = 'White')
    Write-Host (" {0,-19}" -f $Label) -NoNewline -ForegroundColor Gray
    $max = 52
    if ($Value.Length -gt $max) { $Value = $Value.Substring(0, $max - 3) + '...' }
    Write-Host $Value -ForegroundColor $Color
}

function Show-BackgroundStatus {
    $running = Test-TrayRunning
    $auto = Test-AutostartEnabled
    $cfg = Get-BackgroundConfig
    $st = Read-TrayState

    if ($running) { Write-StatusRow 'Background script:' 'RUNNING' 'Green' } else { Write-StatusRow 'Background script:' 'STOPPED' 'Yellow' }
    if ($auto) { Write-StatusRow 'Start at sign-in:' 'ON' 'Green' } else { Write-StatusRow 'Start at sign-in:' 'OFF' 'Gray' }
    if ($null -eq $cfg) {
        Write-Host ' No background settings. Use the wizard and choose Repeat.' -ForegroundColor Yellow
        return
    }
    $paused = [bool]($st -and $st.Paused)
    if ($running -and $paused) { Write-StatusRow 'State:' 'PAUSED' 'Yellow' }
    elseif ($running) { Write-StatusRow 'State:' 'ACTIVE' 'Green' }
    else { Write-StatusRow 'State:' '-' 'Gray' }
    Write-Host ''
    Write-StatusRow 'Source:' ([string]$cfg.Source)
    if ($st -and $st.LastImage) {
        $img = [string]$st.LastImage
        if ($st.LastAuthor) { $img += ' by ' + [string]$st.LastAuthor }
        Write-StatusRow 'Last image:' $img
    }
    Write-StatusRow 'Interval:' ('every {0} min' -f $cfg.IntervalMinutes)
    if ($st -and $st.LastRun) {
        Write-StatusRow 'Last change:' ([string]$st.LastRun)
        if ($st.LastResult) { Write-StatusRow 'Last result:' ([string]$st.LastResult) }
    }
    if ($running -and $st -and $st.NextRun -and -not $paused) { Write-StatusRow 'Next change:' ([string]$st.NextRun) }
    if ($st -and $st.UpdateAvailable) { Write-StatusRow 'Update available:' ([string]$st.UpdateAvailable) 'Yellow' }
    Write-Host ''
    Write-Host ' Log file: ' -NoNewline -ForegroundColor Gray
    Write-Host (Get-ShortPath $script:LogFile) -ForegroundColor DarkGray
}

function Wait-TrayState {
    # Waits until the tray process reports the expected Paused value.
    param([bool]$Paused)
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Milliseconds 500
        $st = Read-TrayState
        if ($st -and ([bool]$st.Paused -eq $Paused)) { return $true }
    }
    return $false
}

function Remove-BackgroundSettings {
    # Stop resets everything: start at sign-in, settings and state.
    Remove-Autostart
    foreach ($f in @($script:BgConfigFile, $script:StateFile, $script:CmdFile)) {
        Remove-Item -LiteralPath $f -Force -ErrorAction SilentlyContinue
    }
}

function Invoke-BackgroundCommand {
    # -Background Status|Start|Stop|Pause|Resume  -> exit code
    param([string]$Command)
    $cfg = Get-BackgroundConfig
    switch ($Command) {
        'Status' {
            Show-BackgroundStatus
            return 0
        }
        'Start' {
            if ($null -eq $cfg) {
                Write-Host ' No background settings. Use -Wizard and choose Repeat.' -ForegroundColor Yellow
                return 1
            }
            if (Test-TrayRunning) {
                Write-Host ' The background changer is already running.' -ForegroundColor Yellow
                return 0
            }
            try {
                Install-ScriptCopy
                Set-Autostart
                if (Start-Tray) { Write-Host ' Background changer started. Start at sign-in: ON.' -ForegroundColor Green; return 0 }
                Write-Host ' The background changer did not start. See the log file.' -ForegroundColor Red
                return 1
            } catch {
                Write-Host (' Could not start: {0}' -f $_.Exception.Message) -ForegroundColor Red
                return 1
            }
        }
        'Stop' {
            if ($null -eq $cfg -and -not (Test-TrayRunning) -and -not (Test-AutostartEnabled)) {
                Write-Host ' Nothing to stop. The background changer is not set up.' -ForegroundColor Yellow
                return 0
            }
            if (-not (Stop-Tray)) {
                Write-Host ' The background changer could not be stopped.' -ForegroundColor Red
                return 1
            }
            Remove-BackgroundSettings
            Write-Host ' Background changer stopped. Its settings and start at' -ForegroundColor Green
            Write-Host ' sign-in were removed.' -ForegroundColor Green
            return 0
        }
        { $_ -in @('Pause', 'Resume') } {
            if (-not (Test-TrayRunning)) {
                if ($null -eq $cfg) { Write-Host ' The background changer is not set up.' -ForegroundColor Yellow }
                else { Write-Host ' The background changer is not running. Use -Background Start.' -ForegroundColor Yellow }
                return 1
            }
            $want = ($Command -eq 'Pause')
            $st = Read-TrayState
            $now = [bool]($st -and $st.Paused)
            if ($now -eq $want) {
                if ($want) { Write-Host ' The background changer is already paused.' -ForegroundColor Yellow }
                else { Write-Host ' The background changer is not paused.' -ForegroundColor Yellow }
                return 0
            }
            Send-TrayCommand ($Command.ToLower())
            if (Wait-TrayState -Paused $want) {
                if ($want) { Write-Host ' Background changer paused. Use -Background Resume to continue.' -ForegroundColor Green }
                else { Write-Host ' Background changer resumed.' -ForegroundColor Green }
                return 0
            }
            Write-Host ' No response from the background changer.' -ForegroundColor Red
            return 1
        }
    }
    return 1
}

# =============================================
# TRAY PROCESS (hidden, resident)
# =============================================

function Get-CurrentWallpaperLabel {
    try {
        $cur = (Get-ItemProperty -Path $script:DesktopKey -Name 'WallPaper' -ErrorAction Stop).WallPaper
        $st = Read-TrayState
        if ($st -and $st.LastFile -and $cur -and ($cur -ieq [string]$st.LastFile)) {
            $txt = [string]$st.LastProvider
            if ($st.LastAuthor) { $txt += ' - ' + [string]$st.LastAuthor }
            elseif ($st.LastImage) { $txt += ' - ' + [string]$st.LastImage }
            if ($txt.Length -gt 48) { $txt = $txt.Substring(0, 45) + '...' }
            return ('Current wallpaper: ' + $txt)
        }
    } catch { }
    return 'Current wallpaper: Unknown'
}

function Get-CurrentWallpaperStats {
    # 'Resolution: 3840x2160 | Size: 4.3MB | Format: PNG (100%)' or $null.
    try {
        $cur = (Get-ItemProperty -Path $script:DesktopKey -Name 'WallPaper' -ErrorAction Stop).WallPaper
        $st = Read-TrayState
        if (-not ($st -and $st.LastFile -and $cur -and ($cur -ieq [string]$st.LastFile))) { return $null }
        if (-not $st.LastWidth) { return $null }
        $ext = [IO.Path]::GetExtension($cur).TrimStart('.').ToUpper()
        if ($ext -eq 'JPEG') { $ext = 'JPG' }
        if ($ext -eq 'PNG') { $fmt = 'PNG (100%)' }
        else {
            $q = Get-JpegImportQuality
            if ($null -eq $q) { $q = 85 }
            $fmt = '{0} ({1}%)' -f $ext, $q
        }
        $size = (Format-Bytes ([int64]$st.LastSize)) -replace ' ', ''
        return ('Resolution: {0}x{1} | Size: {2} | Format: {3}' -f $st.LastWidth, $st.LastHeight, $size, $fmt)
    } catch { return $null }
}

function Get-LastChangeLabel {
    $st = Read-TrayState
    $last = 'Last change: -'
    if ($st -and $st.LastOutcome) {
        $last = 'Last change: {0} ({1}/{2})' -f $st.LastOutcome, $st.LastAttempt, $st.LastMax
    }
    if ($script:TrayPaused) { return ($last + ' | Paused') }
    $every = ''
    $cfg = Get-BackgroundConfig
    if ($cfg -and $cfg.IntervalMinutes -gt 0) { $every = ' (every {0} min)' -f $cfg.IntervalMinutes }
    return ($last + ' | Next change: ' + $script:TrayNextRun.ToString('HH:mm') + $every)
}

function Get-StoredImageCount {
    # Number of downloaded images kept in the wallpapers folder, or $null for local sources.
    $cfg = Get-BackgroundConfig
    if (-not $cfg -or $cfg.Source -in @('Photos', 'Folder')) { return $null }
    try {
        return @(Get-ChildItem -LiteralPath $cfg.Dir -File -ErrorAction Stop | Where-Object {
            $_.Name -match '^[A-Za-z]+[-_]img_\d' -and $_.Extension -in @('.jpg', '.png', '.bmp')
        }).Count
    } catch { return 0 }
}

function Get-WallpaperFolder {
    $cfg = Get-BackgroundConfig
    $d = if ($cfg) { [string]$cfg.Dir } else { '' }
    if ($cfg -and $cfg.Source -eq 'Folder' -and (Test-Path -LiteralPath $cfg.Folder -PathType Container)) { $d = [string]$cfg.Folder }
    elseif ($cfg -and $cfg.Source -eq 'Photos') { $d = Get-PicturesFolder }
    if (-not $d -or -not (Test-Path -LiteralPath $d -PathType Container)) {
        $d = Join-Path (Get-PicturesFolder) 'Universal Windows Wallpapers'
        if (-not (Test-Path -LiteralPath $d -PathType Container)) { $d = Get-PicturesFolder }
    }
    return $d
}

function New-TrayIcon {
    try {
        $bmp = New-Object System.Drawing.Bitmap 32, 32
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.Clear([System.Drawing.Color]::FromArgb(24, 72, 140))
        $sun = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 200, 60))
        $hill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(70, 170, 110))
        $g.FillEllipse($sun, 18, 4, 9, 9)
        $g.FillEllipse($hill, -6, 16, 30, 24)
        $g.FillEllipse($hill, 10, 20, 30, 24)
        $sun.Dispose(); $hill.Dispose(); $g.Dispose()
        return [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
    } catch {
        return [System.Drawing.SystemIcons]::Application
    }
}

function Invoke-TrayCycle {
    $script:TrayBusy = $true
    try {
        $cfg = Get-BackgroundConfig
        if ($null -eq $cfg -or $cfg.IntervalMinutes -lt 1) {
            Write-Log 'Background configuration missing; exiting tray.' 'ERROR'
            $script:TrayExit = $true
            [System.Windows.Forms.Application]::Exit()
            return
        }
        $script:CycleAttempt = 0
        $script:CycleMax = $cfg.MaxAttempts
        $res = Invoke-Cycle -Cfg $cfg
        $now = Get-Date
        if ($res.Ok) {
            $script:TrayNextRun = $now.AddMinutes($cfg.IntervalMinutes)
            $text = '{0} {1}x{2}' -f $res.Provider, $res.Width, $res.Height
        } else {
            $script:TrayNextRun = $now.AddMinutes([math]::Min($cfg.IntervalMinutes, 5))
            $until = $null
            if ($cfg.Source -ne 'Random') { $until = Test-ProviderRateLimited $cfg.Source }
            if ($until -and $until -gt $script:TrayNextRun) { $script:TrayNextRun = $until }
            $text = 'FAILED: ' + $res.Error
        }
        Write-TrayState @{
            LastRun = $now.ToString('yyyy-MM-dd HH:mm'); LastResult = $text
            NextRun = $script:TrayNextRun.ToString('yyyy-MM-dd HH:mm')
            LastOutcome = $(if ($res.Ok) { 'Successful' } else { 'Failed' })
            LastAttempt = $script:CycleAttempt; LastMax = $script:CycleMax
        }
    } catch {
        Write-Log ("Tray cycle error: {0}" -f $_.Exception.Message) 'ERROR'
        $script:TrayNextRun = (Get-Date).AddMinutes(5)
    } finally {
        $script:TrayBusy = $false
    }
}

function Invoke-TrayDailyUpdateCheck {
    $st = Read-TrayState
    if ($st -and $st.LastUpdateCheck) {
        try { if (((Get-Date) - [datetime]$st.LastUpdateCheck).TotalHours -lt 24) { return } } catch { }
    }
    $latest = Get-LatestVersion
    $values = @{ LastUpdateCheck = (Get-Date).ToString('o') }
    if ($latest -and (Compare-Versions -Version1 $ScriptVersion -Version2 $latest) -lt 0) {
        $values['UpdateAvailable'] = $latest
        $script:TrayIcon.ShowBalloonTip(8000, 'Universal Windows Wallpaper Changer',
            ("Version {0} is available. Open the setup wizard from the tray menu to update." -f $latest),
            [System.Windows.Forms.ToolTipIcon]::Info)
    } else {
        $values['UpdateAvailable'] = ''
    }
    Write-TrayState $values
}

function Invoke-TrayCommandFile {
    if (-not (Test-Path -LiteralPath $script:CmdFile)) { return }
    $cmd = ''
    try { $cmd = (Get-Content -LiteralPath $script:CmdFile -Raw -ErrorAction Stop).Trim().ToLower() } catch { return }
    Remove-Item -LiteralPath $script:CmdFile -Force -ErrorAction SilentlyContinue
    switch ($cmd) {
        'stop'   { $script:TrayExit = $true; [System.Windows.Forms.Application]::Exit() }
        'pause'  { $script:TrayPaused = $true;  Write-TrayState @{ Paused = $true } }
        'resume' { $script:TrayPaused = $false; Write-TrayState @{ Paused = $false }; $script:TrayNextRun = Get-Date }
        'change' { $script:TrayNextRun = Get-Date }
    }
}

function Invoke-TrayMode {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $created = $false
    $script:TrayMutex = New-Object System.Threading.Mutex($true, $script:MutexName, [ref]$created)
    if (-not $created) { return }

    $script:TrayExit = $false
    $script:TrayBusy = $false
    $script:TrayPaused = $false
    $st = Read-TrayState
    if ($st -and $st.Paused) { $script:TrayPaused = $true }

    $cfg = Get-BackgroundConfig
    if ($null -eq $cfg -or $cfg.IntervalMinutes -lt 1) {
        Write-Log 'Tray started without a background configuration.' 'ERROR'
        $script:TrayMutex.ReleaseMutex(); $script:TrayMutex.Dispose()
        return
    }

    # First change: right away (after a short delay for the network) when the
    # last change is older than the interval, otherwise at the planned time.
    $startNow = [bool]($st -and $st.StartNow)
    $script:TrayNextRun = (Get-Date).AddSeconds($(if ($startNow) { 1 } else { 30 }))
    if (-not $startNow -and $st -and $st.LastRun) {
        try {
            $planned = ([datetime]$st.LastRun).AddMinutes($cfg.IntervalMinutes)
            if ($planned -gt $script:TrayNextRun) { $script:TrayNextRun = $planned }
        } catch { }
    }
    Write-TrayState @{ Pid = $PID; StartedAt = (Get-Date).ToString('yyyy-MM-dd HH:mm'); Paused = $script:TrayPaused; StartNow = $false
                       NextRun = $script:TrayNextRun.ToString('yyyy-MM-dd HH:mm') }
    Write-Log "Tray started (PID $PID)." 'INFO'

    $script:TrayIcon = New-Object System.Windows.Forms.NotifyIcon
    $script:TrayIcon.Icon = New-TrayIcon
    $script:TrayIcon.Text = 'Universal Windows Wallpaper Changer'

    $script:ProjectUrl = $githubReleasesUrl
    $script:ReleaseUrl = '{0}/releases/tag/v{1}' -f $githubReleasesUrl, $ScriptVersion
    $menu = New-Object System.Windows.Forms.ContextMenuStrip
    $miTitle  = New-Object System.Windows.Forms.ToolStripMenuItem 'Universal Windows Wallpaper Changer'
    try { $miTitle.Font = New-Object System.Drawing.Font($miTitle.Font, [System.Drawing.FontStyle]::Bold) } catch { }
    $miVer    = New-Object System.Windows.Forms.ToolStripMenuItem ('Version {0}' -f $ScriptVersion)
    $miCur    = New-Object System.Windows.Forms.ToolStripMenuItem 'Current wallpaper: Unknown'
    $miCur.Enabled = $false
    $miStats  = New-Object System.Windows.Forms.ToolStripMenuItem 'Resolution: -'
    $miStats.Enabled = $false
    $miInfo   = New-Object System.Windows.Forms.ToolStripMenuItem 'Last change: -'
    $miInfo.Enabled = $false
    $miChange = New-Object System.Windows.Forms.ToolStripMenuItem 'Change now'
    $miPause  = New-Object System.Windows.Forms.ToolStripMenuItem 'Pause'
    $miLast   = New-Object System.Windows.Forms.ToolStripMenuItem 'Last used wallpapers'
    $miWizard = New-Object System.Windows.Forms.ToolStripMenuItem 'Open Wallpaper Setup Wizard'
    $miStartup = New-Object System.Windows.Forms.ToolStripMenuItem 'Startup with Windows (ON)'
    $miExit   = New-Object System.Windows.Forms.ToolStripMenuItem 'Exit'
    [void]$menu.Items.Add($miTitle)
    [void]$menu.Items.Add($miVer)
    [void]$menu.Items.Add($miCur)
    [void]$menu.Items.Add($miStats)
    [void]$menu.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))
    [void]$menu.Items.Add($miInfo)
    [void]$menu.Items.Add($miChange)
    [void]$menu.Items.Add($miPause)
    [void]$menu.Items.Add($miLast)
    [void]$menu.Items.Add($miWizard)
    [void]$menu.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))
    [void]$menu.Items.Add($miStartup)
    [void]$menu.Items.Add($miExit)
    $script:TrayIcon.ContextMenuStrip = $menu
    $script:MiInfo = $miInfo; $script:MiPause = $miPause; $script:MiCur = $miCur
    $script:MiStats = $miStats; $script:MiStartup = $miStartup; $script:MiLast = $miLast

    $menu.Add_Opening({
        try {
            $script:MiCur.Text = Get-CurrentWallpaperLabel
            $stats = Get-CurrentWallpaperStats
            if ($stats) { $script:MiStats.Text = $stats; $script:MiStats.Visible = $true } else { $script:MiStats.Visible = $false }
            $script:MiPause.Text = if ($script:TrayPaused) { 'Resume' } else { 'Pause' }
            $script:MiInfo.Text = Get-LastChangeLabel
            $stored = Get-StoredImageCount
            $script:MiLast.Text = if ($null -ne $stored) { 'Last used wallpapers ({0} stored)' -f $stored } else { 'Last used wallpapers' }
            $script:MiStartup.Text = if (Test-AutostartEnabled) { 'Startup with Windows (ON)' } else { 'Startup with Windows (OFF)' }
        } catch { }
    })
    $miChange.Add_Click({ try { $script:TrayNextRun = Get-Date; $script:TrayPaused = $false; Write-TrayState @{ Paused = $false } } catch { } })
    $miPause.Add_Click({
        try {
            $script:TrayPaused = -not $script:TrayPaused
            Write-TrayState @{ Paused = $script:TrayPaused }
            if (-not $script:TrayPaused) { $script:TrayNextRun = Get-Date }
        } catch { }
    })
    $miWizard.Add_Click({
        try {
            $ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
            Start-Process -FilePath $ps -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -NoExit -File "{0}" -Wizard' -f $script:InstalledScript)
        } catch { }
    })
    $miTitle.Add_Click({ try { Start-Process $script:ProjectUrl } catch { } })
    $miVer.Add_Click({ try { Start-Process $script:ReleaseUrl } catch { } })
    $miLast.Add_Click({ try { Start-Process -FilePath (Get-WallpaperFolder) } catch { } })
    $miStartup.Add_Click({
        try {
            if (Test-AutostartEnabled) { Remove-Autostart; Write-Log 'Startup with Windows: OFF (tray menu).' 'INFO' }
            else { Set-Autostart; Write-Log 'Startup with Windows: ON (tray menu).' 'INFO' }
        } catch { Write-Log ("Startup toggle failed: {0}" -f $_.Exception.Message) 'WARN' }
    })
    $miExit.Add_Click({ try { $script:TrayExit = $true; [System.Windows.Forms.Application]::Exit() } catch { } })
    $script:TrayIcon.Visible = $true

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 2000
    $timer.Add_Tick({
        try {
            Invoke-TrayCommandFile
            if ($script:TrayExit -or $script:TrayBusy) { return }
            if (-not $script:TrayPaused -and (Get-Date) -ge $script:TrayNextRun) {
                Invoke-TrayCycle
                if (-not $script:TrayExit) { Invoke-TrayDailyUpdateCheck }
            }
        } catch { Write-Log ("Tray tick error: {0}" -f $_.Exception.Message) 'ERROR' }
    })
    $timer.Start()

    try {
        [System.Windows.Forms.Application]::Run()
    } finally {
        $timer.Stop(); $timer.Dispose()
        $script:TrayIcon.Visible = $false
        $script:TrayIcon.Dispose()
        Write-TrayState @{ Pid = 0 }
        Write-Log 'Tray stopped.' 'INFO'
        try { $script:TrayMutex.ReleaseMutex() } catch { }
        $script:TrayMutex.Dispose()
    }
}

# =============================================
# DISPLAY HELPERS
# =============================================

function Get-SourceLabel {
    param([hashtable]$Cfg)
    switch ($Cfg.Source) {
        'Photos' { return 'Windows Photos Folder' }
        'Folder' { return 'Custom Folder' }
        'URL'    { return 'Image links' }
        default  { return $Cfg.Source }
    }
}

function Get-QueryLabel {
    param([hashtable]$Cfg)
    if ($Cfg.Source -in @('Random', 'Bing', 'Picsum', 'Immich', 'Photos', 'Folder', 'URL')) {
        if ($Cfg.Source -eq 'Random' -and $Cfg.Query) { return (Get-Culture).TextInfo.ToTitleCase($Cfg.Query) }
        return 'Random'
    }
    if ($Cfg.Query) { return (Get-Culture).TextInfo.ToTitleCase($Cfg.Query) }
    return 'Random category'
}

function Write-CommandBlock {
    # Prints the command with PowerShell line continuations so it can be pasted.
    param([hashtable]$Cfg)
    $parts = @(Get-CommandParts $Cfg)
    $line = ' '
    $lines = @()
    foreach ($p in $parts) {
        if (($line + ' ' + $p).Length -gt 68 -and $line.Trim()) { $lines += $line; $line = '     ' + $p }
        else { $line = if ($line.Trim()) { $line + ' ' + $p } else { ' ' + $p } }
    }
    $lines += $line
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $suffix = if ($i -lt $lines.Count - 1) { ' `' } else { '' }
        Write-Host ($lines[$i] + $suffix) -ForegroundColor White
    }
}

function Get-KeepLabel {
    param([hashtable]$Cfg)
    if ($Cfg.Source -in @('Photos', 'Folder')) { return 'n/a (files used in place)' }
    if ($Cfg.KeepCurrentOnly) { return 'Current wallpaper only' }
    if ($Cfg.Keep -le 0) { return 'All (nothing is deleted)' }
    return ('Last {0} images' -f $Cfg.Keep)
}

function Show-ConfigSummary {
    param([hashtable]$Cfg)
    $pix = if ($Cfg.MinPixels -gt 0) { '{0} px' -f $Cfg.MinPixels } else { 'Off' }
    $size = Format-Bytes (ConvertTo-Bytes $Cfg.MinSize)
    if ($size -ieq 'off') { $size = 'Off' }
    $quality = if ($Cfg.Source -eq 'Unsplash') {
        if ($Cfg.Format -eq 'png') { 'PNG (lossless)' } else { 'JPG, {0}%' -f $Cfg.Quality }
    } else { 'As delivered (no conversion)' }
    $rows = @(
        @('Source', (Get-SourceLabel $Cfg)),
        @('Search', (Get-QueryLabel $Cfg)),
        @('Min width', ('{0} px' -f $Cfg.MinWidth)),
        @('Min pixels', $pix),
        @('Min file size', $size),
        @('Quality', $quality),
        @('Orientation', (Get-Culture).TextInfo.ToTitleCase($Cfg.Orientation)),
        @('Stored images', (Get-KeepLabel $Cfg)),
        @('Max attempts', [string]$Cfg.MaxAttempts)
    )
    if ($Cfg.Source -eq 'Folder') { $rows += ,@('Folder', $Cfg.Folder) }
    if ($Cfg.Source -eq 'URL') {
        $u = [string]$Cfg.URL
        if ($u.Length -gt 52) { $u = $u.Substring(0, 49) + '...' }
        $rows += ,@('Link / list', $u)
    }
    if ($Cfg.Source -eq 'Immich') { $rows += ,@('Server', (Resolve-ImmichUrl $Cfg)) }
    $run = if ($Cfg.IntervalMinutes -gt 0) { 'Every {0} min (background)' -f $Cfg.IntervalMinutes } else { 'Once' }
    $rows += ,@('Run mode', $run)
    foreach ($r in $rows) {
        Write-Host (" {0,-15}" -f ($r[0] + ':')) -NoNewline -ForegroundColor Gray
        Write-Host $r[1] -ForegroundColor White
    }
}

# =============================================
# PRE-FLIGHT AND RUNNING
# =============================================

function Get-RunProblem {
    # Returns a problem description or $null.
    param([hashtable]$Cfg)
    $src = $Cfg.Source
    if ($KeyServices.Contains($src) -and $KeyServices[$src].Required -and -not (Get-ApiKeySource $src)) {
        return ("{0} needs an API key. Use -SetKey {0} or set {1}." -f $src, $KeyServices[$src].Env)
    }
    if ($src -eq 'Folder' -and [string]::IsNullOrWhiteSpace($Cfg.Folder)) {
        return 'Source Folder needs a path. Use -Folder <path>.'
    }
    if ($src -eq 'Folder' -and -not (Test-Path -LiteralPath $Cfg.Folder -PathType Container)) {
        return ("Folder not found: {0}" -f $Cfg.Folder)
    }
    if ($src -eq 'URL') {
        if ([string]::IsNullOrWhiteSpace($Cfg.URL)) { return 'Source URL needs a link or a .txt list. Use -URL <link or file>.' }
        if ($Cfg.URL -notmatch '^https?://' -and -not (Test-Path -LiteralPath $Cfg.URL -PathType Leaf)) {
            return ("List file not found: {0}" -f $Cfg.URL)
        }
    }
    if ($src -eq 'Immich' -and -not (Resolve-ImmichUrl $Cfg)) {
        return 'Immich needs the server address. Use -ImmichUrl <url>.'
    }
    return $null
}

function Show-CycleResult {
    param([hashtable]$Cfg, [hashtable]$Res)
    $p = $Res.Photo
    $name = Split-Path $Res.File -Leaf
    $author = if ($p.Author) { $p.Author } else { 'Unknown' }
    if ($author.Length -gt 36) { $author = $author.Substring(0, 33) + '...' }

    Write-Host ' Image: ' -NoNewline -ForegroundColor White
    Write-Host $name -NoNewline -ForegroundColor White
    if ($Res.InPlace) {
        Write-Host ' | used in place' -ForegroundColor DarkGray
    } else {
        Write-Host ' | by ' -NoNewline -ForegroundColor DarkGray
        Write-Host $author -NoNewline -ForegroundColor Cyan
        Write-Host (' | Attempt {0}/{1}' -f $Res.Attempt, $Res.MaxAttempts) -ForegroundColor DarkGray
    }
    $ext = [IO.Path]::GetExtension($Res.File).TrimStart('.').ToUpper()
    Write-Host '        Resolution ' -NoNewline -ForegroundColor Gray
    Write-Host ('{0}x{1}' -f $Res.Width, $Res.Height) -NoNewline -ForegroundColor White
    Write-Host (' | {0} | Size ' -f $ext) -NoNewline -ForegroundColor DarkGray
    Write-Host (Format-Bytes $Res.Size) -ForegroundColor Green
    Write-Host '        Source ' -NoNewline -ForegroundColor Gray
    Write-Host $Res.Provider -ForegroundColor White
    if (-not $Res.InPlace) {
        Write-Host '        Saved in ' -NoNewline -ForegroundColor Gray
        Write-Host $Cfg.Dir -ForegroundColor DarkGray
    }
}

function Show-RunInfo {
    param([hashtable]$Cfg)
    $pixels = if ($Cfg.MinPixels -gt 0) { '{0} Mpx' -f [math]::Round($Cfg.MinPixels / 1000000, 1) } else { 'off' }
    $sizeLbl = Format-Bytes (ConvertTo-Bytes $Cfg.MinSize)
    $quality = if ($Cfg.Source -eq 'Unsplash') {
        if ($Cfg.Format -eq 'png') { 'PNG' } else { '{0}%' -f $Cfg.Quality }
    } else { 'as delivered' }
    $keep = if ($Cfg.Source -in @('Photos', 'Folder')) { 'n/a' } elseif ($Cfg.KeepCurrentOnly) { 'Current only' } elseif ($Cfg.Keep -le 0) { 'All' } else { 'Last {0}' -f $Cfg.Keep }

    Write-Host ' Time: ' -NoNewline -ForegroundColor Gray
    Write-Host (Get-Date -Format 'HH:mm:ss') -NoNewline -ForegroundColor Cyan
    Write-Host ' | Source: ' -NoNewline -ForegroundColor Gray
    Write-Host (Get-SourceLabel $Cfg) -NoNewline -ForegroundColor White
    Write-Host ' | Type: ' -NoNewline -ForegroundColor Gray
    Write-Host (Get-QueryLabel $Cfg) -ForegroundColor White

    Write-Host ' Min Width: ' -NoNewline -ForegroundColor Gray
    Write-Host $Cfg.MinWidth -NoNewline -ForegroundColor White
    Write-Host ' | Min Pixels: ' -NoNewline -ForegroundColor Gray
    Write-Host $pixels -NoNewline -ForegroundColor $(if ($Cfg.MinPixels -gt 0) { 'Yellow' } else { 'DarkGray' })
    Write-Host ' | Min Size: ' -NoNewline -ForegroundColor Gray
    Write-Host $sizeLbl -NoNewline -ForegroundColor $(if ($sizeLbl -ne 'off') { 'Yellow' } else { 'DarkGray' })
    Write-Host ' | Quality: ' -NoNewline -ForegroundColor Gray
    Write-Host $quality -ForegroundColor DarkGray

    Write-Host ' Orientation: ' -NoNewline -ForegroundColor Gray
    Write-Host (Get-Culture).TextInfo.ToTitleCase($Cfg.Orientation) -NoNewline -ForegroundColor White
    Write-Host ' | Max Attempts: ' -NoNewline -ForegroundColor Gray
    Write-Host $Cfg.MaxAttempts -NoNewline -ForegroundColor White
    Write-Host ' | Keep: ' -NoNewline -ForegroundColor Gray
    Write-Host $keep -ForegroundColor White
    Write-Host ''
}

function Stop-BackgroundForOnce {
    # A one-time wallpaper replaces the scheduled changer so it does not override it.
    $had = (Test-TrayRunning) -or (Test-Path -LiteralPath $script:BgConfigFile) -or (Test-AutostartEnabled)
    if (-not $had) { return $false }
    [void](Stop-Tray)
    Remove-BackgroundSettings
    return $true
}

function Invoke-OnceInteractive {
    param([hashtable]$Cfg)
    Show-Header
    Show-ScreenTitle '[RUN] CHANGING YOUR WALLPAPER'
    Write-Host ''
    if (Stop-BackgroundForOnce) {
        Write-Host ' The background changer was stopped and removed from startup.' -ForegroundColor Yellow
        Write-Host ''
    }
    Show-RunInfo $Cfg
    Write-Host ' Looking for a suitable image...' -ForegroundColor Yellow
    Write-Host ''

    $res = Invoke-Cycle -Cfg $Cfg
    if ($res.Ok) {
        Show-CycleResult -Cfg $Cfg -Res $res
        Write-Host ''
        Write-Host ' Wallpaper changed successfully.' -ForegroundColor Green
        $script:ExitCode = 0
    } else {
        Write-Host ' Could not set a new wallpaper.' -ForegroundColor Red
        Write-Host (' ' + ($res.Error -replace '(Blocked by the site\.) (Download)', "`$1`n `$2")) -ForegroundColor Red
        Write-Host (' Details: {0}' -f (Get-ShortPath $script:LogFile)) -ForegroundColor Gray
        $script:ExitCode = 1
    }
    Write-Host ''
    Wait-AnyKey " Press any key to continue to the credits screen..."
    Show-FinalCredits
}

function Invoke-BackgroundSetupInteractive {
    param([hashtable]$Cfg)
    Show-Header
    Show-ScreenTitle '[BACKGROUND] STARTING THE BACKGROUND CHANGER'
    Write-Host ''
    Show-ConfigSummary $Cfg
    Write-Host ''
    if ($Cfg.Source -eq 'Unsplash' -and $Cfg.IntervalMinutes -lt 5) {
        Write-Host ' WARNING: Unsplash allows 50 requests per hour. An interval under' -ForegroundColor Yellow
        Write-Host ' 5 minutes can hit the limit; changes then pause for about an hour.' -ForegroundColor Yellow
        Write-Host ''
    }
    Write-Host ' Installing a stable copy of the script and enabling start at sign-in...' -ForegroundColor Yellow
    try {
        Initialize-Background -Cfg $Cfg
    } catch {
        Write-Host (' ERROR: {0}' -f $_.Exception.Message) -ForegroundColor Red
        Write-Host ' Details:' -ForegroundColor Gray
        Write-Host (' ' + (Get-ShortPath $script:LogFile)) -ForegroundColor Gray
        Write-Host ''
        Wait-AnyKey " Press any key to exit..."
        exit 1
    }
    $ps1 = ".\$ToolFileName.ps1"
    Write-Host ''
    Write-Host ' The background changer is running (see the tray icon).' -ForegroundColor Green
    Write-Host (' The first change happens in a few seconds, then every {0} min.' -f $Cfg.IntervalMinutes) -ForegroundColor Green
    Write-Host ' You can close this window now.' -ForegroundColor Green
    Write-Host ''
    Write-Host ' Manage it with:' -ForegroundColor Cyan
    Write-Host ''
    Write-Host "   $ps1 -Background Status" -ForegroundColor White
    Write-Host '       Show what the background changer is doing.' -ForegroundColor Gray
    Write-Host ''
    Write-Host "   $ps1 -Background Pause" -ForegroundColor White
    Write-Host '       Pause the changes until you resume them.' -ForegroundColor Gray
    Write-Host ''
    Write-Host "   $ps1 -Background Resume" -ForegroundColor White
    Write-Host '       Continue after a pause.' -ForegroundColor Gray
    Write-Host ''
    Write-Host "   $ps1 -Background Stop" -ForegroundColor White
    Write-Host '       Stop it and remove its settings and start at sign-in.' -ForegroundColor Gray
    Write-Host ''
    Write-Host ' Back to start [S] or exit [X].' -ForegroundColor Gray
    Write-Host ''
    $null = Read-MenuChoice -Prompt 'Your choice [S/X]' -Valid @('S','X') -Default 'X'
    Exit-WithCredits
    exit 0
}

function Invoke-Run {
    # Interactive run of a configuration (same window).
    param([hashtable]$Cfg)
    $problem = Get-RunProblem $Cfg
    if ($problem) {
        Write-Host ''
        Write-Host (' ' + $problem) -ForegroundColor Red
        Write-Host ' Use -help or -h to see available options.' -ForegroundColor Gray
        Write-Host ''
        exit 1
    }
    if ($Cfg.IntervalMinutes -gt 0) { Invoke-BackgroundSetupInteractive $Cfg }
    else { Invoke-OnceInteractive $Cfg }
}

function Invoke-QuietRun {
    # No screens, no prompts, no credits.
    param([hashtable]$Cfg)
    $problem = Get-RunProblem $Cfg
    if ($problem) { Write-Log $problem 'ERROR'; exit 1 }
    if ($Cfg.IntervalMinutes -gt 0) {
        try { Initialize-Background -Cfg $Cfg } catch { Write-Log $_.Exception.Message 'ERROR'; exit 1 }
        exit 0
    }
    $res = Invoke-Cycle -Cfg $Cfg
    if ($res.Ok) { exit 0 }
    exit 1
}

# =============================================
# MANAGEMENT COMMANDS (keys, JPEG quality, background)
# =============================================

function Invoke-ManagementCommands {
    # Returns an exit code, or $null when no management command was given.
    if ($Cli.ContainsKey('JpegImportQuality')) {
        if (-not $script:Quiet) { Show-Header }
        return (Invoke-JpegImportQualityCommand)
    }
    if ($Flags.Keys) {
        if (-not $script:Quiet) {
            Show-Header
            Show-ScreenTitle 'API KEY MANAGEMENT'
            Write-Host ''
            Show-KeyTable
            Write-Host ''
            Write-Host ' Keys are stored encrypted (DPAPI) for the current Windows user.' -ForegroundColor Gray
            Write-Host ' Add: -SetKey <service>   Remove: -RemoveKey <service|All>' -ForegroundColor Gray
            Write-Host ''
        }
        return 0
    }
    if ($Cli.ContainsKey('SetKey')) {
        $svc = $Cli.SetKey
        if (-not $script:Quiet) { Show-Header; Show-ScreenTitle 'API KEY MANAGEMENT'; Write-Host '' }
        if ($svc -eq 'Immich' -and -not $script:Quiet) {
            $cur = Get-StoredImmichUrl
            $u = if ($Cli.ContainsKey('ImmichUrl')) { $Cli.ImmichUrl } else { (Read-Host (" Immich server address [{0}]" -f $cur)).Trim().TrimEnd('/') }
            if (-not $u) { $u = $cur }
            if ($u -notmatch '^https?://\S+$') { Write-Host ' Invalid address (expected http:// or https://).' -ForegroundColor Red; return 1 }
            Set-StoredImmichUrl $u
        }
        if (Read-ApiKeyInteractive -Service $svc) {
            Write-Host (" {0} key stored (encrypted for this Windows user)." -f $svc) -ForegroundColor Green
            Write-Host ''
            return 0
        }
        Write-Host ' No key stored.' -ForegroundColor Yellow
        Write-Host ''
        return 1
    }
    if ($Cli.ContainsKey('RemoveKey')) {
        $svc = $Cli.RemoveKey
        $targets = if ($svc -eq 'All') { @($KeyServices.Keys) } else { @($svc) }
        $envCleared = @(); $stillSet = @()
        foreach ($t in $targets) {
            Remove-ApiKey $t
            $envName = $KeyServices[$t].Env
            try {
                if ([Environment]::GetEnvironmentVariable($envName, 'User')) {
                    [Environment]::SetEnvironmentVariable($envName, $null, 'User')
                    $envCleared += $envName
                }
                [Environment]::SetEnvironmentVariable($envName, $null, 'Process')
            } catch { }
            if (Get-ApiKeySource $t) { $stillSet += $envName }
        }
        if (-not $script:Quiet) {
            Show-Header
            Show-ScreenTitle 'API KEY MANAGEMENT'
            Write-Host ''
            Write-Host (' Key removed: {0}' -f ($targets -join ', ')) -ForegroundColor Green
            if ($envCleared.Count -gt 0) {
                Write-Host (' User environment variable cleared: {0}' -f ($envCleared -join ', ')) -ForegroundColor Green
            }
            if ($stillSet.Count -gt 0) {
                Write-Host (' Still set (system-wide variable): {0}' -f ($stillSet -join ', ')) -ForegroundColor Yellow
                Write-Host ' Remove it in System Properties > Environment Variables.' -ForegroundColor Yellow
            }
            Write-Host ''
        }
        return 0
    }
    if ($Cli.ContainsKey('Background')) {
        if (-not $script:Quiet) {
            Show-Header
            Show-ScreenTitle '[BACKGROUND] BACKGROUND CHANGER'
            Write-Host ''
        }
        $code = Invoke-BackgroundCommand $Cli.Background
        if (-not $script:Quiet) { Write-Host '' }
        return $code
    }
    return $null
}

# =============================================
# START SCREEN
# =============================================

function Read-MenuChoice {
    param([string]$Prompt, [string[]]$Valid, [string]$Default)
    while ($true) {
        $raw = Read-Nav $Prompt
        if ($raw -eq '' -and $Default) { $raw = $Default }
        if ($Valid -contains $raw.ToUpper()) { return $raw.ToUpper() }
        $list = if ($Valid.Count -gt 1) { (($Valid | Select-Object -First ($Valid.Count - 1)) -join ', ') + ' or ' + $Valid[-1] } else { [string]$Valid[0] }
        Write-Host (" Enter one of: {0}." -f $list) -ForegroundColor Red
    }
}

function Show-BackgroundMenu {
    while ($true) {
        Show-Header
        Show-ScreenTitle '[BACKGROUND] BACKGROUND CHANGER'
        Write-Host ''
        Show-BackgroundStatus
        Write-Host ''
        $running = Test-TrayRunning
        $st = Read-TrayState
        $paused = [bool]($st -and $st.Paused)
        # Every option is listed; the ones that do not apply now are grey and cannot be chosen.
        $options = @(
            @{ Key = '1'; Text = 'Change the wallpaper now';          On = $running },
            @{ Key = '2'; Text = $(if ($paused) { 'Resume' } else { 'Pause' }); On = $running },
            @{ Key = '3'; Text = 'Stop and remove its settings';      On = $running },
            @{ Key = '4'; Text = 'Start it again';                    On = (-not $running) },
            @{ Key = '5'; Text = 'Remove its settings';               On = (-not $running) }
        )
        $valid = @()
        foreach ($o in $options) {
            $color = if ($o.On) { 'White' } else { 'DarkGray' }
            Write-Host (' [{0}] {1}' -f $o.Key, $o.Text) -ForegroundColor $color
            if ($o.On) { $valid += $o.Key }
        }
        Write-Host ''
        Write-WizardFooter 'Enter a number and press Enter.'
        $c = Read-MenuChoice -Prompt 'Your choice' -Valid $valid
        Write-Host ''
        switch ($c) {
            '1' { Send-TrayCommand 'change'; Write-Host ' Requested. The change happens within a few seconds.' -ForegroundColor Green; Start-Sleep -Seconds 2 }
            '2' { [void](Invoke-BackgroundCommand $(if ($paused) { 'Resume' } else { 'Pause' })); Start-Sleep -Seconds 1 }
            '3' { [void](Invoke-BackgroundCommand 'Stop'); Start-Sleep -Seconds 2; return }
            '4' { [void](Invoke-BackgroundCommand 'Start'); Start-Sleep -Seconds 1 }
            '5' { [void](Invoke-BackgroundCommand 'Stop'); Start-Sleep -Seconds 2; return }
        }
    }
}

function Show-StartScreen {
    while ($true) {
        $items = @(
            @{ Key = 'Wizard'; Title = 'Wallpaper Changer Wizard'; Desc = 'Choose a source, filters and a schedule step by step.' },
            @{ Key = 'Random'; Title = 'Set one random 4K wallpaper now'; Desc = 'Bing, Picsum or Wallhaven. Free, no API key needed.' }
        )
        if (Test-Path -LiteralPath (Get-ProfilePath 'default')) {
            $items += @{ Key = 'Profile'; Title = 'Run your saved profile (default)'; Desc = 'The settings you saved in the wizard.' }
        }
        if (Test-Path -LiteralPath $script:BgConfigFile) {
            $state = if (Test-TrayRunning) { 'running' } else { 'stopped' }
            $items += @{ Key = 'Manage'; Title = ('Manage the background changer ({0})' -f $state); Desc = 'Status, pause, resume or stop it.' }
        }
        $items += @{ Key = 'Keys'; Title = 'Manage API keys'; Desc = 'Add or remove keys for services that need one.' }

        Show-Header
        Show-ScreenTitle '[START] WHAT WOULD YOU LIKE TO DO?'
        Write-Host ''
        for ($i = 0; $i -lt $items.Count; $i++) {
            Write-Host (' [{0}] {1}' -f ($i + 1), $items[$i].Title) -ForegroundColor Yellow
            Write-Host ('     ' + $items[$i].Desc) -ForegroundColor Gray
            Write-Host ''
        }
        Write-Host ' Enter a number and press Enter, or press [X] to exit.' -ForegroundColor Gray
        Write-Host ''
        $valid = @(1..$items.Count | ForEach-Object { [string]$_ }) + 'X'
        $script:NavStartAllowed = $false
        $c = Read-MenuChoice -Prompt ('Your choice [1-{0}]' -f $items.Count) -Valid $valid
        $script:NavStartAllowed = $true

        switch ($items[[int]$c - 1].Key) {
            'Wizard' { Invoke-Wizard; return }
            'Random' {
                $cfg = Merge-Config -Base (New-DefaultConfig) -Over $Cli
                Invoke-Run $cfg
                return
            }
            'Profile' {
                $p = Read-ConfigFile -Path (Get-ProfilePath 'default')
                $cfg = Merge-Config -Base (New-DefaultConfig) -Over $p
                Invoke-Run $cfg
                return
            }
            'Manage' { Show-BackgroundMenu }
            'Keys'   { Show-KeyManagementScreen }
        }
    }
}

# =============================================
# WIZARD
# =============================================

function Show-WizardScreen {
    param([int]$Step, [int]$Total, [string]$StepTitle)
    Show-Header
    Show-ScreenTitle '[WIZARD] WALLPAPER SETUP'
    Write-Host (" Step {0}/{1} - {2}" -f $Step, $Total, $StepTitle) -ForegroundColor Yellow
    Write-Host ''
}

function Write-WizardFooter {
    param([string]$Hint = 'Press Enter to continue.')
    Write-Host (' ' + $Hint) -ForegroundColor Gray
    Write-Host ' Back to start [S] or exit [X].' -ForegroundColor Gray
    Write-Host ''
}

function Show-KeyTableNumbered {
    param([string[]]$Names)
    Write-Host ('     {0,-9} {1,-20} {2,-12} {3}' -f 'SERVICE', 'ENVIRONMENT VARIABLE', 'STATUS', '') -ForegroundColor Gray
    Write-Host (' ' + ('-' * 70)) -ForegroundColor DarkGray
    for ($i = 0; $i -lt $Names.Count; $i++) {
        $svc = $Names[$i]
        $info = $KeyServices[$svc]
        $src = Get-ApiKeySource $svc
        Write-Host (' [{0}] {1,-9} {2,-20} ' -f ($i + 1), $svc, $info.Env) -NoNewline -ForegroundColor White
        if ($src) {
            $label = if ($src -eq 'Environment') { 'SET (env)' } else { 'SET (stored)' }
            Write-Host ('{0,-12} ' -f $label) -NoNewline -ForegroundColor Green
        } else {
            Write-Host ('{0,-12} ' -f 'NOT SET') -NoNewline -ForegroundColor Red
        }
        if ($info.Note -and -not $src) { Write-Host $info.Note -ForegroundColor $info.Color } else { Write-Host '' }
    }
}

function Clear-ApiKeyEverywhere {
    # Removes the stored key and the User environment variable. Returns a result hashtable.
    param([string]$Service)
    $envName = $KeyServices[$Service].Env
    $res = @{ EnvCleared = $false; StillSet = $false }
    Remove-ApiKey $Service
    try {
        if ([Environment]::GetEnvironmentVariable($envName, 'User')) {
            [Environment]::SetEnvironmentVariable($envName, $null, 'User')
            $res.EnvCleared = $true
        }
        [Environment]::SetEnvironmentVariable($envName, $null, 'Process')
    } catch { }
    if (Get-ApiKeySource $Service) { $res.StillSet = $true }
    return $res
}

function Read-ServiceKeyAndStore {
    # Asks for the key (hidden), stores it. Returns a message hashtable.
    param([string]$Service)
    if ($Service -eq 'Immich') {
        $cur = Get-StoredImmichUrl
        $u = (Read-Nav ("Immich server address [{0}]" -f $cur)).TrimEnd('/')
        if (-not $u) { $u = $cur }
        if ($u -notmatch '^https?://\S+$') { return @{ Text = 'Invalid address (expected http:// or https://).'; Color = 'Red' } }
        Set-StoredImmichUrl $u
    }
    $secure = Read-Host (" Paste your {0} key (hidden; Enter cancels)" -f $Service) -AsSecureString
    $plain = ''
    if ($secure -and $secure.Length -gt 0) { $plain = (ConvertFrom-SecureToPlain $secure).Trim() }
    if ($plain -eq '') { return @{ Text = 'Cancelled. No key stored.'; Color = 'Yellow' } }
    if ($plain.Length -eq 1) { Invoke-Nav $plain }
    try {
        if (Set-ApiKey -Service $Service -Secure $secure) {
            return @{ Text = ("{0} key stored (encrypted for this Windows user)." -f $Service); Color = 'Green' }
        }
    } catch {
        return @{ Text = ("Could not store the key: {0}" -f $_.Exception.Message); Color = 'Red' }
    }
    return @{ Text = 'No key stored.'; Color = 'Yellow' }
}

function Edit-ApiKey {
    # One service: add the key when missing, replace or remove it when set. Returns a message hashtable.
    param([string]$Service)
    $info = $KeyServices[$Service]
    $src = Get-ApiKeySource $Service
    Show-Header
    Show-ScreenTitle '[KEYS] API KEY MANAGEMENT'
    Write-Host (' {0} ({1})' -f $Service, $info.Env) -ForegroundColor Yellow
    Write-Host ''
    if (-not $src) {
        Write-Host ' No key is set.' -ForegroundColor Red
        Write-Host ''
        Write-Host ' Back to start [S] or exit [X].' -ForegroundColor Gray
        Write-Host ''
        return (Read-ServiceKeyAndStore $Service)
    }
    if ($src -eq 'Stored') {
        Write-Host ' A key is stored (encrypted, never shown).' -ForegroundColor Green
    } else {
        Write-Host (' The key comes from the environment variable {0}.' -f $info.Env) -ForegroundColor Green
    }
    Write-Host ''
    Write-Host ' [1] Replace the key' -ForegroundColor White
    Write-Host ' [2] Remove the key' -ForegroundColor White
    Write-Host ' [B] Back' -ForegroundColor White
    Write-Host ''
    Write-Host ' Back to start [S] or exit [X].' -ForegroundColor Gray
    Write-Host ''
    $c = Read-MenuChoice -Prompt 'Your choice' -Valid @('1', '2', 'B') -Default 'B'
    switch ($c) {
        '1' {
            if ($src -eq 'Environment') {
                $r = Clear-ApiKeyEverywhere $Service
                if ($r.StillSet) { return @{ Text = ("{0} is set system-wide. Remove it in System Properties > Environment Variables." -f $info.Env); Color = 'Yellow' } }
            }
            return (Read-ServiceKeyAndStore $Service)
        }
        '2' {
            $r = Clear-ApiKeyEverywhere $Service
            if ($r.StillSet) { return @{ Text = ("{0} is set system-wide. Remove it in System Properties > Environment Variables." -f $info.Env); Color = 'Yellow' } }
            $extra = if ($r.EnvCleared) { ' User environment variable cleared too.' } else { '' }
            return @{ Text = ("{0} key removed.{1}" -f $Service, $extra); Color = 'Green' }
        }
    }
    return $null
}

function Show-KeyManagementScreen {
    # Service = '' : opened from the start screen, returns when done.
    # Service = name : wizard step; returns $true when that service has a key,
    #                  $false to choose another service.
    param([string]$Service = '', [int]$Step = 0, [int]$Total = 0)
    $names = @($KeyServices.Keys)
    $msg = $null
    while ($true) {
        Show-Header
        if ($Service) {
            Show-ScreenTitle '[WIZARD] API KEY MANAGEMENT'
            Write-Host (" Step {0}/{1} - {2} needs an API key" -f $Step, $Total, $Service) -ForegroundColor Yellow
        } else {
            Show-ScreenTitle '[KEYS] API KEY MANAGEMENT'
        }
        Write-Host ''
        Show-KeyTableNumbered $names
        Write-Host ''
        Write-Host ' Keys are stored encrypted (DPAPI) for your Windows user and' -ForegroundColor Gray
        Write-Host ' are never shown. An environment variable works as well.' -ForegroundColor Gray
        Write-Host ''
        if ($msg) { Write-Host (' ' + $msg.Text) -ForegroundColor $msg.Color; Write-Host '' }
        Write-Host ' Enter a number to add, replace or remove that key.' -ForegroundColor Gray
        if ($Service) { Write-Host ' [B] Use another service. Back to start [S] or exit [X].' -ForegroundColor Gray }
        else { Write-Host ' Back to start [S] or exit [X].' -ForegroundColor Gray }
        Write-Host ''
        $valid = @(1..$names.Count | ForEach-Object { [string]$_ }) + 'B'
        $c = Read-MenuChoice -Prompt ('Your choice [1-{0}]' -f $names.Count) -Valid $valid -Default 'B'
        if ($c -eq 'B') { if ($Service) { return $false } else { return } }
        $msg = Edit-ApiKey $names[[int]$c - 1]
        if ($Service -and (Get-ApiKeySource $Service)) { return $true }
    }
}

function Read-WizardSource {
    # Step 1. Returns the source name.
    param([int]$Total)
    $map = @{ '1' = 'Bing'; '2' = 'Picsum'; '3' = 'Wallhaven'; '4' = 'Photos'; '5' = 'Folder'
              '6' = 'Flickr'; '7' = 'Immich'; '8' = 'Pexels'; '9' = 'Pixabay'; '10' = 'Unsplash'; '11' = 'URL' }
    while ($true) {
        Show-WizardScreen -Step 1 -Total $Total -StepTitle 'Image source'
        Write-Host ' Online - no API key needed' -ForegroundColor Cyan
        Write-Host '   [1]  Bing       Image archive, always random'
        Write-Host '   [2]  Picsum     Random photos'
        Write-Host ("   [3]  {0,-10} {1,-27}" -f 'Wallhaven', 'Safe wallpaper search') -NoNewline
        if (Get-ApiKeySource 'Wallhaven') { Write-Host '[KEY SET]' -ForegroundColor Green } else { Write-Host '[NOT SET]' -ForegroundColor Red }
        Write-Host ''
        Write-Host ' Local - your own pictures (used in place, never deleted)' -ForegroundColor Cyan
        Write-Host '   [4] Windows Photos Folder   Your Pictures folder'
        Write-Host '   [5] Custom Folder           Any folder you choose'
        Write-Host ''
        Write-Host ' Online - API key required' -ForegroundColor Cyan
        $notes = @{
            Flickr = 'experimental'; Immich = 'experimental, own server'
            Pexels = 'new keys currently paused'; Pixabay = 'free API: up to 1280 px'
            Unsplash = '50 requests per hour'
        }
        foreach ($n in 6..10) {
            $svc = $map[[string]$n]
            Write-Host ("   [{0}]{1}{2,-10} {3,-27}" -f $n, $(if ($n -ge 10) { ' ' } else { '  ' }), $svc, $notes[$svc]) -NoNewline
            if (Get-ApiKeySource $svc) { Write-Host '[KEY SET]' -ForegroundColor Green } else { Write-Host '[NOT SET]' -ForegroundColor Red }
        }
        Write-Host ''
        Write-Host ' Online - your own links' -ForegroundColor Cyan
        Write-Host '   [11] Image link / .txt list  Direct links to jpg or png files'
        Write-Host ''
        Write-WizardFooter 'Enter a number, or press Enter for the default (1 = Bing).'
        $c = Read-MenuChoice -Prompt 'Your choice [1-11]' -Valid @($map.Keys) -Default '1'
        $svc = $map[$c]
        if ($KeyServices.Contains($svc) -and $KeyServices[$svc].Required -and -not (Get-ApiKeySource $svc)) {
            if (-not (Show-KeyManagementScreen -Service $svc -Step 1 -Total $Total)) { continue }
        }
        return $svc
    }
}

function Invoke-WizardCollect {
    # Collects all settings. Returns the configuration.
    $cfg = New-DefaultConfig
    $total = 10   # provisional, only used for the first screen
    $cfg.Source = Read-WizardSource -Total $total
    $src = $cfg.Source
    $isLocal = $src -in @('Photos', 'Folder')

    $steps = @()
    if ($src -eq 'Folder') { $steps += 'Folder' }
    if ($src -eq 'URL') { $steps += 'URL' }
    if ($src -eq 'Immich') { $steps += 'ImmichUrl' }
    if (-not $isLocal -and $src -ne 'URL') { $steps += 'Query' }
    $steps += @('MinWidth', 'MinPixels', 'MinSize')
    if ($src -eq 'Unsplash') { $steps += @('Quality', 'Format') }
    $steps += 'Orientation'
    if (-not $isLocal) { $steps += 'Keep' }
    $steps += @('MaxAttempts', 'RunMode')
    $total = 1 + $steps.Count
    $n = 1

    foreach ($s in $steps) {
        $n++
        switch ($s) {
            'Folder' {
                Show-WizardScreen $n $total 'Folder'
                Write-Host ' Enter the full path of the folder with your images.' -ForegroundColor Gray
                Write-Host ' Subfolders are included. Files are used in place, never' -ForegroundColor Gray
                Write-Host ' copied or deleted. Supported: jpg, png, bmp.' -ForegroundColor Gray
                Write-Host ''
                Write-WizardFooter 'Type the folder path and press Enter.'
                $cfg.Folder = Read-Validated -Prompt 'Folder' -ErrorText 'Folder not found. Enter an existing folder.' -Validate {
                    param($t)
                    $t = $t.Trim('"')
                    if ($t -and (Test-Path -LiteralPath $t -PathType Container)) { return @{ Ok = $true; Value = (Resolve-Path -LiteralPath $t).Path } }
                    return @{ Ok = $false }
                }
            }
            'URL' {
                Show-WizardScreen $n $total 'Image link or list'
                Write-Host ' Enter a direct link to an image (jpg, png, bmp), or a .txt' -ForegroundColor Gray
                Write-Host ' list with one link per line (a file path or a link).' -ForegroundColor Gray
                Write-Host ' Lines that do not start with http:// or https:// are ignored.' -ForegroundColor Gray
                Write-Host ' Links must point to the image file itself, not to a web page.' -ForegroundColor Gray
                Write-Host ''
                Write-WizardFooter 'Type the link or the list file path and press Enter.'
                $cfg.URL = Read-Validated -Prompt 'Link or list' -ErrorText 'Enter an http(s) link or an existing .txt file.' -Validate {
                    param($t)
                    $t = $t.Trim('"')
                    if ($t -match '^https?://\S+$') { return @{ Ok = $true; Value = $t } }
                    if ($t -and (Test-Path -LiteralPath $t -PathType Leaf)) { return @{ Ok = $true; Value = (Resolve-Path -LiteralPath $t).Path } }
                    return @{ Ok = $false }
                }
            }
            'ImmichUrl' {
                $cur = Get-StoredImmichUrl
                Show-WizardScreen $n $total 'Immich server address'
                Write-Host ' Address of your Immich server, for example https://photos.lan' -ForegroundColor Gray
                Write-Host ' Experimental: random images from your library are used.' -ForegroundColor Yellow
                Write-Host ''
                Write-WizardFooter 'Type the address and press Enter.'
                $prompt = if ($cur) { "Server address [$cur]" } else { 'Server address' }
                $cfg.ImmichUrl = Read-Validated -Prompt $prompt -Default $cur -ErrorText 'Enter an address starting with http:// or https://.' -Validate {
                    param($t)
                    if ($t -match '^https?://\S+$') { return @{ Ok = $true; Value = $t.TrimEnd('/') } }
                    return @{ Ok = $false }
                }
                Set-StoredImmichUrl $cfg.ImmichUrl
            }
            'Query' {
                Show-WizardScreen $n $total 'Search phrase'
                if (Test-SourceSupportsQuery $src) {
                    Write-Host ' Enter a search phrase, for example: forest, mountains, city.' -ForegroundColor Gray
                    Write-Host ''
                    Write-Host ' Leave it empty for a random category:' -ForegroundColor Gray
                    Write-Host ' Nature, Abstract, Minimalist, Anime or Cyberpunk.' -ForegroundColor Gray
                    Write-Host ''
                    Write-WizardFooter 'Type a phrase, or press Enter for a random category (default).'
                    $cfg.Query = Read-Nav 'Search phrase [random category]'
                } else {
                    $why = switch ($src) {
                        'Bing'   { 'Bing always delivers its own images. Every image is random.' }
                        'Picsum' { 'Picsum has no search. Every image is random.' }
                        'Immich' { 'Immich is used without search. Random images from your library.' }
                    }
                    Write-Host (' ' + $why) -ForegroundColor Yellow
                    Write-Host ' Services with search: Wallhaven, Flickr, Pexels, Pixabay, Unsplash.' -ForegroundColor Gray
                    Write-Host ''
                    Write-WizardFooter
                    [void](Read-Nav 'Press Enter to continue')
                }
            }
            'MinWidth' {
                Show-WizardScreen $n $total 'Minimum image width'
                Write-Host ' Smallest acceptable image width in pixels:' -ForegroundColor Gray
                Write-Host ''
                Write-Host ' [1] Resolution 16K     = 15360'
                Write-Host ' [2] Resolution 8K      = 7680'
                Write-Host ' [3] Resolution 4K      = 3840'
                Write-Host ' [4] Resolution 1440p   = 2560'
                Write-Host ' [5] Resolution FHD     = 1920'
                Write-Host ' [6] Resolution HD      = 1280'
                Write-Host '     Other resolution   = Custom (type a number)'
                Write-Host ''
                if ($src -eq 'Pixabay') { Write-Host ' Pixabay free API delivers at most 1280 px.' -ForegroundColor Yellow; Write-Host '' }
                if ($isLocal) { Write-Host ' Smaller images in your folder are skipped.' -ForegroundColor Gray; Write-Host '' }
                Write-WizardFooter 'Pick [1-6], type a value, or press Enter for 3840 (4K).'
                $widthMap = @{ '1' = '15360'; '2' = '7680'; '3' = '3840'; '4' = '2560'; '5' = '1920'; '6' = '1280' }
                $cfg.MinWidth = Read-Validated -Prompt 'Minimum width [3840]' -Default '3840' -ErrorText 'Enter 1-6 or a number from 320 to 16384.' -Validate {
                    param($t)
                    if ($widthMap.ContainsKey($t)) { $t = $widthMap[$t] }
                    $v = Test-ArgValue -Key 'MinWidth' -Value $t
                    if ($null -ne $v) { return @{ Ok = $true; Value = $v } }
                    return @{ Ok = $false }
                }
            }
            'MinPixels' {
                Show-WizardScreen $n $total 'Minimum pixels'
                Write-Host ' Smallest acceptable width x height in pixels.' -ForegroundColor Gray
                Write-Host ''
                Write-Host ' [1] 15360x8640 (16K)   = 132710400'
                Write-Host ' [2] 7680x4320  (8K)    = 33177600'
                Write-Host ' [3] 3840x2160  (4K)    = 8294400'
                Write-Host ' [4] 2560x1440  (1440p) = 3686400'
                Write-Host ' [5] 1920x1080  (FHD)   = 2073600'
                Write-Host ' [6] 1280x720   (HD)    = 921600'
                Write-Host ' [0] or Enter           = Off'
                Write-Host '     Other              = Custom (type a number)'
                Write-Host ''
                Write-WizardFooter 'Pick [1-6], type a value, or press Enter for Off (0).'
                $pixMap = @{ '1' = '132710400'; '2' = '33177600'; '3' = '8294400'; '4' = '3686400'; '5' = '2073600'; '6' = '921600' }
                $cfg.MinPixels = Read-Validated -Prompt 'Minimum pixels [0]' -Default '0' -ErrorText 'Enter 0-6 or a whole number.' -Validate {
                    param($t)
                    if ($pixMap.ContainsKey($t)) { $t = $pixMap[$t] }
                    $v = Test-ArgValue -Key 'MinPixels' -Value $t
                    if ($null -ne $v) { return @{ Ok = $true; Value = $v } }
                    return @{ Ok = $false }
                }
            }
            'MinSize' {
                Show-WizardScreen $n $total 'Minimum file size'
                Write-Host ' Smallest acceptable file size. Tiny files are usually low quality.' -ForegroundColor Gray
                Write-Host ''
                Write-Host ' [1] 100K   = Very small image'
                Write-Host ' [2] 500K   = Small image'
                Write-Host ' [3] 1M     = Medium image'
                Write-Host ' [4] 2.5M   = Good quality FHD image (default)'
                Write-Host ' [5] 5M     = Large image (good for 4K)'
                Write-Host ' [6] 10M    = Very large image'
                Write-Host ' [0] Off    = No minimum size'
                Write-Host '     Custom   (type a value, for example 3.5M)'
                Write-Host ''
                Write-WizardFooter 'Pick [0-6], type a value, or press Enter for default (2.5M).'
                $sizeMap = @{ '0' = '0'; '1' = '100K'; '2' = '500K'; '3' = '1M'; '4' = '2.5M'; '5' = '5M'; '6' = '10M' }
                $cfg.MinSize = Read-Validated -Prompt 'Minimum file size [2.5M]' -Default '4' -ErrorText 'Use 0-6 or a value like 750K, 1M or 2.5M.' -Validate {
                    param($t)
                    if ($sizeMap.ContainsKey($t)) { $t = $sizeMap[$t] }
                    $v = Test-ArgValue -Key 'MinSize' -Value $t
                    if ($null -ne $v) { return @{ Ok = $true; Value = $v } }
                    return @{ Ok = $false }
                }
            }
            'Quality' {
                Show-WizardScreen $n $total 'JPG/PNG quality'
                Write-Host ' Compression quality of the image Unsplash converts for you.' -ForegroundColor Gray
                Write-Host ' It applies to JPG; PNG is always lossless.' -ForegroundColor Gray
                Write-Host ''
                Write-Host ' [1] 60%  = Small size, visible compression'
                Write-Host ' [2] 70%  = Compact, some detail lost'
                Write-Host ' [3] 80%  = Balanced size and quality'
                Write-Host ' [4] 90%  = Good quality'
                Write-Host ' [5] 95%  = Very good (default)'
                Write-Host ' [6] 100% = Practically lossless'
                Write-Host '     Custom (type a value from 1 to 100, for example 75)'
                Write-Host ''
                Write-WizardFooter 'Pick [1-6], type a value, or press Enter for default (95).'
                $qMap = @{ '1' = '60'; '2' = '70'; '3' = '80'; '4' = '90'; '5' = '95'; '6' = '100' }
                $cfg.Quality = Read-Validated -Prompt 'Quality [95]' -Default '95' -ErrorText 'Enter 1-6 or a number from 1 to 100.' -Validate {
                    param($t)
                    if ($qMap.ContainsKey($t)) { $t = $qMap[$t] }
                    $v = Test-ArgValue -Key 'Quality' -Value $t
                    if ($null -ne $v) { return @{ Ok = $true; Value = $v } }
                    return @{ Ok = $false }
                }
            }
            'Format' {
                Show-WizardScreen $n $total 'File format'
                Write-Host ' Format of the image that Unsplash converts for you:' -ForegroundColor Gray
                Write-Host ''
                Write-Host '   [1] JPG   Smaller files' -ForegroundColor White
                Write-Host '   [2] PNG   Lossless, much larger files' -ForegroundColor White
                Write-Host ''
                Write-WizardFooter 'Enter 1 or 2, or press Enter for the default (1 = JPG).'
                $c = Read-MenuChoice -Prompt 'Your choice [1]' -Valid @('1', '2') -Default '1'
                $cfg.Format = if ($c -eq '2') { 'png' } else { 'jpg' }
            }
            'Orientation' {
                Show-WizardScreen $n $total 'Orientation'
                Write-Host ' Which images do you want?' -ForegroundColor Gray
                Write-Host ''
                Write-Host '   [1] Landscape   Wide images (normal monitors)' -ForegroundColor White
                Write-Host '   [2] Portrait    Tall images (width limit applies to height)' -ForegroundColor White
                Write-Host '   [3] Squarish    Almost square images' -ForegroundColor White
                Write-Host ''
                Write-WizardFooter 'Enter 1-3, or press Enter for the default (1 = Landscape).'
                $c = Read-MenuChoice -Prompt 'Your choice [1]' -Valid @('1', '2', '3') -Default '1'
                $cfg.Orientation = @('landscape', 'portrait', 'squarish')[[int]$c - 1]
            }
            'Keep' {
                Show-WizardScreen $n $total 'Max kept images'
                Write-Host ' Maximum number of the newest images kept in the wallpapers' -ForegroundColor Gray
                Write-Host ' folder. Older ones are deleted. The current wallpaper is' -ForegroundColor Gray
                Write-Host ' never deleted.' -ForegroundColor Gray
                Write-Host ''
                Write-Host ' [1] Current only = Keep the current wallpaper only'
                Write-Host ' [0] Off          = Keep every image (nothing is deleted)'
                Write-Host '     Custom         (type a number, for example 50)'
                Write-Host ''
                Write-WizardFooter 'Type a value, or press Enter for the default (20).'
                $keepVal = Read-Validated -Prompt 'Max kept images [20]' -Default '20' -ErrorText 'Enter 0, 1 or a whole number.' -Validate {
                    param($t)
                    if ($t -eq '1') { return @{ Ok = $true; Value = 'current' } }
                    $v = Test-ArgValue -Key 'Keep' -Value $t
                    if ($null -ne $v) { return @{ Ok = $true; Value = $v } }
                    return @{ Ok = $false }
                }
                if ($keepVal -eq 'current') { $cfg.KeepCurrentOnly = $true }
                else { $cfg.KeepCurrentOnly = $false; $cfg.Keep = [int]$keepVal }
            }
            'MaxAttempts' {
                Show-WizardScreen $n $total 'Maximum attempts'
                Write-Host ' How many images to try before giving up (1-20).' -ForegroundColor Gray
                Write-Host ' An attempt fails when an image misses your filters.' -ForegroundColor Gray
                Write-Host ''
                Write-Host ' Example:' -ForegroundColor Gray
                Write-Host ''
                Write-Host ' A minimum width of 1280 combined with a minimum file size' -ForegroundColor Gray
                Write-Host ' of 10M may match no image at all, so every attempt fails.' -ForegroundColor Gray
                Write-Host ''
                Write-WizardFooter 'Type a value, or press Enter for the default (5).'
                $cfg.MaxAttempts = Read-Validated -Prompt 'Maximum attempts [5]' -Default '5' -ErrorText 'Enter a number from 1 to 20.' -Validate {
                    param($t)
                    $v = Test-ArgValue -Key 'MaxAttempts' -Value $t
                    if ($null -ne $v) { return @{ Ok = $true; Value = $v } }
                    return @{ Ok = $false }
                }
            }
            'RunMode' {
                Show-WizardScreen $n $total 'Run mode'
                Write-Host ' How should the wallpaper be changed?' -ForegroundColor Gray
                Write-Host ''
                Write-Host '   [1] Once     Change it now, one time' -ForegroundColor White
                Write-Host '   [2] Repeat   Keep changing it in the background' -ForegroundColor White
                Write-Host ''
                Write-Host ' Repeat runs a hidden process with a tray icon and starts at sign-in.' -ForegroundColor Gray
                Write-Host ' No PowerShell window has to stay open.' -ForegroundColor Gray
                Write-Host ''
                Write-WizardFooter 'Enter 1 or 2, or press Enter for the default (1 = Once).'
                $c = Read-MenuChoice -Prompt 'Your choice [1]' -Valid @('1', '2') -Default '1'
                if ($c -eq '2') {
                    Write-Host ''
                    $cfg.IntervalMinutes = Read-Validated -Prompt 'Change every how many minutes? (1-1440) [60]' -Default '60' `
                        -ErrorText 'Enter a number from 1 to 1440.' -Validate {
                        param($t)
                        $v = Test-ArgValue -Key 'IntervalMinutes' -Value $t
                        if ($null -ne $v) { return @{ Ok = $true; Value = $v } }
                        return @{ Ok = $false }
                    }
                } else { $cfg.IntervalMinutes = 0 }
            }
        }
    }
    return $cfg
}

function Invoke-Wizard {
    while ($true) {
        $cfg = Invoke-WizardCollect
        $message = $null
        while ($true) {
            Show-Header
            Show-ScreenTitle '[WIZARD] SUMMARY'
            Write-Host ''
            Show-ConfigSummary $cfg
            Write-Host ''
            if ($message) { Write-Host (' ' + $message) -ForegroundColor Green; Write-Host ''; $message = $null }
            Write-Host ' What next?' -ForegroundColor Yellow
            Write-Host ''
            Write-Host '   [1] Run now' -ForegroundColor White
            Write-Host '   [2] Print the command only (do not run)' -ForegroundColor White
            Write-Host '   [3] Save settings as a default profile (use with -Profile)' -ForegroundColor White
            Write-Host '   [4] Start again' -ForegroundColor White
            Write-Host ''
            Write-WizardFooter 'Enter 1-4, or press Enter for the default (1 = Run now).'
            $c = Read-MenuChoice -Prompt 'Your choice [1-4]' -Valid @('1', '2', '3', '4') -Default '1'
            if ($c -eq '1') { Invoke-Run $cfg; return }
            if ($c -eq '4') { break }
            if ($c -eq '2') {
                Write-Host ''
                Write-Host ' Command:' -ForegroundColor Cyan
                Write-CommandBlock $cfg
                Write-Host ''
                Write-Host ' Keys are not part of the command; set them with -SetKey.' -ForegroundColor Gray
                Write-Host ''
                [void](Read-Nav 'Press Enter to go back')
            }
            if ($c -eq '3') {
                try {
                    Save-ConfigFile -Path (Get-ProfilePath 'default') -Cfg $cfg
                    $message = "Profile saved. Run it with: .\$ToolFileName.ps1 -Profile"
                } catch {
                    $message = $null
                    Write-Host (" Could not save the profile: {0}" -f $_.Exception.Message) -ForegroundColor Red
                    Start-Sleep -Seconds 2
                }
            }
        }
    }
}

# =============================================
# MIGRATION FROM THE OLD FOLDER (FirstEverTech\...)
# =============================================

function Move-LegacyData {
    try {
        $oldLocal = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'FirstEverTech\UniversalWindowsWallpaperChanger'
        $oldRoam  = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'FirstEverTech\UniversalWindowsWallpaperChanger'
        if (-not (Test-Path -LiteralPath $oldLocal) -and -not (Test-Path -LiteralPath $oldRoam)) { return }

        $oldConfig = Join-Path $oldLocal 'background.json'
        $hadBackground = Test-Path -LiteralPath $oldConfig
        if (Test-TrayRunning) {
            $oldCmd = Join-Path $oldLocal 'command.txt'
            if (Test-Path -LiteralPath $oldLocal) { Set-Content -LiteralPath $oldCmd -Value 'stop' -Encoding ASCII }
            for ($i = 0; $i -lt 30 -and (Test-TrayRunning); $i++) { Start-Sleep -Milliseconds 500 }
            if (Test-TrayRunning) {
                try {
                    $oldState = Join-Path $oldLocal 'state.json'
                    $o = Get-Content -LiteralPath $oldState -Raw | ConvertFrom-Json
                    if ($o.Pid) { Stop-Process -Id ([int]$o.Pid) -Force -ErrorAction SilentlyContinue }
                } catch { }
            }
        }
        if (-not (Test-Path -LiteralPath $script:LocalRoot)) { New-Item -ItemType Directory -Force -Path $script:LocalRoot | Out-Null }
        if ($hadBackground -and -not (Test-Path -LiteralPath $script:BgConfigFile)) {
            Copy-Item -LiteralPath $oldConfig -Destination $script:BgConfigFile -Force
        }
        $oldProfiles = Join-Path $oldRoam 'profiles'
        if (Test-Path -LiteralPath $oldProfiles) {
            if (-not (Test-Path -LiteralPath $script:ProfileDir)) { New-Item -ItemType Directory -Force -Path $script:ProfileDir | Out-Null }
            Get-ChildItem -LiteralPath $oldProfiles -Filter '*.json' -File -ErrorAction SilentlyContinue | ForEach-Object {
                $dest = Join-Path $script:ProfileDir $_.Name
                if (-not (Test-Path -LiteralPath $dest)) { Copy-Item -LiteralPath $_.FullName -Destination $dest }
            }
        }
        Remove-Item -LiteralPath $oldLocal -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $oldRoam -Recurse -Force -ErrorAction SilentlyContinue
        foreach ($parent in @((Split-Path -Parent $oldLocal), (Split-Path -Parent $oldRoam))) {
            if ((Test-Path -LiteralPath $parent) -and -not (Get-ChildItem -LiteralPath $parent -Force -ErrorAction SilentlyContinue)) {
                Remove-Item -LiteralPath $parent -Force -ErrorAction SilentlyContinue
            }
        }
        if ($hadBackground -and $ScriptPath) {
            Install-ScriptCopy
            Set-Autostart
            [void](Start-Tray)
        }
        Write-Log 'Migrated data from the old FirstEverTech folder.' 'INFO'
    } catch { Write-Log ("Migration failed: {0}" -f $_.Exception.Message) 'WARN' }
}

# =============================================
# MAIN
# =============================================

$script:ExitCode = 0

try {
    if (-not $Flags.Tray) { Move-LegacyData }

    # --- Management commands (no checks, no wallpaper change) ---
    $mgmt = Invoke-ManagementCommands
    if ($null -ne $mgmt) { exit $mgmt }

    # --- Resident tray process (started by Run key or -IntervalMinutes) ---
    if ($Flags.Tray) {
        Invoke-TrayMode
        exit 0
    }

    $RunConfig = Resolve-RunConfig

    # --- Quiet: no screens, prompts or credits ---
    if ($Flags.Quiet) { Invoke-QuietRun $RunConfig }

    # --- Interactive ---
    Set-ConsoleSize
    $githubOk = Show-StartupChecks

    if ($githubOk) {
        $hashResult = Test-ScriptHash
        if ($hashResult -eq 'Failed') {
            Write-Host " Aborted for security reasons." -ForegroundColor Red
            Write-Host ""
            Wait-AnyKey " Press any key to exit..."
            exit 1
        }
        if (-not $Flags.NoUpdate) { Invoke-UpdateCheck }
    }
    if (-not $DebugMode) { Start-Sleep -Seconds 2 }

    if (Test-JpegPrecheckNeeded) { Show-JpegPrecheck }

    $hasAction = ($Cli.Count -gt 0) -or $Flags.Once -or $ProfileRequested -or $Flags.KeepCurrentOnly
    $next = if ($Flags.Wizard) { 'Wizard' } elseif ($hasAction) { 'Run' } else { 'Start' }
    while ($true) {
        try {
            switch ($next) {
                'Wizard' { Invoke-Wizard }
                'Run'    { Invoke-Run $RunConfig }
                default  { Show-StartScreen }
            }
            break
        } catch {
            if ($_.Exception.Message -eq 'UWWC_BACK_TO_START') { $next = 'Start'; continue }
            throw
        }
    }
}
catch {
    Write-Log ("Unhandled error: {0}" -f $_.Exception.Message) 'ERROR'
    if (-not $script:Quiet) {
        Write-Host ""
        Write-Host (" ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
        Write-Host (" Details: {0}" -f (Get-ShortPath $script:LogFile)) -ForegroundColor Gray
        Write-Host ""
    }
    exit 1
}
exit $script:ExitCode
