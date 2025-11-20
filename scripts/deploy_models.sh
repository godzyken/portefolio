#!/bin/bash

echo "🚀 Déploiement des modèles 3D..."

# Copier vers docs/models pour GitHub Pages
mkdir -p docs/models
cp assets/images/models/*.glb docs/models/

# Commit et push
git add docs/models/
git commit -m "Update 3D models"
git push origin master

echo "✅ Modèles déployés ! Vérifiez dans 2-3 minutes."
echo "🔗 URL: https://github.com/godzyken/portefolio/raw/refs/heads/master/assets_source/models/perso_samurail.glb"
