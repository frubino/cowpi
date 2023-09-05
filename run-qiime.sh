#!/bin/sh
#SBATCH --cpus-per-task=16
#SBATCH --mem=40G
#SBATCH --job-name=qiime
#SBATCH --error=stderr.txt
#SBATCH --output=stdout.txt
#SBATCH --time=16:00:00
#SBATCH --nodes=1

wget https://data.qiime2.org/2021.4/common/silva-138-99-tax.qza
wget https://data.qiime2.org/2021.4/common/silva-138-99-seqs.qza

module load apps/singularity
COMMAND="singularity exec core_2021.8.sif"

# import

singularity exec core_2021.8.sif qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
    --input-path data \
      --input-format CasavaOneEightSingleLanePerSampleDirFmt \
        --output-path demux-single-end.qza

# denoise/trimming

$COMMAND qiime dada2 denoise-single \
    --i-demultiplexed-seqs demux-single-end.qza \
    --p-trim-left 10 \
  --p-trunc-len 400 \
  --o-table table.qza \
  --p-n-threads 16 \
  --o-representative-sequences rep-seqs.qza \
  --o-denoising-stats denoising-stats.qza

# clustering

$COMMAND qiime vsearch cluster-features-de-novo \
  --i-table table.qza \
  --i-sequences rep-seqs.qza \
  --p-perc-identity 0.99 \
  --o-clustered-table table-dn-99.qza \
  --o-clustered-sequences rep-seqs-dn-99.qza

# classification

$COMMAND qiime feature-classifier classify-consensus-blast --i-query rep-seqs-dn-99.qza --i-reference-reads silva-138-99-seqs.qza --i-reference-taxonomy silva-138-99-tax.qza --o-classification rep-seqs-dn-99-class --verbose

# visualisation

$COMMAND qiime taxa barplot --i-table table-dn-99.qza --i-taxonomy rep-seqs-dn-99-class.qza --o-visualization rep-seqs-dn-99-class-bar

# export representative sequences

$COMMAND qiime tools export \
  --input-path rep-seqs-dn-99.qza \
    --output-path rep-seqs-dn-99-export

# export OTU table

$COMMAND qiime tools export --input-path table-dn-99.qza --output-path table-dn-99-export
