#!/bin/bash
# =============================================================
# Script 05 : Analyse de diversité
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Mars 2025
# =============================================================

echo "=== Construction arbre phylogénétique ==="
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences /data/data/16S/qiime2_artifacts/rep-seqs.qza \
  --o-alignment /data/data/16S/qiime2_artifacts/aligned-rep-seqs.qza \
  --o-masked-alignment /data/data/16S/qiime2_artifacts/masked-aligned-rep-seqs.qza \
  --o-tree /data/data/16S/qiime2_artifacts/unrooted-tree.qza \
  --o-rooted-tree /data/data/16S/qiime2_artifacts/rooted-tree.qza \
  --p-n-threads 0

echo "=== Core metrics phylogénétiques ==="
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny /data/data/16S/qiime2_artifacts/rooted-tree.qza \
  --i-table /data/data/16S/qiime2_artifacts/table.qza \
  --p-sampling-depth 6847 \
  --m-metadata-file /data/data/16S/metadata/metadata.tsv \
  --output-dir /data/data/16S/qiime2_artifacts/diversity

echo "=== Diversité alpha ==="
qiime diversity alpha-group-significance \
  --i-alpha-diversity /data/data/16S/qiime2_artifacts/diversity/shannon_vector.qza \
  --m-metadata-file /data/data/16S/metadata/metadata.tsv \
  --o-visualization /data/data/16S/qiime2_artifacts/diversity/shannon-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity /data/data/16S/qiime2_artifacts/diversity/faith_pd_vector.qza \
  --m-metadata-file /data/data/16S/metadata/metadata.tsv \
  --o-visualization /data/data/16S/qiime2_artifacts/diversity/faith-pd-significance.qzv

echo "=== Diversité bêta ==="
qiime diversity beta-group-significance \
  --i-distance-matrix /data/data/16S/qiime2_artifacts/diversity/bray_curtis_distance_matrix.qza \
  --m-metadata-file /data/data/16S/metadata/metadata.tsv \
  --m-metadata-column dada2_quality \
  --o-visualization /data/data/16S/qiime2_artifacts/diversity/bray-curtis-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix /data/data/16S/qiime2_artifacts/diversity/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file /data/data/16S/metadata/metadata.tsv \
  --m-metadata-column dada2_quality \
  --o-visualization /data/data/16S/qiime2_artifacts/diversity/weighted-unifrac-significance.qzv \
  --p-pairwise

echo "✅ Diversité terminée"
echo "Note : p-values non significatives attendues — population homogène"
echo "Comparaisons inter-populations prévues en Avril-Mai"
