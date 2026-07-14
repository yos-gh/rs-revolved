param(
    [string]$SourceDir = "original/rs_tonyu_0.031/Usr/wav",
    [string]$OutputDir = "assets/audio/runtime/original_mastered",
    [string]$Ffmpeg = "C:/Program Files/FFmpeg/bin/ffmpeg.exe"
)

$ErrorActionPreference = "Stop"
$names = @("shot", "bomb_s", "bomb_m", "die", "extend", "gum_o", "gum_c")
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

foreach ($name in $names) {
    $inputPath = Join-Path $SourceDir "$name.wav"
    $outputPath = Join-Path $OutputDir "$name.wav"
    & $Ffmpeg -y -v error -i $inputPath `
        -af "volume=-3dB,highpass=f=18:p=2,volume=2dB,alimiter=limit=0.891251:attack=1:release=20:level=false:latency=true" `
        -ar 48000 -ac 1 -c:a pcm_s16le $outputPath
    if ($LASTEXITCODE -ne 0) {
        throw "ffmpeg failed while mastering $inputPath"
    }
}

Write-Host "Mastered $($names.Count) original SFX files into $OutputDir"
