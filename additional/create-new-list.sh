#!/bin/bash

# run from err-out directory
touch new-lists.txt

for err in *.err;
do 
	if grep -q 'CANCELLED' ${err} 
	then
	  list=$(sed -n -e 's/^.*list=//p' ${err})
	  list_dir=$(echo ${list} | cut -d'/' -f1-8)
	  list_file=$(echo ${list} | cut -d'/' -f9 | cut -d'.' -f1-3)
	  new_list=$(echo ${list_dir}/${list_file}x1.list)
	  
		vcf=$(sed -n -e 's/^.*ofile=//p' ${err})
		vcf_dir=$(echo ${vcf} | cut -d'/' -f1-7)
		vcf_file=$(echo ${vcf} | cut -d'/' -f8)
		
		last=$(zcat ${vcf_dir}/clean.${vcf_file} | tail -n 1 | awk '{print $1 ":" $2}')
		SCAFF=$(echo ${last} | awk -F ":" '{print $1}')
		POS=$(echo $(($(echo ${last} | awk -F ":" '{print $2}')+1)))
		LENGTH=$(echo ${SCAFF} | awk -F "size" '{print $2}')
		
		awk -v scaff=$SCAFF -v pos=$POS -v len=$LENGTH '$1==scaff {print scaff ":" pos "-" len; go=1; next} go==1 {print}' ${list}> ${new_list}
		echo ${vcf} ${list} ${new_list} >> new-lists.txt
	fi
done