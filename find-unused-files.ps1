# find-unused-files.ps1
param(
    [string]$RootPath = "D:\gitrepo\projects\portefolio\lib"
)

Write-Host "🔍 Recherche des fichiers potentiellement inutilisés..." -ForegroundColor Cyan

$dartFiles = Get-ChildItem -Path $RootPath -Recurse -Filter "*.dart" -File
$unusedFiles = @()

foreach ($file in $dartFiles) {
    $fileName = $file.BaseName
    $filePath = $file.FullName

    # Ignorer les fichiers d'export et main.dart
    if ($fileName -match "_extentions$" -or $fileName -eq "main") {
        continue
    }

    # Chercher les imports de ce fichier
    $importPattern = "import.*['/\]$fileName\.dart"
    $references = $false
    Get-ChildItem -Path $RootPath -Recurse -Filter "*.dart" -File |
            Where-Object { $_.FullName -ne $filePath } |
            ForEach-Object {
                $content = Get-Content $_.FullName -Raw
                if ($content -match $importPattern) {
                    $references = $true
                }
            }

    if (-not $references) {
        $unusedFiles += [PSCustomObject]@{
            File = $file.Name
            Path = $file.FullName.Replace($RootPath, "lib")
        }
    }
}

if ($unusedFiles.Count -eq 0) {
    Write-Host "✅ Aucun fichier inutilisé trouvé!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Fichiers potentiellement inutilisés trouvés:" -ForegroundColor Yellow
    $unusedFiles | Format-Table -AutoSize

    Write-Host "`n📊 Total: $($unusedFiles.Count) fichier(s)" -ForegroundColor Cyan
}
