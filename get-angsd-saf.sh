#!/bin/bash

#SBATCH --time=24:00:00
#SBATCH --output=saf_%A_%a
#SBATCH --array=1-15
#SBATCH --mail-type=ALL
#SBATCH --ntasks-per-node 4
#SBATCH --mem=16G
#SBATCH --mail-user=mgdesaix@gmail.com


list=$(awk -v N=$SLURM_ARRAY_TASK_ID 'NR == N {print $1}' list-names)
pop=$(echo $list | cut -d'-' -f2)
reference="/projects/mgdesaix@colostate.edu/reference/YWAR/YWAR.fa"

angsd -b $list -anc $reference -ref $reference \
    -P 4 \
    -dosaf 1 -gl 1 \
    -doMajorMinor 4 \
    -skipTriallelic 1 \
    -uniqueOnly 1 \
    -baq 1 \
    -minQ 20 -minMapQ 30 \
    -minInd 5 \
    -out ${pop}.filtered
