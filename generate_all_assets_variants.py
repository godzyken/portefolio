#!/usr/bin/env python3
"""
generate_asset_variants.py
--------------------------
Gère la génération des assets pour Flutter de manière optimisée.
- Redimensionne les images bitmap (png, jpg, webp).
- Convertit les sources AVIF en WEBP (Flutter ne décode pas l'AVIF nativement).
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

# ⚠️ Nécessaire pour que Pillow sache OUVRIR les fichiers .avif source.
#    pip install pillow-avif-plugin
try:
    import pillow_avif  # noqa: F401  (juste besoin de l'enregistrer)
except ImportError:
    print("⚠️ pillow-avif-plugin non installé — les sources .avif ne pourront pas être lues.")
    print("   Installez-le avec : pip install pillow-avif-plugin")

# --- CONFIGURATION DES FORMATS ---
# .avif est maintenant traité comme une image bitmap à CONVERTIR (pas juste copier)
RASTER_EXTS = {'.png', '.jpg', '.jpeg', '.webp', '.avif'}
COPY_ONLY_EXTS = {'.svg', '.json', '.gltf', '.bin', '.glb', '.riv'}

# Formats qui, une fois lus, doivent être ré-écrits dans UN AUTRE format
# (Flutter ne sait pas décoder l'AVIF -> on sort systématiquement en WEBP)
OUTPUT_EXT_OVERRIDE = {'.avif': '.webp'}

# --- CONFIGURATION DES CHEMINS ET TAILLES ---
DEFAULT_SOURCE_DIR = Path('assets_source')
DEFAULT_DEST_DIR = Path('assets/images')
DEFAULT_BASE_WIDTH = 300
DEFAULT_SCALES = "2.0,3.0"


def resize_and_save(src_img: Image.Image, dest_path: Path, new_width: int, out_ext: str):
    """Redimensionne une image bitmap et la sauvegarde avec optimisation."""
    if new_width <= 0:
        return
    aspect_ratio = src_img.height / src_img.width
    new_height = int(new_width * aspect_ratio)

    resized = src_img.resize((new_width, new_height), resample=Image.LANCZOS)
    dest_path.parent.mkdir(parents=True, exist_ok=True)

    if out_ext in {'.jpg', '.jpeg'}:
        if resized.mode in ("RGBA", "P"):
            resized = resized.convert("RGB")
        resized.save(dest_path, optimize=True, quality=85)
    elif out_ext == '.webp':
        resized.save(dest_path, format="WEBP", quality=85, method=6)
    else:
        resized.save(dest_path, optimize=True)


def copy_asset(src_path: Path, dest_dir: Path, relative_path: Path):
    """Copie un asset si la source est plus récente que la destination."""
    dest_path = dest_dir / relative_path
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

    print(f"🖼️ {len(all_source_files)} fichier(s) trouvé(s).")

    for file_path in tqdm(all_source_files, desc="Traitement des assets", unit="file"):
        relative_path = file_path.relative_to(src_dir)
        extension = file_path.suffix.lower()

        try:
            if extension in RASTER_EXTS:
                # Détermine l'extension de SORTIE (ex: .avif -> .webp)
                out_ext = OUTPUT_EXT_OVERRIDE.get(extension, extension)
                out_relative_path = relative_path.with_suffix(out_ext)

                dest_base = dest_dir / out_relative_path

                if not dest_base.exists() or dest_base.stat().st_mtime < file_path.stat().st_mtime:
                    with Image.open(file_path) as img:
                        if img.mode in ("RGBA", "P") and out_ext in {'.jpg', '.jpeg'}:
                            img = img.convert("RGB")

                        # Image de base (1.0x)
                        resize_and_save(img, dest_base, base_width, out_ext)

                        # Variantes (2.0x, 3.0x...)
                        for scale in scales:
                            target_width = int(base_width * scale)
                            subdir = dest_dir / f"{scale:.1f}x"
                            dest_file_path = subdir / out_relative_path
                            resize_and_save(img, dest_file_path, target_width, out_ext)

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
    print(f"Source : {args.src}")
    print(f"Destination : {args.dest}")
    print(f"Base Width : {args.base_width}px")
    print(f"Échelles : {scales}")
    print("---------------------------------------------")

    generate_variants(args.src, args.dest, scales, args.base_width)
    print("\n✅ Terminé ! Vos assets sont prêts (AVIF source -> WEBP compatible Flutter).")


if __name__ == '__main__':
    main()
