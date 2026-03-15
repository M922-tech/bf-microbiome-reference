#!/bin/bash
# =============================================================
# Script 01 : Téléchargement des données De Filippo 2010
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Mars 2025
# Accession : ERP000133 (ENA)
# =============================================================

# Dossier de destination
OUTPUT_DIR="data/16S/raw"
ACCESSIONS="data/16S/metadata/BF_accessions.txt"

echo "=== Téléchargement des 14 échantillons Burkina Faso ==="

while read acc; do
    echo "⬇️  Téléchargement de $acc..."
    wget -q --show-progress \
      "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR011/${acc}/${acc}.fastq.gz" \
      -P ${OUTPUT_DIR}
    echo "✅ $acc terminé"
done < ${ACCESSIONS}

echo "=== Téléchargement terminé ==="
echo "Nombre de fichiers : $(ls ${OUTPUT_DIR}/*.fastq.gz | wc -l)"
