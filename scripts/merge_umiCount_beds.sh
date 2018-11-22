#!/bin/bash 

# Run this via: 
# qsub merge_umiCount_beds.sh 

#$ -N mergeumi 
#$ -cwd
#$ -w w 
#$ -j y
#$ -l h_vmem=2G
#$ -l h_rt=01:30:00
# $ -o /exports/eddie/scratch/tballing/errorlogs/$JOB_NAME.o$JOB_ID.$TASK_ID

unset MODULEPATH
. /etc/profile.d/modules.sh 
module load igmm/apps/bcbio/1.0.8

# tmpdir is where intermediate files will be written 
tmpdir=/home/tballing/scratch/$JOB_NAME.$JOB_ID
mkdir -p $tmpdir
# files are the datasets that will be merged together. 
# files=(`ls GPSeq_data/raw_bed_files/BICRO58_TK*_*n_GG__cutsiteLoc-umiCount.bed`)
files=(`ls GPSeq_data/raw_bed_files/BICRO62+83_TK*_*n_GG__cutsiteLoc-umiCount.bed`)
echo $files
beda=${files[0]}
fna=`basename $beda .bed | awk '{split($1, a, "_"); print a[2]"_"a[3]}'`
header="chr start end cs_id $fna" 
for((i=1; i< ${#files[@]}; i++)) 
do 
	bedb=${files[$i]}
	fnb=`basename $bedb .bed | awk '{split($1, a, "_"); print a[2]"_"a[3]}'`
	header="$header $fnb" 
	c1=`expr $i + 4`
	c2=`expr $i + 9`
	echo "beda: $beda, bedb: $bedb"
	bedtools intersect -wao -a $beda -b $bedb | cut -f1-$c1,$c2 > $tmpdir/testout
	bedtools intersect -v -a $bedb -b $beda \
	| awk 'BEGIN{OFS="\t"}{s="-1"; for(j=1; j< n; j++) s=s"\t-1"; print $1,$2,$3,$4,s,$5}' n=$i | cat $tmpdir/testout - | sort -k1,1 -k2,2n > $tmpdir/tmpinter.$i	
	beda=$tmpdir/tmpinter.$i
done
i=`expr $i - 1`
echo $header | tr ' ' '\t' | cat - $tmpdir/tmpinter.$i > BICRO62_all_umiCount.txt

