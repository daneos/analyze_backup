#!/bin/bash

file="checksums.csv"
dir=""

function usage() {
	cat << EOF
Usage: $0 <OPTIONS>
Analyze backup
Options:
-d Backup directory
-h Prints this help message
Example: $0 -d /home/backup/checksums 
EOF
}

while getopts "hd:" OPTION; do
	case $OPTION in
	h)
		usage
		exit 1
		;;
	d)
		dir="$OPTARG"
		;;
	*)
		echo "Invalid option"
		usage
		exit 1;
		;;
	?)
		usage
		exit 0
		;;
	esac
done

[ -n "$dir" ] || { echo "No directory specified"; exit 1; }

backups=$(ls $dir)

declare -a sums
declare -a counts
allsum=0
allfiles=0
ii=0
for bp in ${backups[@]}
do
	ii=$[$ii + 1];
	# datetime=$(echo $bp | tr 'T' ' ')
	# echo -n "$datetime  :"
	sizes=$(cat $dir/$bp/$file | cut -d',' -f1)
	sum=0
	i=0
	for size in ${sizes[@]}
	do
		sum=$[$sum + $size];
		i=$[$i + 1];
	done
	sums[ii]=$sum;
	counts[ii]=$i;
	allsum=$[$allsum + $sum];
	allfiles=$[$allfiles + $i];
	# mb=$[$[$sum / 1024] / 1024];
	# echo "$mb MB -- ($sum bytes) -- $i files"
done
# echo -n "SUMMARY: "
# allmb=$[$[$allsum / 1024] / 1024];
# echo "$allmb MB -- ($allsum bytes) -- $allfiles files"
maxbytes=$(for s in ${sums[@]}; do echo $s; done | sort -n -r - | head -1)
minbytes=$(for s in ${sums[@]}; do echo $s; done | sort -n -r - | tail -1)
maxfiles=$(for s in ${counts[@]}; do echo $s; done | sort -n -r - | head -1)
minfiles=$(for s in ${counts[@]}; do echo $s; done | sort -n -r - | tail -1)
avgbytes=$[$allsum / $ii];
avgfiles=$[$allfiles / $ii];
echo "MAX: $[$[$maxbytes / 1024] / 1024] MB -- ($maxbytes bytes)"
echo "MAX: $maxfiles files"
echo
echo "MIN: $[$[$minbytes / 1024] / 1024] MB -- ($minbytes bytes)"
echo "MIN: $minfiles files"
echo
echo "AVG: $[$[$avgbytes / 1024] / 1024] MB -- ($avgbytes bytes)"
echo "AVG: $avgfiles files"