#!/bin/bash
name=JAVIERD

for project in `ls *[0-9]* -d`; do
	cd $project

	sed -s -i -e 's/\ *$//' *.vhd # *.mpf
	sed -s -i -e 's/\t/  /g' *.vhd # *.mpf
	sed -s -i -e 's/\r$//'  *.vhd # *.mpf

	files=`find . -name "*.vhd" -o -name "*.mpf" -o -name "*.png" -o -name "fichlectura.txt"| sed -e 's/^.*\///g'`
	number=`echo $project | sed -e 's/[a-zA-Z_]*//g'`
	cd ..
done;
