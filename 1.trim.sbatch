#!/bin/bash
#set a job name
#SBATCH --job-name=trim
#SBATCH --output=./err-out/trim.%j.out
#SBATCH --error=./err-out/trim.%j.err
################
#SBATCH -t 24:00:00
#SBATCH --qos=normal
#SBATCH --partition=shas
#SBATCH --mail-type=FAIL
#################
# Note: 4.84G/core or task
#SBATCH --nodes=1
#SBATCH --ntasks-per-node 2
#################
#SBATCH --mem=8G
#################
set -x

mkdir err-out
#Run in terminal: 
#for fqgz in `ls *1.fq.gz`; do sbatch 1.trim.amre.sbatch $fqgz; done

###Identify program directories
FASTUNIQ=/home/mgdesaix@colostate.edu/programs/FastUniq/source # Directory for fastuniq

outdir=/scratch/summit/mgdesaix@colostate.edu/AMRE/redo-sequence/fastuniq-out
### Variables
# ex. DNASERU3038_CKDL200146239-1a-N701-N507_H772MCCX2_L1_1.fq.gz
fqgz=$1
sample=`echo $fqgz | cut -f1 -d'_'`
fastq=`echo $fqgz | cut -f1,2,3,4 -d'_'`

###Remove duplicates (potential PCR artifacts) using fastuniq

	echo $fastq\_1.fq > pair.$sample\.txt
	echo $fastq\_2.fq >> pair.$sample\.txt
	gunzip $fastq\_1.fq.gz
	gunzip $fastq\_2.fq.gz
	$FASTUNIQ/fastuniq -i pair.$sample.txt -t q -o $outdir\/$sample\_R1.fastq -p $outdir\/$sample\_R2.fastq
	gzip -f $fastq\_1.fq
	gzip -f $fastq\_2.fq
	gzip -f $outdir\/$sample\_R1.fastq
	gzip -f $outdir\/$sample\_R2.fastq
	rm pair."$sample".txt
