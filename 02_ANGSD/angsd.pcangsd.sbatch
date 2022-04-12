#!/bin/bash 
#
#################
#SBATCH --job-name=pcangsd
#SBATCH --output=pcangsd.%j.out
#SBATCH --error=pcangsd.%j.err
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

# num=$2
file=$1

module load python

# python ~/programs/pcangsd/pcangsd.py -beagle $file  -n $num -o "$file".pcangsd -threads 10
# I don't see a -n option in the documentation so I removed that
python ~/programs/pcangsd/pcangsd.py -beagle $file -o "$file".pcangsd -threads 4


