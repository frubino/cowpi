#!/bin/sh

INPUT_FILE=$1
OUTPUT_FILE=$2

biom convert -i $INPUT_FILE -o /dev/stdout --table-type="OTU table" --to-tsv | tail -n+2 | tr -d '#' | sed 's/OTU ID/OTU/' > $OUTPUT_FILE

python -c "import pandas as pd; df = pd.read_table('$OUTPUT_FILE', index_col=0, header=0); df['total'] = df.sum(axis=1); df.to_csv('$OUTPUT_FILE', sep='\t')"