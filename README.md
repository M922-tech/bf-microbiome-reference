# Gut Microbiome Reference — Burkina Faso 🇧🇫

## Description
Ce projet vise à établir une base de référence du microbiote intestinal
burkinabè sur le plan taxonomique et fonctionnel, à partir de données
métagénomiques publiques (16S rRNA et shotgun).

**Étudiant :** Marius Zida  
**Directeurs :** Dr. Yves Sere & Nina Gouba  
**Programme :** Master en Microbiologie — 2025  

## Données utilisées

### Données disponibles
| Étude | Accession | Type | Population BF | Statut |
|-------|-----------|------|---------------|--------|
| De Filippo et al. 2010 | ERP000133 (ENA) | 16S V5-V6 | 14 enfants | ✅ Importées |
| Sonnenburg et al. 2021 | PRJNA690543 (NCBI) | Shotgun | 90 adultes | ✅ Téléchargé et vérifié (294 Go) |

### Données en cours d'acquisition
| Étude | Accession | Type | Population BF | Statut |
|-------|-----------|------|---------------|--------|
| AWI-Gen 2 | EGAD00001015449 (EGA) | Shotgun | 384 adultes | 🔜 Demande soumise — en attente de réponse |

### Données comparatives (à identifier)
| Population | Source | Type | Statut |
|------------|--------|------|--------|
| Autres populations africaines | MGnify/GMrepo | 16S/Shotgun | ⏳ À identifier |
| Populations internationales | MGnify/GMrepo | 16S/Shotgun | ⏳ À identifier |

## Prérequis
- Docker installé
- Image QIIME2 : quay.io/qiime2/amplicon:2025.10
- HUMAnN3 installé (v3.9)
- Git

## Installation et lancement

### 1. Cloner le dépôt
```bash
git clone https://github.com/M922-tech/gut-microbiome-reference.git
cd gut-microbiome-reference
```

### 2. Télécharger les données De Filippo 2010 (16S)
```bash
while read acc; do
    wget "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR011/${acc}/${acc}.fastq.gz" \
    -P data/16S/raw/
done < data/16S/metadata/BF_accessions.txt
```

### 3. Télécharger les données PRJNA690543 (Shotgun)
```bash
# Liste des accessions dans data/shotgun/metadata/
while read acc; do
    wget "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/.../${acc}.fastq.gz" \
    -P data/shotgun/raw/
done < data/shotgun/metadata/PRJNA690543_accessions.txt
```

### 4. Lancer l'environnement QIIME2 (Pipeline 16S)
```bash
docker run -it \
  -v ~/gut-microbiome-reference:/data \
  quay.io/qiime2/amplicon:2025.10 bash
```

## Pipelines

### Pipeline 1 — 16S rRNA (QIIME2)
| Étape | Outil | Statut |
|-------|-------|--------|
| Import données | QIIME2 | ✅ Terminé |
| Contrôle qualité | QIIME2/DADA2 | ✅ Terminé |
| Profilage taxonomique | DADA2 | ✅ Terminé |
| Profilage fonctionnel | PICRUSt2 | ✅ Terminé |

### Pipeline 2 — Shotgun métagénomique (HUMAnN3)
| Étape | Outil | Statut |
|-------|-------|--------|
| Import données PRJNA690543 | HUMAnN3 | ✅ Données prêtes |
| Import données AWI-Gen 2 | HUMAnN3 | ⏳ En attente EGA |
| Profilage taxonomique | MetaPhlAn4 | ⏳ À venir |
| Profilage fonctionnel | HUMAnN3 | ⏳ À venir |

### Pipeline 3 — Analyse comparative (R/Phyloseq)
| Étape | Outil | Statut |
|-------|-------|--------|
| Intégration des résultats | R | ⏳ À venir |
| Diversité alpha/bêta | Phyloseq | ✅ Terminé |
| Analyses statistiques | PERMANOVA/ANCOM-BC | ⏳ À venir |
| Associations maladies | SparCC/SPIEC-EASI | ⏳ À venir |

## Structure du projet
```
gut-microbiome-reference/
├── data/
│   ├── 16S/                  # De Filippo 2010
│   │   ├── raw/              # FASTQ bruts (non versionnés)
│   │   ├── metadata/         # manifest.tsv, metadata.tsv
│   │   └── qiime2_artifacts/ # Artefacts QIIME2 (non versionnés)
│   ├── shotgun/              # PRJNA690543 + AWI-Gen 2
│   │   ├── raw/              # FASTQ bruts (non versionnés)
│   │   └── metadata/         # Accessions et métadonnées
│   └── comparative/          # Données comparatives
│       ├── raw/              # FASTQ bruts (non versionnés)
│       └── metadata/
├── scripts/
│   ├── pipeline1_16S/        # Scripts QIIME2/DADA2/PICRUSt2
│   ├── pipeline2_shotgun/    # Scripts HUMAnN3/MetaPhlAn4
│   └── pipeline3_comparative/# Scripts R/Phyloseq
├── notebooks/                # Analyses documentées
├── results/
│   ├── figures/              # Graphiques
│   └── tables/               # Tableaux de résultats
└── envs/                     # Environnement logiciel
```

## Auteur
**Marius Zida** — mariuszida430@gmail.com  
Master Microbiologie, Burkina Faso
