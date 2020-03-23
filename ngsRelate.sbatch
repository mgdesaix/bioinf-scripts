#!/bin/bash 
#
#################
#SBATCH --job-name=ngsRelate
#SBATCH --output=ngsrelate.%j.out
#SBATCH --error=ngsrelate.%j.err
#################
#SBATCH -t 24:00:00
#SBATCH --qos=normal
#SBATCH --partition=shas
################
# Note: 4.84G/core or task
#SBATCH --nodes=1
#SBATCH --ntasks-per-node 1
#SBATCH --mem=4G
#SBATCH --mail-type=FAIL
#SBATCH  --mail-user=mgdesaix@gmail.com
#################
#echo commands to stdout
set -x
##################

set -x

ngsRelate=~/programs/ngsRelate/ngsRelate
vcf=${1}
out=${vcf}.relatedness

# ${ngsRelate} -g CAWA.Plate1_2.maf03.glf.gz -n 110 -f CAWA.Plate1_2.maf03.mafs.freq -z CAWA.Plate1_2.ind.bamlist.ind > CAWAsnp.Plate1_2.maf03.res

# Parse a VCF file!

${ngsRelate} -h ${vcf} -A AF -c 1 -O ${out}
