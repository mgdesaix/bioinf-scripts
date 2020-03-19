#!/bin/bash 
#
#all commands that start with SBATCH contain commands that are just used by SLURM for scheduling  
#################
#set a job name  
#SBATCH --job-name=snpcalling
#SBATCH --output=snpcalling.%j.out
#SBATCH --error=snpcalling.%j.err
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


#AMRE.ind.bamlist
j=$1
outfile=$(echo $j|sed 's/.ind.bamlist//g')

#no glf file, but does get you the beagle file
 angsd -bam "$j" -P 4 -ref /projects/mgdesaix@colostate.edu/reference/YWAR.fa \
       -uniqueOnly 1 -remove_bads 1 \
       -trim 0 -maxDepth 500 -doGlf 2 \
       -minMapQ 20 -minQ 30 -minInd 89 -doCounts 1 \
       -GL 1 -doMajorMinor 1 -doMaf 1 -skipTriallelic 1 \
       -SNP_pval 1e-6 -doGeno 32 -doPost 1 -minMaf 0.05  -out "$outfile".05maf.minInd89

#gets the glf file
#  angsd -bam "$j" -P 28 -ref /projects/mgdesaix@colostate.edu/reference/YWAR.fa \
# 	-uniqueOnly 1 -remove_bads 1 \
# 	-trim 0 -maxDepth 500 -doGlf 3 \
# 	-minMapQ 20 -minQ 30 -minInd 70 -doCounts 1 \
# 	-gl 2 -doMajorMinor 1 -doMaf 1 -skipTriallelic 1 \
# 	-SNP_pval 1e-6 -doGeno 32 -doPost 1 -minMaf 0.05  -out "$outfile".05maf.minInd70.glf

