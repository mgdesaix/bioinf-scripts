#!/bin/bash

infile=incomplete-vcfs.txt
touch vcf-last-line.txt

for i in {2..140}
do
  # get specific line from infile, which is absolute path to vcf
  vcf=`sed -n ${i}p ${infile}`
  drop_last=$(zcat ${vcf} | tail -n 1 | awk '{print $1 ":" $2}')
  vcf_dir=`echo ${vcf} | cut -d'/' -f1-7`
  vcf_file=`echo ${vcf} | cut -d'/' -f8`
  bcftools view -Oz -t ^${drop_last} ${vcf} > ${vcf_dir}/clean.${vcf_file}
  echo ${drop_last} >> vcf-last-line.txt
done
