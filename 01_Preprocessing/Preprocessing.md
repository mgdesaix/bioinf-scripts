# WGS Preprocessing

Here, I provide scripts for trimming adapters, mapping to reference, marking PCR duplicates, as well as some of the handy one-liner codes I tend to forget to make all of this happen. The scripts are for running job arrays on SLURM. It's a *great* idea to test out the code from a script in an interactive session prior to submitting 100s of jobs in an array!

The order of operations for the preprocessing workflow is:

**1.** Trimming adapters ([get_trimmed.sh script](./slurm-scripts/get_trimmed.sh))

**2.** Mapping to reference ([get_mapped.sh script](./slurm-scripts/get_mapped.sh))

**3.** Merging BAMs ([get_merged.sh script](./slurm-scripts/get_merged.sh))

**4.** Marking and removing duplicates ([get_duplicates_removed.sh script](./slurm-scripts/get_duplicates_removed.sh))

To start working with all of the raw fastq files, I like to have them all together in one directory, that I call `fastqs/`. Unfortunately, this is not how they come from sequencing and instead they tend to be nested in different directories. An easy way to move all of them is with the `find` command in Linux. To collect all of the fastqs (ending with `.fq.gz`) in one place, I `cd` to the directory of interest, and then enter:

```sh
find . -name '*.fq.gz' -exec mv {} ./ \;
```

As a side note, directory organization is invaluable and I am always trying to refine my system. For example, my Brown-capped Rosy-Finch (*Leucosticte australis*) sequence data is organized in the following fashion:

```
.
+-- ROFI
|   +-- fastqs
|       +-- err-out
|       +-- raw
|           +-- a_fastq_file.1.fq.gz
|           +-- a_fastq_file.2.fq.gz
|       +-- mapped
|       +-- trimmed
|       +-- summary-stats
```

where I start with raw fastqs in the `raw/` directory, in the `fastqs/` directory, which is in the `AMRE/` directory, and the output of analyses is put in the appropriate directory. To each their own.

## 1) Trimming adapters

The first thing that needs to be done with raw fastq files is to trim the adapters off. I'll demonstrate with [Trim Galore](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/), available through [Conda/Mamba](https://anaconda.org/bioconda/trim-galore). Note that Trim Galore is a wrapper for a couple programs, one of which, FastQC, requires Java.

The basic Trim Galore command I use is:

```sh
trim_galore --paired --fastqc --cores 4 ${read1} ${read2} --output_dir ../trimmed/
```

This will trim the adapters from paired-end data and do some basic quality trimming as well. Trim Galore automatically detects the adapter sequences. Using 4 cores and 16 GB mem, this takes only 10-30 min. per sample. I run this as a job array in Slurm, which looks like:

```sh
source ~/.bashrc

conda activate cutadapt
module load jdk

read1=$(awk -v N=$SLURM_ARRAY_TASK_ID 'NR == N {print $1}' fastqs-read1-list)
read2=$(echo ${read1} | sed 's/1.fq.gz/2.fq.gz/')

cd raw/

trim_galore --paired --fastqc --cores 4 ${read1} ${read2} --output_dir ../trimmed/
```

where the ```fastqs-read1-list``` has all of my fastqs listed for the first read of the paired sequences, and I use that name to get the name of read 2 with a simple `sed` substitution above.

```sh
--% head -n 3 fastqs-read1-list
s17N04030_USPD16103200-N709-AK394_H3LJCCCX2_L5_1.fq.gz
s17N04030_USPD16103200-N709-AK394_H3LJCCCX2_L6_1.fq.gz
s17N04031_CKDL190138994-1a-N710-N504_H3LT3CCX2_L6_1.fq.gz
```

An example job script is available: [get_trimmed.sh](./slurm-scripts/get_trimmed.sh).

*Note:* Directories fill up with files and I like to have a simple naming convention for all of my job scripts, in that they start with `get_` and end with a `.sh` and the name describes the job being done or program being used. That way, a quick `ls get*` in a directory will show me all the job scripts I have (and sure, just the *sh would do the trick but I like having the prefix match).

## 2) Mapping, sorting, add read groups

In this step, I will map the paired end reads (fastq files) to the reference genome and produce a SAM file. Then I will sort, output a BAM file, and add read groups.

