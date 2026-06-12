# Microbiote Intestinal de Référence — Burkina Faso

**Étudiant :** Marius Zida | **Master Microbiologie**
**Directeurs :** Dr. Yves Sere & Nina Gouba
**GitHub :** github.com/M922-tech/bf-microbiome-reference

---

## Objectif
Construire un microbiome intestinal de référence pour le Burkina Faso
à partir de données métagénomiques publiques.

---

## Datasets

| Dataset | Accession | Type | Échantillons | Statut |
|---|---|---|---|---|
| De Filippo 2010 | ERP000133 | 16S rRNA | 14 enfants BF | ✅ Pipeline 1 complet |
| Sonnenburg 2021 | PRJNA690543 | Shotgun | 90 adultes BF | ✅ Pipeline 2 complet |
| AWI-Gen 2 BF | PRJNA1157371 | Shotgun | 384 femmes Nanoro | ✅ Pipeline 2 complet |

---

## Pipeline 1 — 16S rRNA ✅ TERMINÉ

| Étape | Outil | Résultat |
|---|---|---|
| Import | QIIME2 | demux_seqs.qza |
| Débruitage | DADA2 | trunc=250, max-ee=3.0, ~65% conservés |
| Taxonomie | Silva 138 | Bacteroidota dominant, Prevotella abondant |
| Diversité | QIIME2 | sampling-depth=6847 |
| Fonctions | PICRUSt2 2.6.3 | Glycolyse anaérobie active |

---

## Pipeline 2 — Shotgun métagénomique ✅ TERMINÉ

### État d'avancement

| Étape | PRJNA690543 | PRJNA1157371 |
|---|---|---|
| QC FastQC + MultiQC | ✅ | ✅ 769 rapports |
| Trimming (Fastp) | ✅ | ✅ |
| Décontamination (Bowtie2 hg38) | ✅ 180/180 | ✅ 768/768 |
| MetaPhlAn4 | ✅ 90/90 profils | ✅ 384/384 profils |
| HUMAnN3 | 🔜 | 🔜 |

### Paramètres trimming

**PRJNA690543** (Phred > 35 dès position 1) :
\`\`\`
--qualified_quality_phred 20
--unqualified_percent_limit 40
--length_required 50
--detect_adapter_for_pe
--correction
\`\`\`

**PRJNA1157371** (dégradation positions 0-20) :
\`\`\`
--qualified_quality_phred 20
--unqualified_percent_limit 40
--length_required 50
--trim_front1 20
--trim_front2 20
--detect_adapter_for_pe
--correction
\`\`\`

### Paramètres MetaPhlAn4
\`\`\`
--index mpa_vJan25_CHOCOPhlAnSGB_202503
--subsampling 5000000
--subsampling_seed 42
\`\`\`
> Sous-échantillonnage validé par corrélation de Pearson = 0.9996 vs profils complets

### Résultats préliminaires MetaPhlAn4
- **Bacteroidota dominant** (~59-73%) ✅ cohérent avec Pipeline 1 (16S)
- **Firmicutes** (~6-25%)
- **Archaea** (~0.3%) détectés
- Ratio Bacteroidota/Firmicutes élevé — typique microbiome africain

---

## QC Global

| Rapport | Contenu |
|---|---|
| `results/qc_global/BF_microbiome_multiqc_report.html` | 962 FastQC + 433 Fastp = 1395 rapports |
| Total reads | 16.5 milliards |
| Moyenne/échantillon | 17.1 millions reads |
| GC moyen | 47.8% |

---

## Stockage

| Disque | Contenu |
|---|---|
| 💻 Disque interne | Scripts, référence hg38, MetaPhlAn DB |
| 💾 SSD HIKVISION | Bruts PRJNA1157371 (768 FASTQ, 833 Go) |
| 💾 EXTERNAL_USB | Décontaminés + Profils MetaPhlAn4 |

---

## Prochaines étapes
- [ ] HUMAnN3 PRJNA690543 + PRJNA1157371
- [ ] Harmonisation R/phyloseq (16S + Shotgun)
- [ ] Correction batch effect (ComBat_seq)
- [ ] Analyses statistiques + figures
- [ ] Push GitHub final

## Harmonisation 16S + Shotgun — Juin 2026

### Environnement R
- R 4.5.3 via conda (r_microbiome)
- phyloseq, MMUPHin, DESeq2, vegan, ggplot2, limma, tidyverse

### Stratégie d'harmonisation
- Agrégation au niveau genre pour les 3 datasets
- 44 genres communs aux 3 datasets
- 111 genres dans la fusion finale (intersection)
- Genres non caractérisés (GGB/SGB) sauvegardés séparément

### Résultats
| Étape | Résultat |
|---|---|
| 16S agrégé | 111 genres × 14 échantillons |
| Shotgun PRJNA690543 | 166 genres × 90 échantillons |
| Shotgun PRJNA1157371 | 245 genres × 384 échantillons |
| Fusion totale | 111 genres × 488 échantillons |
| Correction batch MMUPHin | 44 features ajustés |

### Fichiers produits
- `physeq_corrected.rds` — objet phyloseq corrigé
- `physeq_all_merged.rds` — objet phyloseq non corrigé
- `otu_corrected.tsv` — matrice abondances corrigées
- `PRJNA690543_genres_non_caracterises.tsv`
- `PRJNA1157371_genres_non_caracterises.tsv`

### Prochaines étapes
- [ ] Analyses diversité alpha (Shannon, Simpson)
- [ ] Analyses diversité beta (PCoA, Bray-Curtis)
- [ ] Espèces différentiellement abondantes (DESeq2)
- [ ] Figures publication
- [ ] HUMAnN3 (voies métaboliques)
