#!/usr/bin/env python3
"""
generate_asset_variants.py
--------------------------

Crée automatiquement les variantes 2.0x et 3.0x pour les images Flutter.

Usage :
    python generate_asset_variants.py --src assets/images --scales 2,3

Par défaut, --src = assets/images et --scales = 2,3.

Dépendances :
    pip install Pillow tqdm
"""

from __future__ import annotations
import argparse
from pathlib import Path
from typing import Iterable, List
from PIL import Image
from tqdm import tqdm

SUPPORTED_EXTS = {'.png', '.jpg', '.jpeg', '.webp'}

def discover_images(src_dir: Path) -> Iterable[Path]:
    """Retourne tous les fichiers image directement sous src_dir (1.0x)."""
    for path in src_dir.rglob('*'):
        if path.is_file() and path.suffix.lower() in SUPPORTED_EXTS and 'x/' not in path.as_posix():
            yield path

def ensure_subdir(base_dir: Path, scale: float) -> Path:
    """Crée le dossier <scale>.0x sous base_dir s'il n'existe pas."""
    subdir = base_dir / f"{scale:.1f}x"
    subdir.mkdir(parents=True, exist_ok=True)
    return subdir

def resize_image(src: Path, dest: Path, scale: float) -> None:
    with Image.open(src) as img:
        new_size = (int(img.width * scale), int(img.height * scale))
        resized = img.resize(new_size, resample=Image.LANCZOS)
        resized.save(dest, optimize=True)

def generate_variants(src_dir: Path, scales: List[float]) -> None:
    images = list(discover_images(src_dir))
    if not images:
        print(f"Aucune image trouvée dans {src_dir}")
        return

    for img_path in tqdm(images, desc="Génération des variantes", unit="img"):
        for scale in scales:
            subdir = ensure_subdir(src_dir, scale)
            dest = subdir / img_path.name
            if dest.exists():
                continue  # saute si déjà présent
            resize_image(img_path, dest, scale)

def parse_args():
    p = argparse.ArgumentParser(description="Génère des variantes d'assets Flutter (2.0x, 3.0x, etc.)")
    p.add_argument('--src', type=Path, default=Path('assets/images'), help='Répertoire racine des images 1.0x')
    p.add_argument('--scales', type=str, default='2,3', help='Facteurs d\'échelle séparés par des virgules (ex: 2,3,4)')
    return p.parse_args()

def main():
    args = parse_args()
    scales = [float(s) for s in args.scales.split(',') if s]
    generate_variants(args.src, scales)
    print("✅ Variantes générées!")

if __name__ == '__main__':
    main()
