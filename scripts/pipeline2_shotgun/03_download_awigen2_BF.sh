#!/bin/bash
# =============================================================
# Script 03 : Téléchargement données AWI-Gen 2 — Burkina Faso
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Mai 2026
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

# Boucle jusqu'à ce que tous les fichiers soient intacts
while true; do

    # Supprimer les fichiers corrompus
    echo "=== Vérification et suppression fichiers corrompus ==="
    ls *.fastq.gz 2>/dev/null | \
    parallel -j 8 '
        gzip -t {} 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "❌ Corrompu — supprimé : {}"
            rm -f {}
        fi
    '

    # Créer liste des fichiers manquants
    echo "=== Identification fichiers manquants ==="
    while read -r url; do
        filename=$(basename $url)
        if [ ! -f "$OUTPUT_DIR/$filename" ]; then
            echo "$url"
        fi
    done < "$LINKS_FILE" > /tmp/missing_awigen2.txt

    missing=$(wc -l < /tmp/missing_awigen2.txt)
    present=$(ls $OUTPUT_DIR/*.fastq.gz 2>/dev/null | wc -l)
    pct=$((present * 100 / 768))

    echo "========================================"
    echo "$(date)"
    echo "Présents  : $present / 768 ($pct%)"
    echo "Manquants : $missing"
    echo "HIKVISION : $(df -h /media/marius/HIKVISION | tail -1 | awk '{print $4}') disponible"
    echo "========================================"

    if [ $missing -eq 0 ]; then
        echo "🎉 Tous les 768 fichiers sont téléchargés et intacts !"
        break
    fi

    # Télécharger les fichiers manquants
    echo "=== Lancement téléchargement ==="
    cat /tmp/missing_awigen2.txt | \
    parallel -j 8 --ungroup \
      "wget -c ftp://{} \
       -P $OUTPUT_DIR \
       --passive-ftp \
       --timeout=300 \
       --tries=0 \
       --waitretry=30 \
       -q --show-progress"

    echo "⚠️ Relance dans 30 secondes..."
    sleep 30
done

echo "=== Terminé ==="
echo "Fichiers présents : $(ls $OUTPUT_DIR/*.fastq.gz | wc -l) / 768"
du -sh "$OUTPUT_DIR"
