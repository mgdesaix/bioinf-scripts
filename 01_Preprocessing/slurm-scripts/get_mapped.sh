#!/bin/bash
#set a job name
#SBATCH --job-name=ROFI-bwa-map
#SBATCH --output=./err-out/bwa-map-ROFI.%A_%a.out
#SBATCH --error=./err-out/bwa-map-ROFI.%A_%a.err
################
#SBATCH --time=24:00:00
#SBATCH --qos=normal
#SBATCH --partition=shas
#################
# Note: 4.84G/core or task
#################
#SBATCH --mem=16G
#SBATCH --array=1-448
#################

source ~/.bashrc

conda activate /projects/mgdesaix@colostate.edu/miniconda3/envs/bioinf
module load jdk

picard=/projects/mgdesaix@colostate.edu/programs/picard.jar

read1=$(awk -v N=$SLURM_ARRAY_TASK_ID 'NR == N {print $1}' fastqs-read1-list)
# ex. A9033_CKDL200146239-1a-N703-N505_H772MCCX2_L1_1.fq.gz

read1_trim=$(echo ${read1} | sed 's/1.fq.gz/1_val_1.fq.gz/')
# ex. A9033_CKDL200146239-1a-N703-N505_H772MCCX2_L1_1_val_1.fq.gz

read2_trim=$(echo ${read1} | sed 's/1.fq.gz/2_val_2.fq.gz/')

cd trimmed/

