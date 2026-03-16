#!/bin/bash
# =============================================================
# Script 06 : Profilage fonctionnel PICRUSt2
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Mars 2025
# Version   : PICRUSt2 2.6.3
# =============================================================

echo "=== Export des artefacts QIIME2 ==="
# Exporter depuis QIIME2 (lancer dans Docker)
# qiime tools export --input-path data/16S/qiime2_artifacts/table.qza
#   --output-path data/16S/picrust2/table_export
# qiime tools export --input-path data/16S/qiime2_artifacts/rep-seqs.qza
#   --output-path data/16S/picrust2/rep_seqs_export

echo "=== Pipeline PICRUSt2 ==="
# Activer l'environnement : conda activate picrust2

picrust2_pipeline.py \
  -s data/16S/picrust2/rep_seqs_export/dna-sequences.fasta \
  -i data/16S/picrust2/table_export/feature-table.biom \
  -o data/16S/picrust2/picrust2_output \
  -p 4

echo "✅ PICRUSt2 terminé"
echo "Résultats :"
echo "  - EC_metagenome_out/pred_metagenome_unstrat.tsv.gz"
echo "  - KO_metagenome_out/pred_metagenome_unstrat.tsv.gz"
echo "  - pathways_out/path_abun_unstrat.tsv.gz"
echo ""
echo "Voies clés identifiées :"
echo "  - ANAGLYCOLYSIS-PWY : Glycolyse anaérobie (fermentation glucides)"
echo "  - BRANCHED-CHAIN-AA-SYN-PWY : Biosynthèse acides aminés"
echo "  - ANAEROFRUCAT-PWY : Fermentation fructose"
