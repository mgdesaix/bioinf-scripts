#!/bin/bash 
#
#################
#SBATCH --job-name=ngsRelate
#SBATCH --output=ngsrelate.%j.out
#SBATCH --error=ngsrelate.%j.err
#################
#SBATCH -t 72:00:00
#SBATCH --qos=long
#SBATCH --partition=shas
################
# Note: 4.84G/core or task
#SBATCH --nodes=1
#SBATCH --ntasks-per-node 8
#SBATCH --mem=32G
#SBATCH --mail-type=FAIL
#SBATCH  --mail-user=mgdesaix@gmail.com
#################
#echo commands to stdout
set -x
##################

set -x

ngsRelate=~/programs/ngsRelate/ngsRelate
vcf=${1}
out=${vcf}.relatedness.p8long.noinbreeding

# ${ngsRelate} -g CAWA.Plate1_2.maf03.glf.gz -n 110 -f CAWA.Plate1_2.maf03.mafs.freq -z CAWA.Plate1_2.ind.bamlist.ind > CAWAsnp.Plate1_2.maf03.res

# Parse a VCF file!

# [-h vcf] specifies using vcf file
# [-A AF] specifies AF as allele frequency tag in vcf file
# [-T GT] specifies using called genotypes
# [-o] assumes no inbreeding (i.e. Jacquard coefficients sum to 1)
# [-c 1] uses called genotypes
# [-p 8] number of threads

${ngsRelate} -h ${vcf} -A AF -o -c 1 -p 8 -O ${out}
