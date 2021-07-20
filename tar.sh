#!/bin/bash -l

if [ "$#" -ne 1 ]; then
  echo "This program need a parameter: please give me a floder"
  echo "Examaple)  $0 ./results/experiment/exp1"
  echo "           Each directory in this folder will be deleted after compressed into ./results/experiment/exp1/*.tar.gz"
  exit 1
fi


for base in $1/*; do
	# PASS if the "base" is a file
	if [ -f "${base}" ] ; then
	  echo "passing file ${base}"
		continue
	fi

	# compress the "base" directory into "base".tar.gz and remove the directory
	echo "tar czf ${base}.tar.gz ${base} ..."
	tar czf ${base}.tar.gz ${base}
	echo "rm -rf ${base} ..."
	rm -rf ${base}
done
