#!/bin/bash 
#
#all commands that start with SBATCH contain commands that are just used by SLURM for scheduling  
#################
#set a job name  
#SBATCH --job-name=bcftoolsFilter
#SBATCH --output=./err-out/bcftoolsFilter.%j.out
#SBATCH --error=./err-out/bcftoolsFilter.%j.err
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
# filtered=AMRE.full.124.6mb.filtered.vcf
bcftools view -m 2 -M 2 --min-af 0.05 --max-af 0.95 -O z -i 'F_MISSING < 0.5 & QUAL > 30' ROFI.full.4mb.vcf.gz > ROFI.filtered.05maf.50missing.30qual.4mb.vcf.gz
bcftools index ROFI.filtered.05maf.50missing.30qual.4mb.vcf.gz
