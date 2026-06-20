#!/bin/bash
# =============================================================
# Script 07 : Profilage AMR — RGI/CARD
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida | Juin 2026
# Outil     : RGI 6.0.8 + CARD 4.0.1
# Sortie    : /media/marius/HIKVISION/gut-microbiome-reference/results/AMR/
# Important : RGI doit être lancé depuis ~/gut-microbiome-reference
#             (localDB recherchée en chemin relatif)
# =============================================================

DECONTAM_690543="/media/marius/EXTERNAL_USB3/gut-microbiome-reference/data/shotgun/PRJNA690543/decontaminated"
DECONTAM_1157371="/media/marius/EXTERNAL_USB3/gut-microbiome-reference/data/shotgun/PRJNA1157371/decontaminated"
OUTPUT_690543="/media/marius/HIKVISION/gut-microbiome-reference/results/AMR/PRJNA690543"
OUTPUT_1157371="/media/marius/HIKVISION/gut-microbiome-reference/results/AMR/PRJNA1157371"

mkdir -p "$OUTPUT_690543" "$OUTPUT_1157371"

process_sample() {
    sample=$1
    decontam_dir=$2
    output_dir=$3
    threads=$4

    if [ -f "${output_dir}/${sample}.gene_mapping_data.txt" ]; then
        echo "⏭️  Déjà traité : $sample"
        return 0
    fi

    echo "🔄 RGI BWT : $sample"
    cd ~/gut-microbiome-reference && rgi bwt \
      --read_one ${decontam_dir}/${sample}_clean_1.fastq.gz \
      --read_two ${decontam_dir}/${sample}_clean_2.fastq.gz \
      --output_file ${output_dir}/${sample} \
      --local --clean \
      --threads ${threads} \
      --aligner bowtie2 \
      2>> ${output_dir}/${sample}_rgi.log

    STATUS=$?
    rm -f ${output_dir}/${sample}*.bam ${output_dir}/${sample}*.bai
    rm -f ${output_dir}/${sample}*.json ${output_dir}/${sample}*.sam
    rm -f ${output_dir}/${sample}*.temp.* ${output_dir}/${sample}*.seqs.temp.txt
    rm -f ${output_dir}/${sample}*.coverage*.temp.txt

    if [ $STATUS -eq 0 ]; then
        echo "✅ $sample terminé"
    else
        echo "❌ $sample échoué"
        rm -f ${output_dir}/${sample}*
    fi
}

for f in ${DECONTAM_690543}/*_clean_1.fastq.gz; do
    sample=$(basename $f | sed 's/_clean_1.fastq.gz//')
    process_sample $sample $DECONTAM_690543 $OUTPUT_690543 4
done

for f in ${DECONTAM_1157371}/*_clean_1.fastq.gz; do
    sample=$(basename $f | sed 's/_clean_1.fastq.gz//')
    process_sample $sample $DECONTAM_1157371 $OUTPUT_1157371 4
done

echo "✅ PRJNA690543  : $(ls ${OUTPUT_690543}/*.gene_mapping_data.txt 2>/dev/null | wc -l) / 90"
echo "✅ PRJNA1157371 : $(ls ${OUTPUT_1157371}/*.gene_mapping_data.txt 2>/dev/null | wc -l) / 384"
