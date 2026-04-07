#!/bin/bash
# =============================================================
# Script 03 : Téléchargement données AWI-Gen 2 — Burkina Faso
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Avril 2026
# Accession : PRJNA1157371 (NCBI/ENA)
# Site      : Nanoro, Burkina Faso
# Échantillons : 384 femmes adultes (paired-end shotgun)
# Stockage  : SSD externe HIKVISION
# Note      : Fichiers conservés avec noms originaux SRR*
# =============================================================

OUTPUT_DIR="/media/marius/HIKVISION/gut-microbiome-reference/data/shotgun/PRJNA1157371/raw"
LINKS_FILE="$HOME/links_final_bf.txt"

echo "=== Téléchargement AWI-Gen 2 — Burkina Faso (Nanoro) ==="
echo "=== 768 fichiers FASTQ (384 × R1+R2) ==="
echo "=== Destination : $OUTPUT_DIR ==="

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# Créer liste des fichiers manquants
while read -r url; do
    filename=$(basename $url)
    if [ ! -f "$filename" ] || [ ! -s "$filename" ]; then
        echo "$url"
    fi
done < "$LINKS_FILE" > /tmp/missing_awigen2.txt

echo "Fichiers manquants : $(wc -l < /tmp/missing_awigen2.txt)"

# Télécharger les fichiers manquants (3 simultanés)
cat /tmp/missing_awigen2.txt | \
parallel -j 3 --ungroup \
  "wget -nc ftp://{} \
   -P $OUTPUT_DIR \
   --passive-ftp \
   --timeout=60 \
   --tries=20 \
   -q --show-progress"

echo "=== Vérification intégrité ==="
ls *.fastq.gz | parallel -j 8 \
  'gzip -t {} 2>/dev/null || echo "❌ {}"' \
  > /tmp/corrupted_awigen2.txt

echo "Fichiers corrompus : $(wc -l < /tmp/corrupted_awigen2.txt)"
cat /tmp/corrupted_awigen2.txt

echo "=== Terminé ==="
echo "Fichiers présents : $(ls $OUTPUT_DIR | wc -l) / 768"
du -sh "$OUTPUT_DIR"
