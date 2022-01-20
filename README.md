# CowPi for running under a Conda Environment

# Prepare

* clone the repository
* create the environment
* download the necessary data

## Install Environment

`conda env create -f cowpi-env.yml` to install the requirements. Will also check that files are correct.

## Download CowPi Data

Use script `get-data.sh` and it will create a directory `cowpi-data`.

## Correct/Decompress Data
CowPi data needs to be decompressed, but the DB is in aligned FASTA format, so `-` must be removed. Use `handle-data.sh`.

# CowPi Specifics

CowPi expects as input a FASTA file with the OTU representatives and a OTU count table. The table needs to:
* sample names with *NO SPACES*
* last column is names *total* and is the sum of the row
* rows are the OTU and colums are the samples
* First column is the header

# If Using QIIME2
> I'm assuming that you used the command `qiime vsearch cluster-features-de-novo`

To export files from QIIME2 to use with CowPi, you need to export them. Other type of clustering may have different names, but I can only assume what I usually use. Additionally, you run the `convert-qiime2-biom.sh` script on the BIOM file exported by QIIME2.

## Representative Sequences
It's the file specified with `--o-clustered-sequences`

```bash
qiime tools export \
    --input-path representative-seqs.qza \
    --output-path representative-seqs-export
```
Which will create directory `representative-seqs-export` with a FASTA file in it.

## OTU Table
It's the file specified with `--o-clustered-table`
```bash
qiime tools export --input-path otu-table.qza --output-path otu-table-export
```
Which will create directory `otu-table-export` with a BIOM file in it.

Assuming the file is in `otu-table-export/feature-table.biom`, run:

```bash
sh convert-qiime2-biom.sh otu-table-export/feature-table.biom feature-table.tsv
```

This will create a file `feature-table.tsv` can now be used with CowPi.

> The sample names are not changed, so take care that no spaces are there.

# Run CowPi
If everything is correctly prepared, just run
```bash
sh run-cowpi.sh otu-seqs.fa otu-table.tsv
```

This will create a directory names `output` and all intermediate files in it. The final output is called `collapased_pathways.txt`. From v0.2, two more files are produced: `collapsed_modules.tsv` and `collapsed_modules_reduced.tsv`. These files includes Keegg Module data, instead of Pathways and the second one only includes KOs that are unique to the Module.

> You will notice that a OTU table whose samples are integers will be renamed from `1000` to `X1000`. This is something that *R* makes automatically when loading a dataframe.