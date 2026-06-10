#!/bin/bash
# =============================================================
# Script 05 : MetaPhlAn4 — PRJNA690543 + PRJNA1157371
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida | Juin 2026
# Méthode   : Sous-échantillonnage 5M reads (corrélation 0.9996)
# Note      : Traitement strictement séquentiel (1 bowtie2 à la fois)
# =============================================================

DB_DIR="$HOME/gut-microbiome-reference/ref/metaphlan_db"
INDEX="mpa_vJan25_CHOCOPhlAnSGB_202503"

process_sample() {
    sample=$1
    decontam_dir=$2
    output_dir=$3

    # Sauter si déjà traité
    if [ -f "${output_dir}/${sample}_profile.txt" ]; then
        echo "⏭️  Déjà traité : $sample"
        return 0
    fi

    echo "🔄 MetaPhlAn4 5M : $sample"

    metaphlan \
      ${decontam_dir}/${sample}_clean_1.fastq.gz,${decontam_dir}/${sample}_clean_2.fastq.gz \
      --input_type fastq \
      --db_dir $DB_DIR \
      --index $INDEX \
      --nproc 4 \
      --subsampling 5000000 \
      --subsampling_seed 42 \
      --mapout ${output_dir}/${sample}.mapout \
      -o ${output_dir}/${sample}_profile.txt \
      2>> ${output_dir}/${sample}_metaphlan.log &

    MPID=$!

    # Protéger bowtie2 dès qu'il démarre
    for i in $(seq 1 30); do
        BOWPID=$(ps aux | grep bowtie2-align-l | grep -v grep | awk '{print $2}' | head -1)
        if [ -n "$BOWPID" ]; then
            echo -1000 | sudo tee /proc/$BOWPID/oom_score_adj > /dev/null
            echo "🛡️  Bowtie2 PID $BOWPID protégé"
            break
        fi
        sleep 2
    done

    # Attendre la fin avant de passer au suivant
    wait $MPID
    STATUS=$?

    rm -f ${output_dir}/${sample}.mapout

    if [ $STATUS -eq 0 ] && [ -f "${output_dir}/${sample}_profile.txt" ]; then
        echo "✅ $sample terminé"
        return 0
    else
        echo "❌ $sample échoué"
        return 1
    fi
}

# === PRJNA690543 ===
DECONTAM_690543="/media/marius/EXTERNAL_USB2/gut-microbiome-reference/data/shotgun/PRJNA690543/decontaminated"
OUTPUT_690543="/media/marius/EXTERNAL_USB2/gut-microbiome-reference/results/metaphlan/PRJNA690543"
mkdir -p "$OUTPUT_690543"

echo "========================================"
echo "=== MetaPhlAn4 PRJNA690543 — 90 échantillons ==="
echo "Profils disponibles : $(ls ${OUTPUT_690543}/*_profile.txt 2>/dev/null | wc -l) / 90"
echo "========================================"

for sample in $(ls ${DECONTAM_690543}/*_clean_1.fastq.gz | xargs -n1 basename | sed 's/_clean_1.fastq.gz//'); do
    process_sample $sample $DECONTAM_690543 $OUTPUT_690543
done

echo "=== Fusion profils PRJNA690543 ==="
merge_metaphlan_tables.py ${OUTPUT_690543}/*_profile.txt \
  > ${OUTPUT_690543}/PRJNA690543_merged_profiles.txt
echo "✅ PRJNA690543 : $(ls ${OUTPUT_690543}/*_profile.txt 2>/dev/null | wc -l) / 90 profils"

# === PRJNA1157371 ===
DECONTAM_1157371="/media/marius/EXTERNAL_USB2/gut-microbiome-reference/data/shotgun/PRJNA1157371/decontaminated"
OUTPUT_1157371="/media/marius/EXTERNAL_USB2/gut-microbiome-reference/results/metaphlan/PRJNA1157371"
mkdir -p "$OUTPUT_1157371"

echo "========================================"
echo "=== MetaPhlAn4 PRJNA1157371 — 384 échantillons ==="
echo "Profils disponibles : $(ls ${OUTPUT_1157371}/*_profile.txt 2>/dev/null | wc -l) / 384"
echo "========================================"

for sample in $(ls ${DECONTAM_1157371}/*_clean_1.fastq.gz | xargs -n1 basename | sed 's/_clean_1.fastq.gz//'); do
    process_sample $sample $DECONTAM_1157371 $OUTPUT_1157371
done

echo "=== Fusion profils PRJNA1157371 ==="
merge_metaphlan_tables.py ${OUTPUT_1157371}/*_profile.txt \
  > ${OUTPUT_1157371}/PRJNA1157371_merged_profiles.txt
echo "✅ PRJNA1157371 : $(ls ${OUTPUT_1157371}/*_profile.txt 2>/dev/null | wc -l) / 384 profils"

echo "========================================"
echo "🎉 MetaPhlAn4 terminé !"
echo "========================================"
