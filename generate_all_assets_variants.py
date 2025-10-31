#!/usr/bin/env python3
"""
generate_asset_variants.py
--------------------------

Gère la génération des assets pour Flutter.
- Redimensionne les images bitmap (png, jpg...).
- Copie les assets vectoriels (svg) et autres (json...).

Usage :
    1. Placez tous vos assets originaux (images, json, etc.) dans le dossier source.
    2. Exécutez : python generate_all_assets_variants.py
"""

from __future__ import annotations
import argparse
from pathlib import Path
from typing import List
from PIL import Image
from tqdm import tqdm
import shutil

# --- CONFIGURATION DES FORMATS ---
RASTER_EXTS = {'.png', '.jpg', '.jpeg', '.webp'}  # Formats à redimensionner
# ✅ Formats à copier directement, sans créer de variantes de taille
COPY_ONLY_EXTS = {'.svg', '.json'}

# --- CONFIGURATION DES CHEMINS ET TAILLES ---
DEFAULT_SOURCE_DIR = Path('assets_source')
DEFAULT_DEST_DIR = Path('assets/images')
DEFAULT_BASE_WIDTH = 300
DEFAULT_SCALES = "2,3,4"
# -------------------------------------------

def resize_and_save(src_img: Image, dest_path: Path, new_width: int):
    """Redimensionne une image bitmap et la sauvegarde."""
    if new_width <= 0: return
    aspect_ratio = src_img.height / src_img.width
    new_height = int(new_width * aspect_ratio)

    resized = src_img.resize((new_width, new_height), resample=Image.LANCZOS)
    dest_path.parent.mkdir(parents=True, exist_ok=True)
    resized.save(dest_path, optimize=True)

def copy_asset(src_path: Path, dest_dir: Path, relative_path: Path):
    """Copie un asset (SVG, JSON, etc.) à sa destination finale."""
    dest_path = dest_dir / relative_path
    dest_path.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src_path, dest_path)

def generate_variants(src_dir: Path, dest_dir: Path, scales: List[float], base_width: int):
    """Génère les variantes pour les images bitmap et copie les autres assets."""

    # On découvre tous les fichiers, peu importe leur extension
    all_source_files = [p for p in src_dir.rglob('*') if p.is_file()]

    if not all_source_files:
        print(f"❌ Aucun fichier trouvé dans le dossier source '{src_dir}'.")
        return

    print(f"🖼️  {len(all_source_files)} fichier(s) trouvé(s). Traitement en cours...")

    for file_path in tqdm(all_source_files, desc="Traitement des assets", unit="file"):
        relative_path = file_path.relative_to(src_dir)
        extension = file_path.suffix.lower()

        try:
            # --- Traitement des images BITMAP (redimensionnement) ---
            if extension in RASTER_EXTS:
                with Image.open(file_path) as img:
                    # Créer les variantes 2.0x, 3.0x, etc.
                    for scale in scales:
                        target_width = int(base_width * scale)
                        subdir = dest_dir / f"{scale:.1f}x"
                        dest_file_path = subdir / relative_path
                        resize_and_save(img, dest_file_path, target_width)

                    # Créer l'image de base (1.0x)
                    dest_base_file_path = dest_dir / relative_path
                    resize_and_save(img, dest_base_file_path, base_width)

            # --- Traitement des assets à COPIER (SVG, JSON...) ---
            elif extension in COPY_ONLY_EXTS:
                # On copie simplement le fichier dans le dossier de base
                copy_asset(file_path, dest_dir, relative_path)

            # Optionnel: si vous voulez ignorer silencieusement les autres fichiers
            # else:
            #     print(f"ℹ️ Fichier ignoré (type non géré): {relative_path}")

        except Exception as e:
            print(f"\n❌ ERREUR lors du traitement de '{file_path.name}': {e}")


def parse_args():
    p = argparse.ArgumentParser(description="Génère des variantes d'assets Flutter.")
    p.add_argument('--src', type=Path, default=DEFAULT_SOURCE_DIR, help='Répertoire des images sources.')
    p.add_argument('--dest', type=Path, default=DEFAULT_DEST_DIR, help='Répertoire de destination.')
    p.add_argument('--base_width', type=int, default=DEFAULT_BASE_WIDTH, help='Largeur de base pour 1.0x.')
    p.add_argument('--scales', type=str, default=DEFAULT_SCALES, help='Échelles (ex: 2,3,4).')
    return p.parse_args()

def main():
    args = parse_args()
    scales = [float(s) for s in args.scales.split(',') if s]

    # Préparation des dossiers
    args.src.mkdir(exist_ok=True)
    # Nettoie complètement la destination pour repartir de zéro, c'est plus sûr
    if args.dest.exists():
        shutil.rmtree(args.dest)
    args.dest.mkdir(exist_ok=True)

    print("--- Lancement du script de génération d'assets ---")
    print(f"Source: '{args.src}'")
    print(f"Destination: '{args.dest}' (sera nettoyé et recréé)")
    print(f"Largeur 1.0x: {args.base_width}px | Échelles: {scales}")
    print("-------------------------------------------------")

    generate_variants(args.src, args.dest, scales, args.base_width)

    print("\n✅ Script terminé !")

if __name__ == '__main__':
    main()
