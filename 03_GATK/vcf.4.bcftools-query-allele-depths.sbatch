#!/bin/bash 
#
#all commands that start with SBATCH contain commands that are just used by SLURM for scheduling  
#################
#set a job name  
#SBATCH --job-name=bcftoolsQuery
#SBATCH --output=./err-out/bcftoolsQuery.%j.out
#SBATCH --error=./err-out/bcftoolsQuery.%j.err
#################
#SBATCH -t 4:00:00
#SBATCH --qos=normal
#SBATCH --partition=shas
#################
# Note: 4.84G/core or task
#SBATCH --nodes=1
#SBATCH --ntasks-per-node 1
#SBATCH --mem=4G
#SBATCH --mail-type=FAIL 
#SBATCH  --mail-user=mgdesaix@gmail.com

#echo commands to stdout
set -x
##################  

bcftools query -f '%CHROM\t %POS [\t%AD]\n' ROFI.filtered.05maf.50missing.4mb.vcf.gz > allele_depths.txt
