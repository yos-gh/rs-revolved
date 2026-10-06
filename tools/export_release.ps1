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

$script:GodotExe = Resolve-GodotConsole $GodotConsole

if (-not $SkipWeb) {
    Remove-Item -Recurse -Force $WebOut -ErrorAction SilentlyContinue
    Invoke-Export "Web" (Join-Path $WebOut "index.html")
}

if (-not $SkipWindows) {
    Remove-Item -Recurse -Force $WindowsOut -ErrorAction SilentlyContinue
    Invoke-Export "Windows Desktop" (Join-Path $WindowsOut "Rev Sweeper Revolved.exe")
}

Get-ChildItem -Recurse -Filter "*.import" $ExportRoot -ErrorAction SilentlyContinue | Remove-Item -Force
Get-ChildItem -Recurse -File $ExportRoot | Select-Object FullName, Length | Format-Table -AutoSize
