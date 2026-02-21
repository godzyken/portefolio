# find-unused-files.ps1
param(
    [string]$RootPath = "D:\gitrepo\projects\portefolio\lib",
    [string]$PackageName = "portefolio"
)

Write-Host "Recherche des fichiers potentiellement inutilises..." -ForegroundColor Cyan

$dartFiles = Get-ChildItem -Path $RootPath -Recurse -Filter "*.dart" -File

# Lire tout le contenu en memoire une seule fois
$allContents = @{}
foreach ($file in $dartFiles) {
    $allContents[$file.FullName] = Get-Content $file.FullName -Raw
}

$unusedFiles = @()
$ignoredPatterns = @("main", ".*\.g$", ".*\.freezed$", ".*_extensions$", ".*_test$")

foreach ($file in $dartFiles) {
    $fileName = $file.BaseName

    # Ignorer certains fichiers
    $skip = $false
    foreach ($pattern in $ignoredPatterns) {
        if ($fileName -match $pattern) {
            $skip = $true
            break
        }
    }
    if ($skip) { continue }

    # Pattern 1 : import relatif  => import '../../mon_fichier.dart'
    $pattern1 = "import\s+['""].*/$fileName\.dart['""]"
    # Pattern 2 : import package  => import 'package:portefolio/.../mon_fichier.dart'
    $pattern2 = "import\s+['""]package:$PackageName/.*$fileName\.dart['""]"
    # Pattern 3 : export           => export '...mon_fichier.dart'
    $pattern3 = "export\s+['""].*$fileName\.dart['""]"
    # Pattern 4 : import sans sous-dossier (fichier a la racine de lib)
    $pattern4 = "import\s+['""]package:$PackageName/$fileName\.dart['""]"

    $isReferenced = $false
    foreach ($entry in $allContents.GetEnumerator()) {
        if ($entry.Key -ne $file.FullName) {
            $content = $entry.Value
            if ($content -match $pattern1 -or
                    $content -match $pattern2 -or
                    $content -match $pattern3 -or
                    $content -match $pattern4) {
                $isReferenced = $true
                break
            }
        }
    }

    if (-not $isReferenced) {
        $unusedFiles += [PSCustomObject]@{
            File = $file.Name
            Path = "lib" + $file.FullName.Substring($RootPath.Length)
        }
    }
}

if ($unusedFiles.Count -eq 0) {
    Write-Host "Aucun fichier inutilise trouve!" -ForegroundColor Green
} else {
    Write-Host "Fichiers potentiellement inutilises trouves:" -ForegroundColor Yellow
    $unusedFiles | Format-Table -AutoSize
    Write-Host "Total: $($unusedFiles.Count) fichier(s)" -ForegroundColor Cyan
}
