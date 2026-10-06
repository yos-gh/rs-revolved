param(
    [string]$GodotConsole = "",
    [switch]$SkipWeb,
    [switch]$SkipWindows
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ExportRoot = Join-Path $ProjectRoot "export"
$WebOut = Join-Path $ExportRoot "web"
$WindowsOut = Join-Path $ExportRoot "windows"

function Resolve-GodotConsole {
    param([string]$ExplicitPath)

    if ($ExplicitPath -and (Test-Path -LiteralPath $ExplicitPath)) {
        return (Resolve-Path -LiteralPath $ExplicitPath).Path
    }

    if ($env:GODOT_CONSOLE -and (Test-Path -LiteralPath $env:GODOT_CONSOLE)) {
        return (Resolve-Path -LiteralPath $env:GODOT_CONSOLE).Path
    }

    $known = Join-Path $env:USERPROFILE "Godot\Godot_console.exe"
    if (Test-Path -LiteralPath $known) {
        return (Resolve-Path -LiteralPath $known).Path
    }

    $command = Get-Command "godot_console.exe" -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    throw "Godot_console.exe was not found. Set GODOT_CONSOLE or pass -GodotConsole."
}

function Invoke-Export {
    param(
        [string]$Preset,
        [string]$OutputPath
    )

    $outputDir = Split-Path -Parent $OutputPath
    New-Item -ItemType Directory -Force $outputDir | Out-Null
    & $script:GodotExe --path $ProjectRoot --headless --export-release $Preset $OutputPath
    if ($LASTEXITCODE -ne 0) {
        throw "Export failed for preset '$Preset'."
    }
}

# Neither build ships the Sentry add-on (see the presets' exclude filters), but its editor
# plugin forces GDScript call stack tracking on, which slows every script call in release
# builds. Export with the add-on unloaded and tracking off, then put everything back.
$ProjectFile = Join-Path $ProjectRoot "project.godot"
$SentryExtension = Join-Path $ProjectRoot "addons\sentry\sentry.gdextension"
$ExtensionList = Join-Path $ProjectRoot ".godot\extension_list.cfg"
$CallStackSetting = "settings/gdscript/always_track_call_stacks"

function Disable-SentryForExport {
    $script:SavedProject = [System.IO.File]::ReadAllBytes($ProjectFile)
    $script:SavedExtensionList = if (Test-Path -LiteralPath $ExtensionList) { [System.IO.File]::ReadAllBytes($ExtensionList) } else { $null }
    $text = [System.Text.Encoding]::UTF8.GetString($script:SavedProject)
    [System.IO.File]::WriteAllText($ProjectFile, $text.Replace("$CallStackSetting=true", "$CallStackSetting=false"), (New-Object System.Text.UTF8Encoding $false))
    if (Test-Path -LiteralPath $SentryExtension) {
        Move-Item -LiteralPath $SentryExtension "$SentryExtension.export-off"
    }
    if ($null -ne $script:SavedExtensionList) {
        $lines = [System.Text.Encoding]::UTF8.GetString($script:SavedExtensionList) -split "`r?`n" | Where-Object { $_ -notmatch "addons/sentry/" }
        [System.IO.File]::WriteAllText($ExtensionList, ($lines -join "`n"), (New-Object System.Text.UTF8Encoding $false))
    }
}

function Restore-SentryAfterExport {
    if (Test-Path -LiteralPath "$SentryExtension.export-off") {
        Move-Item -Force -LiteralPath "$SentryExtension.export-off" $SentryExtension
    }
    if ($null -ne $script:SavedExtensionList) {
        [System.IO.File]::WriteAllBytes($ExtensionList, $script:SavedExtensionList)
    }
    if ($null -ne $script:SavedProject) {
        [System.IO.File]::WriteAllBytes($ProjectFile, $script:SavedProject)
    }
}

$script:GodotExe = Resolve-GodotConsole $GodotConsole

Disable-SentryForExport
try {
    if (-not $SkipWeb) {
        Remove-Item -Recurse -Force $WebOut -ErrorAction SilentlyContinue
        Invoke-Export "Web" (Join-Path $WebOut "index.html")
        Remove-Item (Join-Path $WebOut "sentry-bundle.js") -Force -ErrorAction SilentlyContinue
        Remove-Item (Join-Path $WebOut "sentry-bundle.js.map") -Force -ErrorAction SilentlyContinue
    }

    if (-not $SkipWindows) {
        Remove-Item -Recurse -Force $WindowsOut -ErrorAction SilentlyContinue
        Invoke-Export "Windows Desktop" (Join-Path $WindowsOut "Rev Sweeper Revolved.exe")
    }
}
finally {
    Restore-SentryAfterExport
}

Get-ChildItem -Recurse -Filter "*.import" $ExportRoot -ErrorAction SilentlyContinue | Remove-Item -Force
Get-ChildItem -Recurse -File $ExportRoot | Select-Object FullName, Length | Format-Table -AutoSize
