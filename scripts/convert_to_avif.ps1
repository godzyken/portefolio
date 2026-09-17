# pipeline_assets.ps1 - Version Windows PowerShell 5.1 Compatible

$SourceDir = (Get-Item "assets_source").FullName
$DestDir = (Get-Item "assets/images").FullName
$BaseWidth = 400

$MagickPath = "magick"

# Detection de ImageMagick
if (!(Get-Command $MagickPath -ErrorAction SilentlyContinue)) {
    $CommonPaths = @(
        "$env:ProgramFiles\ImageMagick*\magick.exe",
        "$env:ProgramFiles (x86)\ImageMagick*\magick.exe"
    )
    $Found = Get-ChildItem -Path $CommonPaths -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($Found) {
        $MagickPath = $Found.FullName
    } else {
        Write-Host "ERREUR: ImageMagick n'est pas detecte."
        exit
    }
}

Write-Host "ImageMagick trouve : $MagickPath"
Write-Host "Lancement du Pipeline AVIF..."

# ETAPE 1 : Conversion des sources (PNG/JPG -> AVIF)
$SourcesToConvert = Get-ChildItem -Path $SourceDir -Recurse -File -Include "*.png", "*.jpg", "*.jpeg", "*.webp"
foreach ($file in $SourcesToConvert) {
    $newPath = [System.IO.Path]::ChangeExtension($file.FullName, ".avif")
    Write-Host ("Optimisation source : " + $file.Name)
    & "$MagickPath" "$($file.FullName)" -quality 65 "$newPath"
    Remove-Item $file.FullName -Force
}

# ETAPE 2 : Generation des variantes Flutter
$AllSources = Get-ChildItem -Path $SourceDir -Recurse -File
$count = 0
$copied = 0

foreach ($f in $AllSources) {
    # Calcul du chemin relatif manuel (Compatible PowerShell 5.1)
    $rel = $f.FullName.Replace($SourceDir, "").TrimStart("\").TrimStart("/")
    $ext = $f.Extension.ToLower()

    if ($ext -eq ".avif") {
        Write-Host ("Variantes pour : " + $rel)

        # 1.0x
        $p1 = Join-Path $DestDir $rel
        $dir1 = Split-Path $p1
        if (!(Test-Path $dir1)) { New-Item -ItemType Directory -Path $dir1 -Force | Out-Null }
        & "$MagickPath" "$($f.FullName)" -resize "$($BaseWidth)x" "$p1"

        # 2.0x
        $p2 = Join-Path $DestDir ("2.0x\" + $rel)
        $dir2 = Split-Path $p2
        if (!(Test-Path $dir2)) { New-Item -ItemType Directory -Path $dir2 -Force | Out-Null }
        & "$MagickPath" "$($f.FullName)" -resize "$($BaseWidth * 2)x" "$p2"

        # 3.0x
        $p3 = Join-Path $DestDir ("3.0x\" + $rel)
        $dir3 = Split-Path $p3
        if (!(Test-Path $dir3)) { New-Item -ItemType Directory -Path $dir3 -Force | Out-Null }
        & "$MagickPath" "$($f.FullName)" -resize "$($BaseWidth * 3)x" "$p3"

        $count++
    } else {
        # Copie simple pour les autres formats
        $d = Join-Path $DestDir $rel
        $dd = Split-Path $d
        if (!(Test-Path $dd)) { New-Item -ItemType Directory -Path $dd -Force | Out-Null }
        Copy-Item $f.FullName -Destination $d -Force
        $copied++
    }
}

Write-Host "Pipeline termine !"
Write-Host ("Images traitees : " + $count)
Write-Host ("Fichiers copies : " + $copied)
