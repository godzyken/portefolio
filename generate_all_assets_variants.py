#!/usr/bin/env python3
"""
generate_asset_variants.py
--------------------------
Gère la génération des assets pour Flutter de manière optimisée.
- Redimensionne les images bitmap (png, jpg...).
- Copie les assets vectoriels (svg) et autres (json...).
- Mode incrémental : ne traite que les fichiers modifiés.
"""

from __future__ import annotations
import argparse
from pathlib import Path
from typing import List
from PIL import Image
from tqdm import tqdm
import shutil
import os

# --- CONFIGURATION DES FORMATS ---
RASTER_EXTS = {'.png', '.jpg', '.jpeg', '.webp'}
COPY_ONLY_EXTS = {'.svg', '.json', '.gltf', '.bin', '.glb', '.riv'}

# --- CONFIGURATION DES CHEMINS ET TAILLES ---
DEFAULT_SOURCE_DIR = Path('assets_source')
DEFAULT_DEST_DIR = Path('assets/images')
DEFAULT_BASE_WIDTH = 300
DEFAULT_SCALES = "2.0,3.0" # Réduit à 2 et 3 pour économiser la RAM/Espace disque

def resize_and_save(src_img: Image.Image, dest_path: Path, new_width: int, ext: str):
    """Redimensionne une image bitmap et la sauvegarde avec optimisation."""
    if new_width <= 0: return

    aspect_ratio = src_img.height / src_img.width
    new_height = int(new_width * aspect_ratio)

    # Redimensionnement haute qualité
    resized = src_img.resize((new_width, new_height), resample=Image.LANCZOS)
    dest_path.parent.mkdir(parents=True, exist_ok=True)

    # Optimisation selon l'extension
    if ext in {'.jpg', '.jpeg'}:
        resized.save(dest_path, optimize=True, quality=85)
    elif ext == '.png':
        resized.save(dest_path, optimize=True)
    else:
        resized.save(dest_path, optimize=True)

def copy_asset(src_path: Path, dest_dir: Path, relative_path: Path):
    """Copie un asset si la source est plus récente que la destination."""
    dest_path = dest_dir / relative_path

    # Vérification incrémentale
    if dest_path.exists() and dest_path.stat().st_mtime >= src_path.stat().st_mtime:
        return

    dest_path.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src_path, dest_path)

def generate_variants(src_dir: Path, dest_dir: Path, scales: List[float], base_width: int):
    """Génère les variantes d'images et gère les copies d'assets."""

    all_source_files = [p for p in src_dir.rglob('*') if p.is_file()]

    if not all_source_files:
        print(f"❌ Aucun fichier trouvé dans le dossier source '{src_dir}'.")
        return

    print(f"🖼️  {len(all_source_files)} fichier(s) trouvé(s).")

    for file_path in tqdm(all_source_files, desc="Traitement des assets", unit="file"):
        relative_path = file_path.relative_to(src_dir)
        extension = file_path.suffix.lower()

        try:
            # --- Traitement des images BITMAP ---
            if extension in RASTER_EXTS:
                dest_base = dest_dir / relative_path

                # On ne traite que si le fichier source est plus récent que la version 1.0x
                if not dest_base.exists() or dest_base.stat().st_mtime < file_path.stat().st_mtime:
                    with Image.open(file_path) as img:
                        # Convertir en RGB si nécessaire (évite erreurs avec certains PNG/WebP)
                        if img.mode in ("RGBA", "P") and extension in {'.jpg', '.jpeg'}:
                            img = img.convert("RGB")

                        # Créer l'image de base (1.0x)
                        resize_and_save(img, dest_base, base_width, extension)

                        # Créer les variantes (2.0x, 3.0x...)
                        for scale in scales:
                            target_width = int(base_width * scale)
                            subdir = dest_dir / f"{scale:.1f}x"
                            dest_file_path = subdir / relative_path
                            resize_and_save(img, dest_file_path, target_width, extension)

            # --- Traitement des fichiers à COPIER ---
            elif extension in COPY_ONLY_EXTS:
                copy_asset(file_path, dest_dir, relative_path)

        except Exception as e:
            print(f"\n❌ ERREUR sur '{file_path.name}': {e}")

def parse_args():
    p = argparse.ArgumentParser(description="Génère des variantes d'assets Flutter.")
    p.add_argument('--src', type=Path, default=DEFAULT_SOURCE_DIR)
    p.add_argument('--dest', type=Path, default=DEFAULT_DEST_DIR)
    p.add_argument('--base_width', type=int, default=DEFAULT_BASE_WIDTH)
    p.add_argument('--scales', type=str, default=DEFAULT_SCALES)
    return p.parse_args()

def main():
    args = parse_args()
    scales = [float(s) for s in args.scales.split(',') if s]

    args.src.mkdir(exist_ok=True)
    args.dest.mkdir(parents=True, exist_ok=True)

    print("--- Lancement de la génération optimisée ---")
    print(f"Source      : {args.src}")
    print(f"Destination : {args.dest}")
    print(f"Base Width  : {args.base_width}px")
    print(f"Échelles    : {scales}")
    print("---------------------------------------------")

    generate_variants(args.src, args.dest, scales, args.base_width)

    print("\n✅ Terminé ! Vos assets sont prêts.")

if __name__ == '__main__':
    main()
