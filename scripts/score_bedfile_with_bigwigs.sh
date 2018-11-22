#!/bin/bash 

# Run this via the following: 
# qsub -v BEDFILE=bedfile -v BIGWIGS=bigwig.list -v OUT=out.txt score_bedfile_with_bigwigs.sh 

#$ -N bigwig 
#$ -cwd
#$ -j y 
#$ -l h_rt=1:00:00
#$ -l h_vmem=3G
# $ -pe sharedmem 1 
# $ -o /exports/eddie/scratch/tballing/$JOB_NAME.o$JOB_ID.$TASK_ID 

unset MODULEPATH
. /etc/profile.d/modules.sh
module load igmm/apps/bcbio/20160916

NextGenDir=/exports/igmm/eddie/NextGenResources
scratch=/exports/eddie/scratch/tballing/bigwig

mkdir -p $scratch/$JOB_ID
tmpdir=$scratch/$JOB_ID

LC_ALL=C sort -k1,1 -k2,2n $BEDFILE | awk '{x++; print $1"\t"$2"\t"$3"\t"x}' > $tmpdir/bedfile.bed 
sort -k4,4n $tmpdir/bedfile.bed > $tmpdir/fout.txt
echo -e "chr\tstart\tend\tid" > $tmpdir/header.txt 

for bigwig in `cat $BIGWIGS`;
do 
	label=`basename $bigwig .bigWig`
	$NextGenDir/software/bigWigAverageOverBed $bigwig $tmpdir/bedfile.bed $tmpdir/out.tab
	sort -k1,1n $tmpdir/out.tab | cut -f5 | paste $tmpdir/fout.txt - > $tmpdir/tmp 
	mv $tmpdir/tmp $tmpdir/fout.txt
	echo $label | paste $tmpdir/header.txt - > $tmpdir/htmp 
	mv $tmpdir/htmp $tmpdir/header.txt  
done 
cat $tmpdir/header.txt $tmpdir/fout.txt > $OUT

