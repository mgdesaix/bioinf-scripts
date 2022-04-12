# bioinf-scripts

This is a collection of bioinformatics and population genomics scripts for whole-genome sequence data, which includes working with both low-coverage data/probabilistic genotypes in [ANGSD](http://www.popgen.dk/angsd/index.php/ANGSD) and moderate coverage/SNP calling in [GATK](https://gatk.broadinstitute.org/hc/en-us). Most scripts are optimized for running large job arrays via HPC. Topics are as follows:

1.  [Data preprocessing](https://github.com/mgdesaix/bioinf-scripts/01_Preprocessing/Preprocessing.md): Includes trimming FASTQs, mapping to reference, merging, marking PCR duplicates, etc.

2.  [Probabilistic genotypes](https://github.com/mgdesaix/bioinf-scripts/02_ANGSD/ANGSD.md): Different ANGSD-y stuff for low-coverage data (<2x)

3.  [Calling SNPS](https://github.com/mgdesaix/bioinf-scripts/03_GATK/GATK.md): Base quality recalibration, filtering high-quality SNPs, etc with **not** low-coverage data (>6x). 

Actively being updated.
