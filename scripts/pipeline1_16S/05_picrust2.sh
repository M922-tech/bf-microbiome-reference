#!/bin/bash
# =============================================================
# Script 05 : Profilage fonctionnel 16S — PICRUSt2
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida | Juin 2026
# Outil     : PICRUSt2 2.6.3
# Entrée    : data/16S/exported/ (feature-table.biom + dna-sequences.fasta)
# Sortie    : EXTERNAL_USB3/results/picrust2_16S/
# Env       : conda activate picrust2
# =============================================================

# Prérequis : exporter depuis QIIME2
# docker run -t -i -v ~/gut-microbiome-reference:/data \
#   quay.io/qiime2/amplicon:2025.10 \
#   qiime tools export \
#   --input-path /data/data/16S/qiime2_artifacts/rep-seqs.qza \
#   --output-path /data/data/16S/exported/

FASTA=~/gut-microbiome-reference/data/16S/exported/dna-sequences.fasta
BIOM=~/gut-microbiome-reference/data/16S/exported/feature-table.biom
OUTPUT=/media/marius/EXTERNAL_USB3/gut-microbiome-reference/results/picrust2_16S/
TMPDIR=/media/marius/EXTERNAL_USB3/tmp

mkdir -p $TMPDIR

export TMPDIR=$TMPDIR

picrust2_pipeline.py \
  -s $FASTA \
  -i $BIOM \
  -o $OUTPUT \
  -p 8 \
  --stratified \
  --verbose \
  2>&1 | tee ${OUTPUT}/picrust2.log

echo "✅ PICRUSt2 terminé !"
echo "Fichiers produits :"
ls -lh $OUTPUT | grep -v intermediate
