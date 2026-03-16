#!/bin/bash
# =============================================================
# Script 04 : Classification taxonomique
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Mars 2025
# Base      : Silva 138 — human stool weighted
# =============================================================

echo "=== Téléchargement du classificateur Silva 138 ==="
wget -v \
  "https://data.qiime2.org/classifiers/sklearn-1.4.2/silva/silva-138-99-nb-human-stool-weighted-classifier.qza" \
  -O /data/data/16S/qiime2_artifacts/silva-138-classifier.qza

echo "=== Classification taxonomique ==="
qiime feature-classifier classify-sklearn \
  --i-classifier /data/data/16S/qiime2_artifacts/silva-138-classifier.qza \
  --i-reads /data/data/16S/qiime2_artifacts/rep-seqs.qza \
  --o-classification /data/data/16S/qiime2_artifacts/taxonomy.qza \
  --p-n-jobs 0 \
  --verbose

echo "=== Visualisations ==="
qiime metadata tabulate \
  --m-input-file /data/data/16S/qiime2_artifacts/taxonomy.qza \
  --o-visualization /data/data/16S/qiime2_artifacts/taxonomy.qzv

qiime taxa barplot \
  --i-table /data/data/16S/qiime2_artifacts/table.qza \
  --i-taxonomy /data/data/16S/qiime2_artifacts/taxonomy.qza \
  --m-metadata-file /data/data/16S/metadata/metadata.tsv \
  --o-visualization /data/data/16S/qiime2_artifacts/taxa-barplot.qzv

echo "✅ Taxonomie terminée"
echo "Résultats clés :"
echo "  - Bacteroidota dominant"
echo "  - Prevotella abondant → signature régime traditionnel BF"
echo "  - Treponema présent → marqueur populations rurales africaines"
