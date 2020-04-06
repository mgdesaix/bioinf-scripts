#!/bin/bash
##all commands that start with SBATCH contain commands that are just used by SLURM for scheduling                                                             
#################
#set a job name
#SBATCH --job-name=haplotypeCaller
#SBATCH --output=./err-out/haplotypeCaller.%j.out
#SBATCH --error=./err-out/haplotypeCaller.%j.err
################
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

# NOTE: Before running this you need to break up the genome into intervals
# see awk script for this depending on the mb you want to break up by
# run this where the bamfiles are

module load jdk
mkdir err-out

bams=bams.list
# where list is from:                                                                                                                                        
# for list in `ls ~/scratch/AMRE/bamfiles/intervals/interval2mb/Interval.2*.list`; do sbatch /projects/mgdesaix@colostate.edu/bioinf-scripts/vcf.1.haplotypecaller.sbatch $list; done
# ex. Interval.4mb.001.list

list=$1
# reverse the list to get the last name, that way this stays standardized depending on where the lists are!
listName=`echo ${list} | rev | cut -f1 -d'/' | rev | cut -f1,2,3 -d'.'`

# reference=/projects/mgdesaix@colostate.edu/reference/leucosticte_australis_19Jul2019_YwTfa.fasta
reference=/projects/mgdesaix@colostate.edu/reference/YWAR/YWAR.fa
out=~/scratch/AMRE/gatk/haplotypecaller
ofile=${out}/pre-snip.AMRE.${listName}.vcf.gz
nfile=${out}/AMRE.${listName}.vcf.gz


gatk --java-options "-Xmx4g" \
    HaplotypeCaller \
    -R ${reference} \
    -I ${bams} \
    -O ${ofile} \
    -L ${list}

bcftools view -o ${nfile} -O z ${ofile}
bcftools index -f -t "{nfile}
