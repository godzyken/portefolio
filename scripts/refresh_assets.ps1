# refresh_assets.ps1
# Script de synchronisation des images (Version robuste)

Write-Host "--- Lancement de la generation des assets (WebP + Variantes) ---" -ForegroundColor Cyan

# Determiner la commande Python valide
$PyCmd = ""
if (python --version 2>$null) { $PyCmd = "python" }
elseif (python3 --version 2>$null) { $PyCmd = "python3" }
elseif (py --version 2>$null) { $PyCmd = "py" }

if ($PyCmd -eq "") {
    Write-Host "ERREUR: Python est introuvable sur votre systeme." -ForegroundColor Red
    Write-Host "1. Installez Python depuis python.org" -ForegroundColor White
    Write-Host "2. Assurez-vous de cocher 'Add Python to PATH'" -ForegroundColor White
    Write-Host "3. Desactivez les 'Alias d'execution' de Windows pour Python" -ForegroundColor White
    exit
}

Write-Host "Utilisation de : $PyCmd" -ForegroundColor Gray

# Installer les dependances
Write-Host "Verification des dependances (Pillow, tqdm)..."
& $PyCmd -m pip install Pillow tqdm pillow-avif-plugin --quiet

# Executer le script de generation
Set-Location "$PSScriptRoot\.."
& $PyCmd .\generate_all_assets_variants.py

Write-Host "--- Termine ! Assets rafraichis dans assets/images/ ---" -ForegroundColor Green
