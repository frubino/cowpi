#!/bin/sh

COWPI_DATA=./cowpi-data
mkdir -p $COWPI_DATA

wget -O $COWPI_DATA/CowPi_V1.0_16S_precalculated.tab.gz "https://zenodo.org/record/1252858/files/CowPi_V1.0_16S_precalculated.tab.gz?download=1"
wget -O $COWPI_DATA/CowPi_V1.0_all_rumen_16S_combined.renamed.fas.gz "https://zenodo.org/record/1252858/files/CowPi_V1.0_all_rumen_16S_combined.renamed.fas.gz?download=1"
wget -O $COWPI_DATA/CowPi_V1.0_ko_precalc1.tab.gz "https://zenodo.org/record/1252858/files/CowPi_V1.0_ko_precalc1.tab.gz?download=1"

# Test Data
wget -O $COWPI_DATA/Huws_16S_colonisation_OTU.fas.txt "https://zenodo.org/record/1252858/files/Huws_16S_colonisation_OTU.fas.txt?download=1"
wget -O $COWPI_DATA/Huws_16S_colonisation_OTU_abundance_Table.txt "https://zenodo.org/record/1252858/files/Huws_16S_colonisation_OTU_abundance_Table.txt?download=1"

md5sum -c md5sum.txt

echo "Download Module Data"
curl http://rest.kegg.jp/link/ko/module | sed 's/md://' | sed 's/ko://' > $COWPI_DATA/module-data.tsv
curl http://rest.kegg.jp/list/module | sed 's/md://' > $COWPI_DATA/module-names.tsv

echo "Add custom Butyrate Production Module"
cat butyrate-module.tsv >> $COWPI_DATA/module-data.tsv
echo -e "M99999\t[CUSTOM] Glucose to Butyrate" >> $COWPI_DATA/module-names.tsv
