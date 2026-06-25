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

## Fusion résultats AMR — Juin 2026

### Méthode
Script Python (`scripts/pipeline2_shotgun/08_merge_amr_results.py`) fusionnant tous les `.gene_mapping_data.txt` par dataset puis globalement :
- Agrégation des reads mappés par ARO Term (gène AMR)
- Table de comptes bruts + table de proportions relatives (par échantillon, sur total reads mappés CARD)
- Table d'annotations (AMR Gene Family, Drug Class, Resistance Mechanism)

### Résultats — Fusion globale
| Métrique | Valeur |
|---|---|
| Gènes AMR uniques (union) | 1799 |
| Échantillons | 474 (90 PRJNA690543 + 384 PRJNA1157371) |

### Classes d'antibiotiques dominantes (par fréquence de gènes)
1. Céphalosporines / pénicillines bêta-lactamines (combinées) — dominance nette
2. Monobactam / céphalosporine / pénicilline (multi-classe)
3. Aminoglycosides
4. Fluoroquinolones
5. Tétracyclines
6. Peptides antibiotiques
7. Glycopeptides (clusters van)

### Fichiers produits (par dataset + fusion globale)
- `*_AMR_counts.tsv` — reads mappés bruts (gènes × échantillons)
- `*_AMR_proportions.tsv` — abondances relatives (gènes × échantillons)
- `*_AMR_annotations.tsv` — Gene Family / Drug Class / Resistance Mechanism par gène
- Stockés sur HIKVISION (`results/AMR/`) et dupliqués sur EXTERNAL_USB3 (`results/AMR_merged/`)

### Prochaines étapes
- [ ] Analyses statistiques AMR (diversité, comparaison inter-datasets, associations avec métadonnées)
- [ ] Visualisations (heatmap RGI ou ggplot2)
- [ ] HUMAnN3 (voies métaboliques)

## Profilage fonctionnel 16S — PICRUSt2 — Juin 2026

### Outil
PICRUSt2 2.6.3 — prédiction fonctionnelle par placement phylogénétique

### Méthode
- Placement des 818 ASVs sur arbre de référence (epa-ng)
- 814/818 ASVs retenus (4 exclus — mauvais alignement)
- Méthode HSP : Maximum Parsimony (mp)
- Stratifié par espèce (--stratified)

### Résultats
| Fichier | Contenu |
|---|---|
| EC_metagenome_out/ | Enzymes prédites (EC) × 14 échantillons |
| KO_metagenome_out/ | KEGG Orthology × 14 échantillons |
| pathways_out/ | Voies MetaCyc × 14 échantillons |

### Top voies dominantes
1. PWY0-1586 : Fatty acid unsaturation (anaérobie)
2. PWY-7357  : Biosynthèse thiamine (B1)
3. PWY-7238  : Sucrose biosynthesis II
4. PWY-1042  : Glycolysis IV ✅ cohérent avec HUMAnN3
5. NONOXIPENT-PWY : Pentose phosphate pathway
6. VALSYN-PWY : L-valine biosynthesis
7. PWY-7790  : UMP biosynthesis II ✅ cohérent avec HUMAnN3

### Cohérence 16S ↔ Shotgun
Les voies métaboliques majeures (glycolyse, biosynthèse acides aminés,
UMP biosynthesis) sont détectées de manière cohérente par PICRUSt2 (16S)
et HUMAnN3 (Shotgun), validant la robustesse des résultats.

### Stockage
- Résultats : EXTERNAL_USB3/gut-microbiome-reference/results/picrust2_16S/
- Script : scripts/pipeline1_16S/05_picrust2.sh
