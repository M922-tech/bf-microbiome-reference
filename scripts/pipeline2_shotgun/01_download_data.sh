#!/bin/bash
# =============================================================
# Script 01 : Téléchargement des données PRJNA690543
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Mars 2025
# Accession : PRJNA690543 (NCBI/ENA)
# Echantillons : 90 adultes burkinabè (paired-end shotgun)
# =============================================================

OUTPUT_DIR="data/shotgun/raw"
FTP_LINKS="data/shotgun/metadata/PRJNA690543_ftp_links.txt"

echo "=== Téléchargement des 90 échantillons shotgun Burkina Faso ==="
echo "=== 180 fichiers FASTQ (R1 + R2) — ~180 Go au total ==="

while read url; do
    filename=$(basename $url)
    
    # Vérifier si le fichier existe déjà et est complet
    if [ -f "${OUTPUT_DIR}/${filename}" ]; then
        echo "⏭️  $filename déjà téléchargé — ignoré"
        continue
    fi
    
    echo "⬇️  Téléchargement de $filename..."
    wget -q --show-progress \
      -c \
      "ftp://${url}" \
      -P ${OUTPUT_DIR}
    echo "✅ $filename terminé"
done < ${FTP_LINKS}

echo "=== Téléchargement terminé ==="
echo "Nombre de fichiers : $(ls ${OUTPUT_DIR}/*.fastq.gz | wc -l)"
