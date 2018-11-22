#!/bin/bash

# qsub -v HIC=hicfile -v BINSIZE=50000 -v OUTPUT=outfile run_juicer.sh 
# Grid Engine options
#$ -N juicer 
#$ -cwd
#$ -l h_rt=06:00:00
#$ -l h_vmem=20g
#$ -j y

#qlogin -l h_vmem=20g

. /etc/profile.d/modules.sh

export LC_ALL=en_US.UTF-8
module load java/jdk/1.8.0

#Usage:   juicebox dump <observed/oe/norm/expected> <NONE/VC/VC_SQRT/KR> <hicFile(s)> <chr1> <chr2> <BP/FRAG> <binsize> <outfile>

juicer=/exports/igmm/eddie/NextGenResources/software/Juicebox/juicer_tools_linux_0.8.jar
tmpdir=/exports/eddie/scratch/tballing/RAO_hic/$JOB_ID
mkdir -p $tmpdir
hicfile=$HIC
if [ -e $hicfile.gz ] 
then 
	echo "gunzip $hicfile.gz"
	gunzip $hicfile.gz
fi
# binsize=50000
binsize=$BINSIZE

for i in `seq 1 22` X Y
do
echo "java -Djava.awt.headless=true  -Xmx16000m  -jar $juicer eigenvector KR $hicfile $i BP $binsize $tmpdir/Eigenvector.chr$i.out"
java -Djava.awt.headless=true  -Xmx16000m  -jar $juicer eigenvector -p KR $hicfile $i BP $binsize $tmpdir/Eigenvector.chr$i.out
# java -Djava.awt.headless=true  -Xmx16000m  -jar $juicer dump norm KR $hicfile $i BP $binsize $tmpdir/Eigenvector.chr$i.out
done

for i in `seq 1 22` X Y
do
	awk '{x=0; print "chr"chr"\t"(NR-1)*b"\t"NR*b"\t"$1}' b=$binsize chr=$i $tmpdir/Eigenvector.chr$i.out > $tmpdir/Eigenvector.chr$i.bed 
done

cat $tmpdir/Eigenvector.chr*.bed > $OUTPUT 
# rm $tmpdir/Eigenvector.chr*.out
# rm $tmpdir/Eigenvector.chr*.bed

