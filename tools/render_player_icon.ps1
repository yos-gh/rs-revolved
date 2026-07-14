param(
    [string]$SourcePng = ""
)

$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$pngPath = if ($SourcePng) { (Resolve-Path -LiteralPath $SourcePng).Path } else { Join-Path $projectRoot "icon.png" }
$icoPath = Join-Path $projectRoot "icon.ico"
$tempRoot = Join-Path $projectRoot ".tmp_icon"

function Add-U16LE([System.Collections.Generic.List[byte]]$bytes, [int]$value) {
    $bytes.Add([byte]($value -band 0xff))
    $bytes.Add([byte](($value -shr 8) -band 0xff))
}

function Add-U32LE([System.Collections.Generic.List[byte]]$bytes, [int]$value) {
    for ($i = 0; $i -lt 4; $i++) {
        $bytes.Add([byte](($value -shr (8 * $i)) -band 0xff))
    }
}

$ffmpeg = Get-Command ffmpeg -ErrorAction Stop
Remove-Item -Recurse -Force $tempRoot -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $tempRoot | Out-Null

$sizes = @(16, 32, 48, 64, 128, 256)
$images = @()
foreach ($size in $sizes) {
    $outPath = Join-Path $tempRoot "icon_$size.png"
    & $ffmpeg.Source -y -v error -i $pngPath -vf "scale=${size}:${size}:flags=lanczos,format=rgba" -frames:v 1 $outPath
    if ($LASTEXITCODE -ne 0) {
        throw "ffmpeg failed to render $size x $size icon."
    }
    $images += ,@($size, [System.IO.File]::ReadAllBytes($outPath))
}

$ico = [System.Collections.Generic.List[byte]]::new()
Add-U16LE $ico 0
Add-U16LE $ico 1
Add-U16LE $ico $images.Count
$offset = 6 + 16 * $images.Count
foreach ($entry in $images) {
    $size = [int]$entry[0]
    $data = [byte[]]$entry[1]
    $dimension = if ($size -eq 256) { 0 } else { $size }
    $ico.Add([byte]$dimension)
    $ico.Add([byte]$dimension)
    $ico.Add([byte]0)
    $ico.Add([byte]0)
    Add-U16LE $ico 1
    Add-U16LE $ico 32
    Add-U32LE $ico $data.Length
    Add-U32LE $ico $offset
    $offset += $data.Length
}
foreach ($entry in $images) {
    $ico.AddRange([byte[]]$entry[1])
}
[System.IO.File]::WriteAllBytes($icoPath, $ico.ToArray())
Remove-Item -Recurse -Force $tempRoot -ErrorAction SilentlyContinue

Get-Item $pngPath, $icoPath | Select-Object FullName, Length, LastWriteTime
