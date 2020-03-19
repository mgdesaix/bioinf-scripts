#!/bin/bash
#set a job name
#SBATCH --job-name=map
#SBATCH --output=./err-out/map.%j.out
#SBATCH --error=./err-out/map.%j.err
################
#SBATCH -t 24:00:00
#SBATCH --qos=normal
#SBATCH --partition=shas
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mgdesaix@gmail.com
#################
# Note: 4.84G/core or task
#SBATCH --nodes=1
#SBATCH --ntasks-per-node 2
#################
#SBATCH --mem=8G
#################
set -x

mkdir err-out
# Run sbatch in for loop for each pair, ex. 18N00492_R1.fastq.gz
# for fq in `ls *R1.fastq.gz`; do sbatch 2.map.amre.sbatch "$fq"; done

module load jdk/1.8.0
# Variables

file=$1
sample=`echo $file | cut -f1 -d'_'`
plate=Plate4

BWA=~/programs/bwa
ID="$plate"."$sample"
reference=/projects/mgdesaix@colostate.edu/reference/YWAR.fa

"$BWA"/bwa mem -t 8 "$reference" ./"$sample"_R1.fastq.gz ./"$sample"_R2.fastq.gz > ../bwa_dedup/aln_"$sample".sam

cd ../bwa_dedup

~/programs/samtools-1.9/samtools sort -o aln_"$sample".bam aln_"$sample".sam

java -jar ~/programs/picard.jar AddOrReplaceReadGroups INPUT=aln_"$sample".bam RGID="$ID" RGLB="$plate" RGPL=illumina RGPU="$ID" RGSM="$sample" OUTPUT="$ID"_RG.bam VALIDATION_STRINGENCY=SILENT

~/programs/samtools-1.9/samtools index "$ID"_RG.bam
