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

~/programs/ngsRelate/ngsRelate -g CAWA.Plate1_2.maf03.glf.gz -n 110 -f CAWA.Plate1_2.maf03.mafs.freq -z CAWA.Plate1_2.ind.bamlist.ind > CAWAsnp.Plate1_2.maf03.res