To map to the reference genome, I use [BWA](http://bio-bwa.sourceforge.net/bwa.shtml). Pretty much everything I use is available via Mamba/Conda. The reference genome first needs to be indexed by BWA, as well as by samtools:

```sh
bwa index reference.fasta
samtools faidx reference.fasta
```

**Note:** Make sure to check that `bwa index` builds the final file `reference.fasta.sa`. If there's not enough memory for the job then `bwa` will successfully create all indexes **except** `.sa` which is also essential. 

All my fastq files have a similar naming convention, so I am able to use the information from this to define my read groups. This script also assumes I already have `mapped/` and `read_group` directories where I store output. I do delete a temporary SAM file in this script, but generally I tend to store outputs in different directories and only delete manually after the analysis when I know it has completed successfully.

I won't go into detail here on read groups, but you can learn about them from the experts at [Broad Institute](https://gatk.broadinstitute.org/hc/en-us/articles/360035890671-Read-groups). But a key factor for our use of the read groups is making sure the sample name, which identifies an individual, is properly identified. If an individual is sequenced across multiple lanes, then all files should have the same sample name read group (RGSM). 

The meat of the script is as follows, and you can find a full example script here: [get_mapped.sh](./slurm-scripts/get_mapped.sh). Again with 4 threads and 16 GB, this takes 1-2 hours per sample for my data.

```sh
read1=$(awk -v N=$SLURM_ARRAY_TASK_ID 'NR == N {print $1}' fastqs-read1-trim-list)
# ex. 19N00143_CKDL190142002-1a-N703-N506_H723KCCX2_L7_1_val_1.fq.gz

read2=$(echo ${read1} | sed 's/1_val_1/2_val_2/')

# RGLB - read group library
rglb=$(echo ${read1} | cut -f3,4 -d_)

# RGPU - read group platform unit
rgpu=$(echo ${read1} | cut -f3 -d_)

# RGSM - read group sample
# ex. 17N04030
rgsm=$(echo ${read1} | cut -f1 -d_)

# RGPL - read group platform
rgpl=ILLUMINA

output=$(echo ${read1} | cut -f1,3,4 -d_)

bwa mem -t 4 ${reference} ./trimmed/${read1} ./trimmed/${read2} > ./mapped/${output}.sam

cd mapped/

samtools sort -o ${output}.bam ${output}.sam

rm ${output}.sam

java -jar ${picard} AddOrReplaceReadGroups I=${output}.bam RGLB=${rglb} RGPL=${rgpl} RGPU=${rgpu} RGSM=${rgsm} O=../read_group/${output}.\
RG.bam VALIDATION_STRINGENCY=SILENT
cd ../read_group
samtools index ${output}.RG.bam
```

## 3) Merging BAM files

Now that we have sorted BAM files with read groups it's time to merge them. I first make a file that has all of the *sample names*,

```sh
--% wc -l rofi-sample-list
147 rofi-sample-list
--% head -n 3 rofi-sample-list
17N04030
17N04031
17N04032
```

This sample list identifies all 147 individuals. In my ROFI data, I had 448 separate BAM files, but this will now be reduced to a data set of 147 BAM files merged for each individual. The code is below and the full script can be found here: [get_merged.sh](./slurm-scripts/get_merged.sh). This runs quick at <1 hr per sample.


```sh
conda activate /projects/mgdesaix@colostate.edu/miniconda3/envs/bioinf

sample_id=$(awk -v N=$SLURM_ARRAY_TASK_ID 'NR == N {print $1}' rofi-sample-list)
# ex. 17N04030

merge_code="samtools merge --threads 4 ./merged/${sample_id}.merged.bam"

for i in `ls ./read_group/${sample_id}*bam`; do merge_code="${merge_code} ${i}"; done

${merge_code}

samtools index ./merged/${sample_id}.merged.bam
```

**Note:** Because the `samtools merge` function is in the format `samtools merge [output] [input1 input2 ... inputn]`, the code above loops through all BAM files with this sample name and then tacks them on to the code as a character string `${merge_code}`. Once it has looped through then the code is run from the variable name `${merge_code}`.

## 4) Marking duplicates

The final cleaning of the BAM files involves removing PCR duplicates and cleaning paired-end sequences. I use `GATK` and `BamUtils` for this step. This process can take awhile and the `MarkDuplicatesSpark` function uses a lot of memory - I give it 64GB and a 24-hour window to finish (though should take a good bit less).

```sh
bam=$(awk -v N=$SLURM_ARRAY_TASK_ID 'NR == N {print $1}' rofi-merged-list)
id=$(echo ${bam} | cut -d '.' -f1)
marked=$(echo ${id}_marked.bam)
clipped=$(echo ${id}_marked_clipped.bam)

gatk MarkDuplicatesSpark -I ./merged/${bam} -O ./marked/${marked} --remove-sequencing-duplicates --tmp-dir ~/scratch/tmp

bam clipOverlap --in ./marked/${marked} --out ./overlap_clipped/${clipped} --stats
```

The `rofi-merged-list` is just a list of all merged BAMS:

```sh
--% head -n 3 rofi-merged-list
17N04030.merged.bam
17N04031.merged.bam
17N04032.merged.bam
```





