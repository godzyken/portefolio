#!/usr/bin/env python3
"""
generate_asset_variants.py
--------------------------

Prend des images haute résolution d'un dossier source et génère les variantes
pour les différentes densités de pixels de Flutter.

Usage :
    1. Placez vos images en haute résolution dans le dossier défini par --src (par défaut: assets_source).
    2. Exécutez : python generate_asset_variants.py

Dépendances :
    pip install Pillow tqdm
"""

from __future__ import annotations
import argparse
from pathlib import Path
from typing import List
from PIL import Image
from tqdm import tqdm
import shutil

SUPPORTED_EXTS = {'.png', '.jpg', '.jpeg', '.webp'}

# --- CONFIGURATION PRINCIPALE ---
# Modifiez ces valeurs par défaut si nécessaire
DEFAULT_SOURCE_DIR = Path('assets_source') # Dossier pour VOS images originales
DEFAULT_DEST_DIR = Path('assets/images')   # Dossier où Flutter cherchera les images
DEFAULT_BASE_WIDTH = 300  # Largeur en pixels pour une image 1.0x
DEFAULT_SCALES = "2,3,4" # Variantes à générer (ex: 2.0x, 3.0x, 4.0x)

# ---------------------------------

def resize_and_save(src_img: Image, dest_path: Path, new_width: int):
    """Redimensionne une image en préservant son ratio et la sauvegarde."""
    if new_width <= 0: return

    aspect_ratio = src_img.height / src_img.width
    new_height = int(new_width * aspect_ratio)

    resized = src_img.resize((new_width, new_height), resample=Image.LANCZOS)

    # Créer le dossier parent si besoin
    dest_path.parent.mkdir(parents=True, exist_ok=True)

    resized.save(dest_path, optimize=True)

def generate_variants(src_dir: Path, dest_dir: Path, scales: List[float], base_width: int):
    """Génère les variantes d'images pour Flutter."""

    source_images = [p for p in src_dir.rglob('*') if p.is_file() and p.suffix.lower() in SUPPORTED_EXTS]

    if not source_images:
        print(f"❌ Aucune image trouvée dans le dossier source '{src_dir}'.")
        print("Assurez-vous d'y avoir placé vos fichiers images en haute résolution.")
        return

    print(f"🖼️  {len(source_images)} image(s) trouvée(s). Traitement en cours...")

    for img_path in tqdm(source_images, desc="Génération des variantes", unit="img"):
        try:
            with Image.open(img_path) as img:
                # Créer les variantes 2.0x, 3.0x, etc.
                for scale in scales:
                    target_width = int(base_width * scale)
                    subdir = dest_dir / f"{scale:.1f}x"
                    dest_file_path = subdir / img_path.name
                    resize_and_save(img, dest_file_path, target_width)

                # Créer l'image de base (1.0x)
                # Elle sera à la racine du dossier de destination
                dest_base_file_path = dest_dir / img_path.name
                resize_and_save(img, dest_base_file_path, base_width)

        except Exception as e:
            print(f"\n❌ ERREUR lors du traitement de '{img_path.name}': {e}")

def parse_args():
    p = argparse.ArgumentParser(description="Génère des variantes d'assets Flutter.")
    p.add_argument('--src', type=Path, default=DEFAULT_SOURCE_DIR, help='Répertoire des images sources en haute résolution.')
    p.add_argument('--dest', type=Path, default=DEFAULT_DEST_DIR, help='Répertoire de destination pour les assets générés.')
    p.add_argument('--base_width', type=int, default=DEFAULT_BASE_WIDTH, help='Largeur de base en pixels pour une image 1.0x.')
    p.add_argument('--scales', type=str, default=DEFAULT_SCALES, help='Facteurs d\'échelle séparés par des virgules (ex: 2,3,4).')
    return p.parse_args()

def main():
    args = parse_args()
    scales = [float(s) for s in args.scales.split(',') if s]

    # Créer les dossiers si besoin
    args.src.mkdir(exist_ok=True)
    args.dest.mkdir(exist_ok=True)

    print("--- Lancement du script de génération d'assets ---")
    print(f"Source: '{args.src}'")
    print(f"Destination: '{args.dest}'")
    print(f"Largeur de base (1.0x): {args.base_width}px")
    print(f"Échelles à générer: {scales}")
    print("-------------------------------------------------")

    generate_variants(args.src, args.dest, scales, args.base_width)

    print("\n✅ Script terminé !")

if __name__ == '__main__':
    main()
