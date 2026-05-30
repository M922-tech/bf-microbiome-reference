#!/bin/bash
# =============================================================
# Script 04 : Trimming — Fastp
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Mai 2026
# Dataset   : PRJNA690543 (90 échantillons)
# =============================================================

RAW_DIR="data/shotgun/raw"
TRIMMED_DIR="data/shotgun/PRJNA690543/trimmed"
QC_DIR="data/shotgun/PRJNA690543/qc_trimmed"

mkdir -p "$TRIMMED_DIR" "$QC_DIR"

echo "=== Trimming Fastp — PRJNA690543 ==="
echo "=== 90 échantillons paired-end ==="

samples=$(ls ${RAW_DIR}/*_1.fastq.gz | \
  xargs -n1 basename | sed 's/_1.fastq.gz//')

for sample in $samples; do
    echo "🔄 Trimming : $sample"
    fastp \
      --in1 ${RAW_DIR}/${sample}_1.fastq.gz \
      --in2 ${RAW_DIR}/${sample}_2.fastq.gz \
      --out1 ${TRIMMED_DIR}/${sample}_1_trimmed.fastq.gz \
      --out2 ${TRIMMED_DIR}/${sample}_2_trimmed.fastq.gz \
      --qualified_quality_phred 20 \
      --unqualified_percent_limit 40 \
      --length_required 50 \
      --detect_adapter_for_pe \
      --correction \
      --thread 4 \
      --json ${QC_DIR}/${sample}_fastp.json \
      --html ${QC_DIR}/${sample}_fastp.html \
      2>> ${QC_DIR}/fastp_summary.log
    echo "✅ $sample terminé"
done

echo "=== Trimming terminé ==="
echo "Reads trimmés : $(ls ${TRIMMED_DIR}/*.fastq.gz | wc -l)"
du -sh "$TRIMMED_DIR"
