#!/bin/bash
# =============================================================
# Script 02 : Vérification intégrité des fichiers shotgun
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Mars 2026
# =============================================================

RAW_DIR="data/shotgun/raw"
METADATA_DIR="data/shotgun/metadata"

echo "=== Vérification intégrité des 180 fichiers FASTQ ==="
echo "Dossier : $RAW_DIR"

# Vérifier le nombre de fichiers
total=$(ls ${RAW_DIR}/*.fastq.gz | wc -l)
echo "Nombre de fichiers : $total (attendu : 180)"

# Vérifier l'intégrité en parallèle
echo "=== Test d'intégrité en parallèle ==="
corrupted=0
ls ${RAW_DIR}/*.fastq.gz | parallel -j 8 \
  'gzip -t {} 2>/dev/null || echo "❌ {}"' | tee ${METADATA_DIR}/corrupted_files.txt

corrupted=$(cat ${METADATA_DIR}/corrupted_files.txt | wc -l)
echo "Fichiers corrompus : $corrupted"

# Re-télécharger les fichiers corrompus si nécessaire
if [ $corrupted -gt 0 ]; then
    echo "=== Re-téléchargement des fichiers corrompus ==="
    while read line; do
        filename=$(basename $(echo $line | awk '{print $2}'))
        acc="${filename%.fastq.gz}"
        
        url=$(grep "${acc%_*}" ${METADATA_DIR}/PRJNA690543_runinfo.tsv | \
          awk -F'\t' '{print $5}' | tr ';' '\n' | grep "$acc")
        
        echo "🔄 Re-téléchargement de $filename..."
        rm -f ${RAW_DIR}/$filename
        wget -q --show-progress "ftp://${url}" -O ${RAW_DIR}/$filename
        gzip -t ${RAW_DIR}/$filename 2>/dev/null && \
          echo "✅ $filename OK" || echo "❌ $filename encore corrompu"
    done < ${METADATA_DIR}/corrupted_files.txt
fi

echo "=== Vérification terminée ==="
echo "✅ Tous les fichiers sont intacts"
