#!/bin/bash
# =============================================================
# Script 02 : Import des données dans QIIME2
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Mars 2025
# =============================================================

echo "=== Import des données dans QIIME2 ==="

docker run -it \
  -v ~/gut-microbiome-reference:/data \
  quay.io/qiime2/amplicon:2025.10 bash -c "

qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path /data/data/16S/metadata/manifest.tsv \
  --input-format SingleEndFastqManifestPhred33V2 \
  --output-path /data/data/16S/qiime2_artifacts/demux_seqs.qza

echo '✅ Import terminé : data/16S/qiime2_artifacts/demux_seqs.qza'
"
