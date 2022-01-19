COWPI_DATA=./cowpi-data
OUTPUT_DATA=./output

# CowPi Data
SEQS_DB=$COWPI_DATA/CowPi_V1.0_all_rumen_16S_combined.renamed.fas

OTU_SEQS=$1
OTU_TABLE=$2
TMP_MISS=$OUTPUT_DATA/data-miss.txt
MISS_NAMES=$OUTPUT_DATA/data-missnames.txt
HITS=$OUTPUT_DATA/data-hits.txt
PICRUST_INPUT_TEXT=$OUTPUT_DATA/picrust-input.txt
PICRUST_INPUT_BIOM=$OUTPUT_DATA/OTU.biom

NORMALISED_OTU=$OUTPUT_DATA/normalized_otus.biom
METAGENOME_PRED=$OUTPUT_DATA/metagenome_predictions.biom
PATHWAYS_FILE=$OUTPUT_DATA/collpased_pathways.txt

mkdir -p $OUTPUT_DATA

# Instead of usearch use vsearch
vsearch -usearch_global $OTU_SEQS -db $SEQS_DB -id 0.75 -strand both -userout $HITS -userfields query+target -notmatched $TMP_MISS

##### New Extract names bit (actually only from none hits now

grep ">" $TMP_MISS | sed 's/.*>//' > $MISS_NAMES

# Convert format for PiCrust
Rscript --verbose convert-data.r $OTU_TABLE $HITS $MISS_NAMES $PICRUST_INPUT_TEXT

#### Convert to BIOM ####

biom convert -i $PICRUST_INPUT_TEXT -o $PICRUST_INPUT_BIOM --table-type="OTU table" --to-json

# Run PiCrust
echo "####################"
echo Normalise by copy number
normalize_by_copy_number.py --verbose -i $PICRUST_INPUT_BIOM -o $NORMALISED_OTU -c $COWPI_DATA/CowPi_V1.0_16S_precalculated.tab
echo "####################"
echo Predict metagenomes
predict_metagenomes.py --verbose -i $NORMALISED_OTU -o $METAGENOME_PRED -c $COWPI_DATA/CowPi_V1.0_ko_precalc1.tab
echo "####################" 
echo Categorise by function
categorize_by_function.py --verbose -i $METAGENOME_PRED -c KEGG_Pathways -l 3 --format_tab_delimited -o $PATHWAYS_FILE

echo "######################"
echo "Results in file $PATHWAYS_FILE"