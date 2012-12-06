#!/bin/bash

file="checksums.csv"
dir=""

function usage() 
{
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
	echo -n "."
done
echo
maxbytes=$(for s in ${sums[@]}; do echo $s; done | sort -n -r - | head -1)
minbytes=$(for s in ${sums[@]}; do echo $s; done | sort -n -r - | tail -1)
maxfiles=$(for s in ${counts[@]}; do echo $s; done | sort -n -r - | head -1)
minfiles=$(for s in ${counts[@]}; do echo $s; done | sort -n -r - | tail -1)

pmaxb10=$(python -c "print $maxbytes*1.1")
pmaxb20=$(python -c "print $maxbytes*1.2")
pmaxf10=$(python -c "print $maxfiles*1.1")
pmaxf20=$(python -c "print $maxfiles*1.2")
nminb10=$(python -c "print $minbytes*0.9")
nminb20=$(python -c "print $minbytes*0.8")
nminf10=$(python -c "print $minfiles*0.9")
nminf20=$(python -c "print $minfiles*0.8")

echo "------------------------------------------------------------------"
echo "MAX:     $(python -c "print $maxbytes/1048576") MB -- ($maxbytes bytes)"
echo "MAX+10%: $(python -c "print $pmaxb10/1048576") MB -- ($pmaxb10 bytes)"
echo "MAX+20%: $(python -c "print $pmaxb20/1048576") MB -- ($pmaxb20 bytes)"
echo "------------------------------------------------------------------"
echo "MAX:     $maxfiles files"
echo "MAX+10%: $pmaxf10 files"
echo "MAX+20%: $pmaxf20 files"
echo "------------------------------------------------------------------"
echo "MIN:     $(python -c "print $minbytes/1048576") MB -- ($minbytes bytes)"
echo "MIN-10%: $(python -c "print $nminb10/1048576") MB -- ($nminb10 bytes)"
echo "MIN-20%: $(python -c "print $nminb20/1048576") MB -- ($nminb20 bytes)"
echo "------------------------------------------------------------------"
echo "MIN:     $minfiles files"
echo "MIN-10%: $nminf10 files"
echo "MIN-20%: $nminf20 files"
echo "------------------------------------------------------------------"