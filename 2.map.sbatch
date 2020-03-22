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

# Run sbatch in for loop for each pair, ex. 18N03686_L3_R1.fastq.gz, set the plate as needed
# for fq in `ls *R1.fastq.gz`; do sbatch 2.map.amre.sbatch ${fq} Plate1; done

# Load java
module load jdk/1.8.0

# Use -p flag so you don't get errors if directory already exists!
mkdir -p err-out

##Variables

# ex. 18N03686_L3_R1.fastq.gz
input=${1}
# ex. Plate1
plate=${2}


# RGID - read group ID
sampleLane=`echo ${input} | cut -f1,2 -d'_'` # ex. 18N03686_L3
rgid=${plate}.${sampleLane} # ex. Plate1.18N03686_L3
# RGLB - read group library
rglb=${plate} # ex. Plate1
# RGPU - read group platform unit
rgpu=${rgid} # same as rgid
# RGSM - read group sample...I'm going to remove that s from the old one
rgsm=`echo ${input} | cut -f1 -d'_'` # 18N03686
# Output
output=${rgid}_RG.bam


BWA=~/programs/bwa
reference=/projects/mgdesaix@colostate.edu/reference/ROFI/ROFI_YwTfa_filtered.fasta

${BWA}/bwa mem -t 2 ${reference} ./${sampleLane}_R1.fastq.gz ./${sampleLane}_R2.fastq.gz > ../bwa_dedup/aln_${rgid}.sam

cd ../bwa_dedup

~/programs/samtools-1.9/samtools sort -o aln_${rgid}.bam aln_${rgid}.sam

java -jar ~/programs/picard.jar AddOrReplaceReadGroups INPUT=aln_${rgid}.bam RGID=${rgid} RGLB=${rglb} RGPL=illumina RGPU=${rgpu} RGSM=${rgsm} OUTPUT=${output} VALIDATION_STRINGENCY=SILENT

~/programs/samtools-1.9/samtools index ${output}
