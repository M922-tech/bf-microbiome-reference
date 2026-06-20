#!/usr/bin/env python3
"""
Script 08 : Fusion des résultats AMR (RGI/CARD)
Projet    : Gut Microbiome Reference — Burkina Faso
Auteur    : Marius Zida | Juin 2026

Fusionne tous les .gene_mapping_data.txt en une table unique :
lignes = gènes AMR (ARO Term), colonnes = échantillons, valeurs = All Mapped Reads
Produit aussi une table de proportions (reads AMR / reads totaux mappés CARD).
"""

import pandas as pd
import glob
import os

AMR_DIR_690543 = "/media/marius/HIKVISION/gut-microbiome-reference/results/AMR/PRJNA690543"
AMR_DIR_1157371 = "/media/marius/HIKVISION/gut-microbiome-reference/results/AMR/PRJNA1157371"
OUTPUT_DIR = "/media/marius/HIKVISION/gut-microbiome-reference/results/AMR"

def load_sample(filepath):
    """Charge un fichier gene_mapping_data.txt et retourne reads mappés par ARO Term + Drug Class + Mechanism."""
    df = pd.read_csv(filepath, sep="\t")
    # Colonnes clés : ARO Term (1), All Mapped Reads (12), Drug Class (25), Resistance Mechanism (26), AMR Gene Family (24)
    df = df[["ARO Term", "All Mapped Reads", "AMR Gene Family", "Drug Class", "Resistance Mechanism"]]
    df = df.groupby("ARO Term", as_index=False).agg({
        "All Mapped Reads": "sum",
        "AMR Gene Family": "first",
        "Drug Class": "first",
        "Resistance Mechanism": "first"
    })
    return df

def merge_dataset(amr_dir, dataset_name):
    files = sorted(glob.glob(os.path.join(amr_dir, "*.gene_mapping_data.txt")))
    print(f"=== {dataset_name} : {len(files)} échantillons trouvés ===")

    abundance_table = {}
    annotations = {}

    for f in files:
        sample = os.path.basename(f).replace(".gene_mapping_data.txt", "")
        df = load_sample(f)
        abundance_table[sample] = df.set_index("ARO Term")["All Mapped Reads"]
        for _, row in df.iterrows():
            annotations[row["ARO Term"]] = {
                "AMR_Gene_Family": row["AMR Gene Family"],
                "Drug_Class": row["Drug Class"],
                "Resistance_Mechanism": row["Resistance Mechanism"]
            }

    abund_df = pd.DataFrame(abundance_table).fillna(0)

    # Proportions relatives (par échantillon, sur le total de reads mappés sur CARD)
    prop_df = abund_df.div(abund_df.sum(axis=0), axis=1).fillna(0)

    annot_df = pd.DataFrame(annotations).T
    annot_df.index.name = "ARO_Term"

    return abund_df, prop_df, annot_df

# === PRJNA690543 ===
abund_690543, prop_690543, annot_690543 = merge_dataset(AMR_DIR_690543, "PRJNA690543")
abund_690543.to_csv(os.path.join(OUTPUT_DIR, "PRJNA690543_AMR_counts.tsv"), sep="\t")
prop_690543.to_csv(os.path.join(OUTPUT_DIR, "PRJNA690543_AMR_proportions.tsv"), sep="\t")
annot_690543.to_csv(os.path.join(OUTPUT_DIR, "PRJNA690543_AMR_annotations.tsv"), sep="\t")
print(f"✅ PRJNA690543 : {abund_690543.shape[0]} gènes AMR x {abund_690543.shape[1]} échantillons")

# === PRJNA1157371 ===
abund_1157371, prop_1157371, annot_1157371 = merge_dataset(AMR_DIR_1157371, "PRJNA1157371")
abund_1157371.to_csv(os.path.join(OUTPUT_DIR, "PRJNA1157371_AMR_counts.tsv"), sep="\t")
prop_1157371.to_csv(os.path.join(OUTPUT_DIR, "PRJNA1157371_AMR_proportions.tsv"), sep="\t")
annot_1157371.to_csv(os.path.join(OUTPUT_DIR, "PRJNA1157371_AMR_annotations.tsv"), sep="\t")
print(f"✅ PRJNA1157371 : {abund_1157371.shape[0]} gènes AMR x {abund_1157371.shape[1]} échantillons")

# === Fusion globale (union des gènes, tous échantillons) ===
abund_all = abund_690543.join(abund_1157371, how="outer").fillna(0)
prop_all = abund_all.div(abund_all.sum(axis=0), axis=1).fillna(0)
annot_all = pd.concat([annot_690543, annot_1157371]).reset_index().drop_duplicates(subset="ARO_Term").set_index("ARO_Term")

abund_all.to_csv(os.path.join(OUTPUT_DIR, "ALL_AMR_counts.tsv"), sep="\t")
prop_all.to_csv(os.path.join(OUTPUT_DIR, "ALL_AMR_proportions.tsv"), sep="\t")
annot_all.to_csv(os.path.join(OUTPUT_DIR, "ALL_AMR_annotations.tsv"), sep="\t")

print(f"\n=== BILAN FUSION GLOBALE ===")
print(f"Gènes AMR totaux (union) : {abund_all.shape[0]}")
print(f"Échantillons totaux : {abund_all.shape[1]}")
print(f"\nTop 10 classes d'antibiotiques (fréquence) :")
print(annot_all["Drug_Class"].value_counts().head(10))
