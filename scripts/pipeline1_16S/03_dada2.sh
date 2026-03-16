#!/bin/bash
# =============================================================
# Script 03 : Débruitage DADA2
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Mars 2025
# Paramètres optimisés après test comparatif
# =============================================================

echo "=== Débruitage DADA2 (pyrosequencing 454) ==="
echo "Paramètres : trim-left=20, trunc-len=250, max-ee=3.0"

qiime dada2 denoise-pyro \
  --i-demultiplexed-seqs /data/data/16S/qiime2_artifacts/demux_seqs.qza \
  --p-trim-left 20 \
  --p-trunc-len 250 \
  --p-max-ee 3.0 \
  --o-table /data/data/16S/qiime2_artifacts/table.qza \
  --o-representative-sequences /data/data/16S/qiime2_artifacts/rep-seqs.qza \
  --o-denoising-stats /data/data/16S/qiime2_artifacts/denoising-stats.qza \
  --o-base-transition-stats /data/data/16S/qiime2_artifacts/base-transition-stats.qza \
  --p-n-threads 0 \
  --verbose

echo "✅ DADA2 terminé — 65.3% reads conservés"
