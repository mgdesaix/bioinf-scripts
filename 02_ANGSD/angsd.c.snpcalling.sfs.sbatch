#!/bin/bash 
#################
#set a job name  
#SBATCH --job-name=AMRE.sfs
#SBATCH --output=AMRE.sfs.%j.out
#SBATCH --error=AMRE.sfs.%j.err
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

# This is splitting based on 3 populations...this is messy. I have a script for multiple pops

POP1=$1
POP2=$2
POP3=$3

angsd="/home/mgdesaix@colostate.edu/programs/angsd"

 # $angsd/misc/realSFS -P 24  "$POP1".AMRE.05maf.minInd110.saf.idx  "$POP2".AMRE.05maf.minInd110.saf.idx 2> /dev/null > "$POP1"."$POP2".CAWA.05maf4.minInd90.sfs

##need to define number of sites <- CH's comment, I didn't define # of sites below
 $angsd/misc/realSFS -P 24   "$POP1".AMRE.05maf.minInd110.saf.idx "$POP2".AMRE.05maf.minInd110.saf.idx  > "$POP1"."$POP2".AMRE.05maf.minInd110.samesite.estim.ml
 $angsd/misc/realSFS -P 24   "$POP1".AMRE.05maf.minInd110.saf.idx "$POP3".AMRE.05maf.minInd110.saf.idx  > "$POP1"."$POP3".AMRE.05maf.minInd110.samesite.estim.ml
 $angsd/misc/realSFS -P 24   "$POP2".AMRE.05maf.minInd110.saf.idx "$POP3".AMRE.05maf.minInd110.saf.idx  > "$POP2"."$POP3".AMRE.05maf.minInd110.samesite.estim.ml

##FST for each site
 $angsd/misc/realSFS fst index  "$POP1".AMRE.05maf.minInd110.saf.idx \ 
 								"$POP2".AMRE.05maf.minInd110.saf.idx \
 								"$POP3".AMRE.05maf.minInd110.saf.idx \
 					 	   -sfs "$POP1"."$POP2".AMRE.05maf.minInd110.samesite.estim.ml \
 					 	        "$POP1"."$POP3".AMRE.05maf.minInd110.samesite.estim.ml \
 					 	        "$POP2"."$POP3".AMRE.05maf.minInd110.samesite.estim.ml \
 					    -fstout "$POP1"."$POP2"."$POP3".AMRE.05maf.minInd110.realsfs -whichFST 1


##FST for 50kb window, 25 kb slide
$angsd/misc/realSFS fst stats2 "$POP1"."$POP2"."$POP3".AMRE.05maf.minInd110.realsfs.fst.idx -win 50000 -step 25000 -whichFST 1 > "$POP1"."$POP2"."$POP3".AMRE.05maf.minInd110.fst.50kbwin.txt


##FST for global
$angsd/misc/realSFS fst stats "$POP1"."$POP2"."$POP3".AMRE.05maf.minInd110.realsfs.fst.idx > "$POP1"."$POP2"."$POP3".AMRE.05maf.minInd110.fst.global.txt
