# WGS Preprocessing

Here, I provide scripts for trimming adapters, mapping to reference, marking PCR duplicates, as well as some of the handy one-liner codes I tend to forget to make all of this happen.

To start working with all of the raw fastq files, I like to have them all together in one directory, that I call `fastqs/`. Unfortunately, this is not how they come from sequencing and instead they tend to be nested in different directories. An easy way to move all of them is with the `find` command in Linux. To collect all of the fastqs (ending with `.fq.gz`) in one place, I `cd` to the directory of interest, and then enter:

```sh
find . -name '*.fq.gz' -exec mv {} ./ \;
```

As a side note, directory organization is invaluable and I am always trying to refine my system. For example, my American Redstart (*Leucosticte australis*) sequence data may be organized in the following fashion:

```
.
+-- AMRE
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

### Trimming adapters

The first thing that needs to be done with raw fastq files is to trim the adapters off. I'll demonstrate with [Trim Galore](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/), available through [Conda/Mamba](https://anaconda.org/bioconda/trim-galore). Note that Trim Galore is a wrapper for a couple programs, one of which, FastQC, requires Java.

The basic Trim Galore command I use is:

```sh
trim_galore --paired --fastqc --cores 4 ${read1} ${read2} --output_dir ../trimmed/
```

This will trim the adapters from paired-end data and do some basic quality trimming as well. Trim Galore automatically detects the adapter sequences. Using 4 cores and 16 GB mem, this takes only 10-20 min. per sample. I run this as a job array in Slurm, which looks like:

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

An example job script is available: [get_trimmed.sh](./slurm-scripts/get_trimmed.sh)
