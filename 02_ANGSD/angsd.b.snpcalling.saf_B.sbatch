#!/bin/bash 
#
#all commands that start with SBATCH contain commands that are just used by SLURM for scheduling  
#################
#SBATCH --job-name=saf
#SBATCH --output=saf.%j.out
#SBATCH --error=saf.%j.err
#################
#SBATCH -t 24:00:00
#SBATCH --qos=normal
#SBATCH --partition=shas
################
# Note: 4.84G/core or task
#SBATCH --nodes=1
#SBATCH --ntasks-per-node 4
#SBATCH --mem=16G
#SBATCH --mail-type=FAIL
#SBATCH  --mail-user=mgdesaix@gmail.com
#################
#echo commands to stdout
set -x
##################

j=$1
outfile=$(echo "$j"|sed 's/.ind.bamlist/.CAWA.05maf.minInd90/g')

NGSTOOLS="/home/cbossu/programs/ngsTools"

$NGSTOOLS/angsd/angsd -bam "$j" -P 4 -ref reference/YWAR.fa -anc reference/YWAR.fa -dosaf 1 \
	-uniqueOnly 1 -remove_bads 1 \
	-doGlf 2 \
	-minInd 4 -doCounts 1 \
	-GL 1 -doMajorMinor 4 -doMaf 1 \
	 -doGeno 32 -doPost 1 \
	-sites CAWA.Plate1_2.bwa_dedup.05maf.minInd90.mafs.pos -out "$outfile".majmin4

