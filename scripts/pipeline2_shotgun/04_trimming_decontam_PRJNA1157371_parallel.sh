#!/bin/bash
# =============================================================
# Script 04b : Trimming + Décontamination PRJNA1157371 — Parallèle
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Mai 2026
# Dataset   : PRJNA1157371 (384 échantillons AWI-Gen 2 BF)
# Jobs      : 8 échantillons simultanés
# Paramètres trimming retenus après analyse MultiQC :
#   - Qualité Phred < 20 → supprimée
#   - 20 premières bases coupées (biais amorçage)
#   - Reads < 50 bp supprimés
#   - Adaptateurs détectés automatiquement
#   - Correction chevauchement paired-end
# =============================================================

RAW_DIR="/media/marius/HIKVISION/gut-microbiome-reference/data/shotgun/PRJNA1157371/raw"
TRIMMED_DIR="/media/marius/EXTERNAL_USB1/gut-microbiome-reference/data/shotgun/PRJNA1157371/trimmed"
DECONTAM_DIR="/media/marius/EXTERNAL_USB1/gut-microbiome-reference/data/shotgun/PRJNA1157371/decontaminated"
QC_DIR="$HOME/gut-microbiome-reference/data/shotgun/PRJNA1157371/qc_trimmed"
LOG_DIR="$HOME/gut-microbiome-reference/data/shotgun/PRJNA1157371/decontam_logs"
INDEX="$HOME/gut-microbiome-reference/ref/human_genome/index/hg38"

mkdir -p "$TRIMMED_DIR" "$DECONTAM_DIR" "$QC_DIR" "$LOG_DIR"

# Fonction de traitement par échantillon
process_sample() {
    sample=$1
    RAW_DIR=$2
    TRIMMED_DIR=$3
    DECONTAM_DIR=$4
    QC_DIR=$5
    LOG_DIR=$6
    INDEX=$7

    # Sauter si déjà décontaminé
    if [ -f "${DECONTAM_DIR}/${sample}_clean_1.fastq.gz" ]; then
        echo "⏭️  Déjà traité : $sample"
        return
    fi

    if [ -f "${TRIMMED_DIR}/${sample}_1_trimmed.fastq.gz" ]; then
        echo "⏭️  Déjà trimmé : $sample"
    else
        echo "🔄 Trimming : $sample"
    fastp \
      --in1 ${RAW_DIR}/${sample}_1.fastq.gz \
      --in2 ${RAW_DIR}/${sample}_2.fastq.gz \
      --out1 ${TRIMMED_DIR}/${sample}_1_trimmed.fastq.gz \
      --out2 ${TRIMMED_DIR}/${sample}_2_trimmed.fastq.gz \
      --qualified_quality_phred 20 \
      --unqualified_percent_limit 40 \
      --length_required 50 \
      --trim_front1 20 \
      --trim_front2 20 \
      --detect_adapter_for_pe \
      --correction \
      --thread 1 \
      --json ${QC_DIR}/${sample}_fastp.json \
      --html ${QC_DIR}/${sample}_fastp.html \
      2>> ${QC_DIR}/fastp_summary.log

    echo "🔄 Décontamination : $sample"
    bowtie2 \
      -x $INDEX \
      -1 ${TRIMMED_DIR}/${sample}_1_trimmed.fastq.gz \
      -2 ${TRIMMED_DIR}/${sample}_2_trimmed.fastq.gz \
      --un-conc-gz ${DECONTAM_DIR}/${sample}_clean_%.fastq.gz \
      -p 3 \
      --very-sensitive \
      -S /dev/null \
      2>> ${LOG_DIR}/${sample}_bowtie2.log

    # Supprimer trimmed immédiatement
    rm -f ${TRIMMED_DIR}/${sample}_1_trimmed.fastq.gz
    rm -f ${TRIMMED_DIR}/${sample}_2_trimmed.fastq.gz

    echo "✅ $sample terminé"
}

export -f process_sample

# Lister les échantillons
samples=$(ls ${RAW_DIR}/*_1.fastq.gz | \
  xargs -n1 basename | sed 's/_1.fastq.gz//')

echo "=== Traitement PRJNA1157371 — 8 échantillons simultanés ==="
echo "Échantillons total : $(echo $samples | wc -w)"

# Traiter 8 échantillons simultanément
echo "$samples" | parallel -j 4 \
  process_sample {} \
  "$RAW_DIR" "$TRIMMED_DIR" "$DECONTAM_DIR" "$QC_DIR" "$LOG_DIR" "$INDEX"

echo "=== Terminé ==="
echo "Décontaminés : $(ls ${DECONTAM_DIR}/*.fastq.gz 2>/dev/null | wc -l) / 768"
du -sh "$DECONTAM_DIR"
