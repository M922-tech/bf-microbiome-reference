# =============================================================
# Script 06 : Harmonisation 16S + Shotgun — R/phyloseq
# Projet    : Gut Microbiome Reference — Burkina Faso
# Auteur    : Marius Zida
# Date      : Juin 2026
# Environnement : conda activate r_microbiome (R 4.5.3)
# =============================================================

library(phyloseq)
library(tidyverse)
library(vegan)
library(ggplot2)
library(MMUPHin)
library(DESeq2)
library(limma)

# Chemins
EXTERNAL <- "/media/marius/EXTERNAL_USB3"
PROJECT  <- "~/gut-microbiome-reference"

# Créer dossier résultats
dir.create(paste0(EXTERNAL, "/gut-microbiome-reference/results/R_analysis"),
           recursive = TRUE, showWarnings = FALSE)

# =============================================
# ÉTAPE 1 — Données 16S
# =============================================
otu_16S <- read.table(
  paste0(PROJECT, "/data/16S/exported/feature-table.tsv"),
  header = TRUE, sep = "\t", skip = 1,
  row.names = 1, check.names = FALSE, comment.char = ""
)

tax_16S <- read.table(
  paste0(PROJECT, "/data/16S/exported/taxonomy.tsv"),
  header = TRUE, sep = "\t", row.names = 1, check.names = FALSE
)

tax_split <- tax_16S %>%
  rownames_to_column("Feature.ID") %>%
  separate(Taxon,
           into = c("Kingdom","Phylum","Class","Order","Family","Genus","Species"),
           sep = ";", fill = "right") %>%
  mutate(across(Kingdom:Species, str_trim)) %>%
  mutate(across(Kingdom:Species, ~gsub("^[dpcofgs]__", "", .))) %>%
  column_to_rownames("Feature.ID") %>%
  select(-Confidence)

physeq_16S <- phyloseq(
  otu_table(as.matrix(otu_16S), taxa_are_rows = TRUE),
  tax_table(as.matrix(tax_split))
)

physeq_16S_genus <- tax_glom(physeq_16S, taxrank = "Genus", NArm = FALSE)

# Renommer taxa avec noms de genres
genres_new <- as.character(tax_table(physeq_16S_genus)[, "Genus"])
family_names <- as.character(tax_table(physeq_16S_genus)[, "Family"])
for (i in seq_along(genres_new)) {
    if (is.na(genres_new[i]) || genres_new[i] == "") {
        if (!is.na(family_names[i]) && family_names[i] != "") {
            genres_new[i] <- paste0(family_names[i], "_unclassified_", i)
        } else {
            genres_new[i] <- paste0("Unknown_", i)
        }
    }
}
dupl <- duplicated(genres_new)
genres_new[dupl] <- paste0(genres_new[dupl], "_", which(dupl))
taxa_names(physeq_16S_genus) <- genres_new

cat("✅ 16S :", ntaxa(physeq_16S_genus), "genres,", nsamples(physeq_16S_genus), "échantillons\n")

# =============================================
# ÉTAPE 2 — Données Shotgun
# =============================================
metaphlan_690543 <- read.table(
  paste0(EXTERNAL, "/gut-microbiome-reference/results/metaphlan/PRJNA690543/PRJNA690543_merged_profiles.txt"),
  header = TRUE, sep = "\t", skip = 1,
  row.names = 1, check.names = FALSE, comment.char = ""
)

metaphlan_1157371 <- read.table(
  paste0(EXTERNAL, "/gut-microbiome-reference/results/metaphlan/PRJNA1157371/PRJNA1157371_merged_profiles.txt"),
  header = TRUE, sep = "\t", skip = 1,
  row.names = 1, check.names = FALSE, comment.char = ""
)

extract_genus <- function(x) {
    parts <- strsplit(x, "\\|")[[1]]
    genus_part <- parts[grep("^g__", parts)]
    gsub("g__", "", genus_part)
}

genre_690543 <- metaphlan_690543[grep("\\|g__", rownames(metaphlan_690543)), ]
genre_690543 <- genre_690543[!grepl("\\|s__", rownames(genre_690543)), ]
rownames(genre_690543) <- sapply(rownames(genre_690543), extract_genus)

genre_1157371 <- metaphlan_1157371[grep("\\|g__", rownames(metaphlan_1157371)), ]
genre_1157371 <- genre_1157371[!grepl("\\|s__", rownames(genre_1157371)), ]
rownames(genre_1157371) <- sapply(rownames(genre_1157371), extract_genus)

# Genres non caractérisés — sauvegarder séparément
genres_non_car_690543 <- genre_690543[grepl("^GGB|^SGB|^CFGB|^OFGB|^FGB",
                                             rownames(genre_690543)), ]
