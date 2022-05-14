# coding: utf-8
import pandas as pd
import numpy as np
import sys
from pathlib import Path

try:
    otu_path = Path(sys.argv[1])
except IndexError:
    print("No OTU file was passed")
    sys.exit(2)
    
if not otu_path.exists():
    print("OTU file", otu_path, "does not exists")
    sys.exit(3)

# Reads the data from the lineage
print("Reading Taxonomy information")
df = pd.read_table("genome-lineages.tsv.gz", header=0, index_col=0)

print("Reading OTU Table", otu_path)
otu_df = pd.read_table(otu_path, skiprows=1, sep='\t', index_col=0)
otu_genomes = set(otu_df.index)

print("Reading Module Data")
with open("cowpi-data/module-data.tsv", "r") as f:
    modules = {}
    for line in f:
        try:
            mod_id, gene_id = line.strip().split()
        except ValueError:
            print(line)
        try:
            modules[mod_id].add(gene_id)
        except KeyError:
            modules[mod_id] = set([gene_id])

print("Reading Module Names")
with open('cowpi-data/module-names.tsv', 'r') as f:
    module_names = {}
    for line in f:
        try:
            mod_id, mod_name = line.strip().split('\t')
            module_names[mod_id] = mod_name
        except ValueError:
            print(line)

print("Reading Genome KOs")
with open("cowpi-data/CowPi_V1.0_ko_precalc1.tab", "r") as f:
    header = f.readline().strip().split()[1:]
    genome_modules = {}
    skipped = 0
    for idx, line in enumerate(f):
        genome_kos = set()
        if idx % 10000 == 0:
            print("Read rows:", idx, "skipped", skipped)
        
        genome_id, *values = line.strip().split()
        if genome_id not in otu_genomes:
            skipped += 1
            continue
        if genome_id == 'metadata_KEGG_Pathways':
            print("Reached end of useful information")
            break
        
        if len(values) != len(header):
            print("Problem with Length of line")
            
        for value, ko_id in zip(values, header):
            if float(value) > 0:
                genome_kos.add(ko_id)
        
        genome_mods = {}
        for mod_id, mod_kos in modules.items():
            genome_mods[mod_id] = len(mod_kos & genome_kos) / len(mod_kos) * 100
        genome_modules[genome_id] = pd.Series(genome_mods).apply(np.round, decimals=0).astype('Int8')

print("Kept", len(genome_modules), 'Skipped', skipped)
print("Making DataFrame")
module_df = pd.DataFrame.from_dict(genome_modules, orient='index')
print("Saving Data")
df.join(module_df, how='inner').rename(columns=module_names).join(otu_df, how='inner').to_csv('OTU-full-data.csv')
