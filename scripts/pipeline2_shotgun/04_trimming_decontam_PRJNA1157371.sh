#!/bin/bash
# =============================================================
# Script 04b : Trimming + Décontamination PRJNA1157371
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Mai 2026
# Dataset   : PRJNA1157371 (384 échantillons AWI-Gen 2 BF)
# =============================================================

RAW_DIR="/media/marius/HIKVISION/gut-microbiome-reference/data/shotgun/PRJNA1157371/raw"
TRIMMED_DIR="/media/marius/EXTERNAL_USB/gut-microbiome-reference/data/shotgun/PRJNA1157371/trimmed"
DECONTAM_DIR="/media/marius/EXTERNAL_USB/gut-microbiome-reference/data/shotgun/PRJNA1157371/decontaminated"
QC_DIR="$HOME/gut-microbiome-reference/data/shotgun/PRJNA1157371/qc_trimmed"
LOG_DIR="$HOME/gut-microbiome-reference/data/shotgun/PRJNA1157371/decontam_logs"
INDEX="$HOME/gut-microbiome-reference/ref/human_genome/index/hg38"

mkdir -p "$TRIMMED_DIR" "$DECONTAM_DIR" "$QC_DIR" "$LOG_DIR"

echo "=== Trimming + Décontamination PRJNA1157371 ==="
echo "=== 384 échantillons paired-end ==="

# Liste des échantillons
samples=$(ls ${RAW_DIR}/*_1.fastq.gz | \
  xargs -n1 basename | sed 's/_1.fastq.gz//')

echo "Échantillons trouvés : $(echo $samples | wc -w)"

for sample in $samples; do
    # Sauter si déjà décontaminé
    if [ -f "${DECONTAM_DIR}/${sample}_clean_1.fastq.gz" ]; then
        echo "⏭️  Déjà traité : $sample"
        continue
    fi

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

    echo "✅ $sample trimmé"

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

    echo "✅ $sample décontaminé"
    echo "--- Espace EXTERNAL_USB : $(df -h /media/marius/EXTERNAL_USB | tail -1 | awk '{print $4}') disponible ---"
done

echo "=== Pipeline PRJNA1157371 terminé ==="
echo "Décontaminés : $(ls ${DECONTAM_DIR}/*.fastq.gz | wc -l)"
du -sh "$DECONTAM_DIR"
