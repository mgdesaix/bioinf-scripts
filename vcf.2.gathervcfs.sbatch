#!/bin/bash 
#
#################
#SBATCH --job-name=gatherVcfs
#SBATCH --output=./err-out/gatherVcfs.%j.out
#SBATCH --error=./err-out/gatherVcfs.%j.err
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

mkdir err-out

module load jdk

# Run from folder with all of the vcfs and the list
# sbatch gatherVcfs.sbatch ROFI.Interval.4mb.list
# ROFI.Interval.4mb.list
vcfs=$1

ofile=ROFI.full.4mb.vcf.gz

gatk --java-options "-Xmx12g" \
    GatherVcfs \
    -I "$vcfs" \
    -O "$ofile"
