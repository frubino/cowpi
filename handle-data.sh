#!/bin/sh

COWPI_DATA=cowpi-data

# Needs to remove the '-' from the alignment
echo "Removing extra characters from DB"
gzip -d -c $COWPI_DATA/CowPi_V1.0_all_rumen_16S_combined.renamed.fas.gz | tr -d '-' > $COWPI_DATA/CowPi_V1.0_all_rumen_16S_combined.renamed.fas
rm $COWPI_DATA/CowPi_V1.0_all_rumen_16S_combined.renamed.fas.gz

echo Decompress the rest of the files
gzip -d -v $COWPI_DATA/*.gz