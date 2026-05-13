#!/bin/bash
# =============================================================
# Script 05 : Décontamination hôte — Bowtie2
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Mai 2026
# Dataset   : PRJNA690543 (90 échantillons)
# =============================================================

TRIMMED_DIR="/media/marius/EXTERNAL_USB/gut-microbiome-reference/data/shotgun/PRJNA690543/trimmed"
DECONTAM_DIR="/media/marius/EXTERNAL_USB/gut-microbiome-reference/data/shotgun/PRJNA690543/decontaminated"
INDEX="$HOME/gut-microbiome-reference/ref/human_genome/index/hg38"
LOG_DIR="$HOME/gut-microbiome-reference/data/shotgun/PRJNA690543/decontam_logs"

mkdir -p "$DECONTAM_DIR" "$LOG_DIR"

echo "=== Décontamination Bowtie2 — PRJNA690543 ==="

# Liste des trimmed restants uniquement
samples=$(ls ${TRIMMED_DIR}/*_1_trimmed.fastq.gz 2>/dev/null | \
  xargs -n1 basename | sed 's/_1_trimmed.fastq.gz//')

echo "Échantillons restants : $(echo $samples | wc -w)"

for sample in $samples; do
    # Sauter si déjà décontaminé
    if [ -f "${DECONTAM_DIR}/${sample}_clean_1.fastq.gz" ]; then
        echo "⏭️  Déjà décontaminé : $sample"
        continue
    fi

    echo "🔄 Décontamination : $sample"

    bowtie2 \
      -x $INDEX \
      -1 ${TRIMMED_DIR}/${sample}_1_trimmed.fastq.gz \
      -2 ${TRIMMED_DIR}/${sample}_2_trimmed.fastq.gz \
      --un-conc-gz ${DECONTAM_DIR}/${sample}_clean_%.fastq.gz \
      -p 4 \
      --very-sensitive \
      -S /dev/null \
      2>> ${LOG_DIR}/${sample}_bowtie2.log

    # Supprimer trimmed immédiatement
    rm -f ${TRIMMED_DIR}/${sample}_1_trimmed.fastq.gz
    rm -f ${TRIMMED_DIR}/${sample}_2_trimmed.fastq.gz

    echo "✅ $sample terminé"
done

echo "=== Décontamination terminée ==="
echo "Total décontaminés : $(ls ${DECONTAM_DIR}/*.fastq.gz | wc -l) / 180"
du -sh "$DECONTAM_DIR"
