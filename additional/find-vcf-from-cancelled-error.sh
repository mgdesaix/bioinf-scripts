#!/bin/bash

touch incomplete-vcfs.txt

for err in *.err;
do 
	if grep -q 'CANCELLED' ${err} 
	then
		vcf=`sed -n -e 's/^.*ofile=//p' ${err}`
		echo ${vcf} >> incomplete-vcfs.txt
	fi
done
