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
| Sonnenburg 2021 | PRJNA690543 | Shotgun | 90 adultes BF | ✅ Décontaminé |
| AWI-Gen 2 BF | PRJNA1157371 | Shotgun | 384 femmes Nanoro | ✅ Décontaminé |

---

## Pipeline 1 — 16S rRNA ✅ TERMINÉ

| Étape | Outil | Résultat |
|---|---|---|
| Import | QIIME2 | demux_seqs.qza |
| Débruitage | DADA2 | trunc=250, max-ee=3.0, 65.3% conservés |
| Taxonomie | Silva 138 | Bacteroidota dominant, Prevotella abondant |
| Diversité | QIIME2 | sampling-depth=6847 |
| Fonctions | PICRUSt2 2.6.3 | Glycolyse anaérobie active |

---

## Pipeline 2 — Shotgun métagénomique

### État d'avancement

| Étape | PRJNA690543 | PRJNA1157371 |
|---|---|---|
| QC FastQC + MultiQC | ✅ | ✅ 769 rapports |
| Trimming (Fastp) | ✅ | ✅ |
| Décontamination (Bowtie2 hg38) | ✅ 180/180 | ✅ 768/768 |
| MetaPhlAn4 | 🔜 | 🔜 |
| HUMAnN3 | 🔜 | 🔜 |

### Paramètres trimming retenus après analyse MultiQC

**PRJNA690543** (Phred > 35 dès position 1 — pas de dégradation) :
\`\`\`
--qualified_quality_phred 20
--unqualified_percent_limit 40
--length_required 50
--detect_adapter_for_pe
--correction
\`\`\`

**PRJNA1157371** (Orange positions 0-20 — biais amorçage) :
\`\`\`
--qualified_quality_phred 20
--unqualified_percent_limit 40
--length_required 50
--trim_front1 20
--trim_front2 20
--detect_adapter_for_pe
--correction
\`\`\`

---

## Stockage

| Disque | Contenu |
|---|---|
| 💻 Disque interne (~191 Go dispo) | Projet, scripts, résultats QC |
| 💾 SSD HIKVISION | Bruts PRJNA1157371 (768 FASTQ, 833 Go) |
| 💾 EXTERNAL_USB1 (1.9 To) | Décontaminés PRJNA690543 + PRJNA1157371 |

---

## Prochaines étapes
- [ ] Installation base de données MetaPhlAn4
- [ ] MetaPhlAn4 PRJNA690543 + PRJNA1157371
- [ ] HUMAnN3 PRJNA690543 + PRJNA1157371
- [ ] Harmonisation métadonnées + correction effets batch (MMUPHin)
- [ ] Analyses R (diversité, statistiques, figures)
