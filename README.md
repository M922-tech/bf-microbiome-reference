# Microbiote intestinal de référence — Burkina Faso 🇧🇫

## Description
Ce projet vise à établir une base de référence du microbiote intestinal
burkinabè sur le plan taxonomique et fonctionnel, à partir de données
métagénomiques publiques (16S rRNA et shotgun).

**Étudiant :** Marius Zida  
**Directeurs :** Dr. Yves Sere & Nina Gouba  
**Programme :** Master en Microbiologie — 2025  

## Données utilisées

### Données disponibles
| Étude | Accession | Type | Échantillons BF | Statut |
|-------|-----------|------|-----------------|--------|
| De Filippo et al. 2010 | ERP000133 (ENA) | 16S V5-V6 | 14 enfants | ✅ Importées |

### Données en cours d'acquisition
| Étude | Accession | Type | Échantillons BF | Statut |
|-------|-----------|------|-----------------|--------|
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
git clone https://github.com/M922-tech/bf-microbiome-reference.git
cd bf-microbiome-reference
```

### 2. Télécharger les données De Filippo 2010
```bash
# Les 14 accessions BF sont listées dans data/metadata/BF_accessions.txt
while read acc; do
    wget "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR011/${acc}/${acc}.fastq.gz"
done < data/metadata/BF_accessions.txt
```

### 3. Lancer l'environnement QIIME2
```bash
docker run -it \
  -v ~/bf_deFilippo_project:/data \
  quay.io/qiime2/amplicon:2025.10 bash
```

## Pipeline

| Étape | Outil | Statut |
|-------|-------|--------|
| Import données De Filippo | QIIME2 | ✅ Terminé |
| Contrôle qualité | QIIME2/DADA2 | 🔜 En cours |
| Profilage taxonomique | DADA2 | ⏳ À venir |
| Profilage fonctionnel | PICRUSt2 | ⏳ À venir |
| Analyse comparative | R/Phyloseq | ⏳ À venir |
| Associations maladies | SparCC/SPIEC-EASI | ⏳ À venir |

## Structure du projet
```
bf_deFilippo_project/
├── data/
│   ├── metadata/     # manifest.tsv, metadata.tsv, accessions
│   └── raw/          # FASTQ bruts (non versionnés)
├── scripts/          # Scripts du pipeline
├── notebooks/        # Analyses documentées
├── results/          # Figures et tableaux
│   ├── figures/
│   └── tables/
└── envs/             # Environnement logiciel
```

## Auteur
**Marius Zida** — mariuszida430@gmail.com  
Master Microbiologie, Burkina Faso