genres_non_car_1157371 <- genre_1157371[grepl("^GGB|^SGB|^CFGB|^OFGB|^FGB",
                                               rownames(genre_1157371)), ]
write.table(genres_non_car_690543,
  paste0(EXTERNAL, "/gut-microbiome-reference/results/R_analysis/PRJNA690543_genres_non_caracterises.tsv"),
  sep = "\t", quote = FALSE, col.names = NA)
write.table(genres_non_car_1157371,
  paste0(EXTERNAL, "/gut-microbiome-reference/results/R_analysis/PRJNA1157371_genres_non_caracterises.tsv"),
  sep = "\t", quote = FALSE, col.names = NA)

# Genres caractérisés uniquement
genre_690543_named <- genre_690543[!grepl("^GGB|^SGB|^CFGB|^OFGB|^FGB",
                                           rownames(genre_690543)), ]
genre_1157371_named <- genre_1157371[!grepl("^GGB|^SGB|^CFGB|^OFGB|^FGB",
                                             rownames(genre_1157371)), ]

cat("✅ PRJNA690543 :", nrow(genre_690543_named), "genres caractérisés\n")
cat("✅ PRJNA1157371 :", nrow(genre_1157371_named), "genres caractérisés\n")

# =============================================
# ÉTAPE 3 — Métadonnées
# =============================================
meta_16S <- data.frame(
  sample_id  = sample_names(physeq_16S_genus),
  dataset    = "16S_DeFilippo",
  technology = "16S_rRNA",
  population = "Burkina_Faso",
  row.names  = sample_names(physeq_16S_genus)
)

meta_690543 <- data.frame(
  sample_id  = colnames(genre_690543_named),
  dataset    = "Shotgun_PRJNA690543",
  technology = "Shotgun",
  population = "Burkina_Faso",
  row.names  = colnames(genre_690543_named)
)

meta_1157371 <- data.frame(
  sample_id  = colnames(genre_1157371_named),
  dataset    = "Shotgun_PRJNA1157371",
  technology = "Shotgun",
  population = "Burkina_Faso",
  row.names  = colnames(genre_1157371_named)
)

# =============================================
# ÉTAPE 4 — Objets phyloseq
# =============================================
physeq_690543 <- phyloseq(
  otu_table(as.matrix(genre_690543_named), taxa_are_rows = TRUE),
  sample_data(meta_690543)
)

physeq_1157371 <- phyloseq(
  otu_table(as.matrix(genre_1157371_named), taxa_are_rows = TRUE),
  sample_data(meta_1157371)
)

physeq_16S_genus <- merge_phyloseq(physeq_16S_genus, sample_data(meta_16S))

# =============================================
# ÉTAPE 5 — Fusion des 3 datasets
# =============================================
physeq_all <- merge_phyloseq(physeq_16S_genus, physeq_690543, physeq_1157371)
cat("✅ Fusion :", ntaxa(physeq_all), "genres,", nsamples(physeq_all), "échantillons\n")

# =============================================
# ÉTAPE 6 — Normalisation
# =============================================
otu_matrix <- as(otu_table(physeq_all), "matrix")
meta_all   <- as(sample_data(physeq_all), "data.frame")

normalize_rel_abund <- function(x) {
    total <- sum(x, na.rm = TRUE)
    if (total == 0) return(x)
    return(x / total)
}
otu_norm <- apply(otu_matrix, 2, normalize_rel_abund)
cat("✅ Normalisation : Min =", min(otu_norm), "Max =", max(otu_norm), "\n")

# =============================================
# ÉTAPE 7 — Correction batch (MMUPHin)
# =============================================
fit_adjust <- adjust_batch(
    feature_abd = otu_norm,
    batch = "dataset",
    data = meta_all,
    control = list(verbose = TRUE)
)

otu_corrected <- fit_adjust$feature_abd_adj
cat("✅ Correction batch terminée !\n")

# =============================================
# ÉTAPE 8 — Objet phyloseq final corrigé
# =============================================
physeq_corrected <- phyloseq(
    otu_table(otu_corrected, taxa_are_rows = TRUE),
    tax_table(tax_table(physeq_all)),
    sample_data(meta_all)
)

# Sauvegarder
saveRDS(physeq_corrected,
    paste0(EXTERNAL, "/gut-microbiome-reference/results/R_analysis/physeq_corrected.rds"))
saveRDS(physeq_all,
    paste0(EXTERNAL, "/gut-microbiome-reference/results/R_analysis/physeq_all_merged.rds"))
write.table(otu_corrected,
    paste0(EXTERNAL, "/gut-microbiome-reference/results/R_analysis/otu_corrected.tsv"),
    sep = "\t", quote = FALSE, col.names = NA)

cat("✅ Harmonisation complète !\n")
print(physeq_corrected)
