#!/bin/bash
# =============================================================
# Script 03 : Téléchargement données AWI-Gen 2 — Burkina Faso
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Mars 2026
# Accession : PRJNA1157371 (NCBI/ENA)
# Site      : Nanoro, Burkina Faso
# Échantillons : 384 femmes adultes (paired-end shotgun)
# Stockage  : Disque externe BIOINFO_DATA
# =============================================================

OUTPUT_DIR="/media/marius/BIOINFO_DATA/gut-microbiome-reference/data/shotgun/PRJNA1157371/raw"
LINKS_FILE="$HOME/gut-microbiome-reference/data/shotgun/metadata/links_final_bf.txt"

echo "=== Téléchargement AWI-Gen 2 — Burkina Faso (Nanoro) ==="
echo "=== 768 fichiers FASTQ (384 × R1+R2) ==="
echo "=== Destination : $OUTPUT_DIR ==="

# Créer le dossier de destination
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# Nettoyer le fichier de liens
sed -i 's/\r//g; s/ //g' "$LINKS_FILE"

# Téléchargement en parallèle (3 à la fois)
echo "=== Lancement du téléchargement (3 fichiers simultanés) ==="
cat "$LINKS_FILE" | parallel -j 3 --ungroup \
  "wget -c ftp://{} \
   -O awigen2_{/} \
   --passive-ftp \
   --timeout=45 \
   --tries=15 \
   --show-progress"

echo "=== Téléchargement terminé ==="
echo "Fichiers téléchargés : $(ls $OUTPUT_DIR | wc -l) / 768"
du -sh "$OUTPUT_DIR"
