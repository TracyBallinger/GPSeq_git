#!/bin/bash 
# To run:
# qsub -v MATRIX=matfile.gz -v OUT=outname run_plotProfile.sh 


# SGE options
#$ -N plotprofile
#$ -cwd
#$ -l h_rt=2:00:00
#$ -l h_vmem=4G
#$ -j y 

. /etc/profile.d/modules.sh 
module load igmm/apps/python/2.7.10  # load this because it has deepTools installed

gpsdir=/home/tballing/bioinfsvice/GPSeq
gpsdatd=$gpsdir/GPSeq_data/raw_bed_files

plotProfile -m $MATRIX \
	-out $OUT.png \
	--perGroup \
	--plotTitle "Number of cuts" 

plotHeatmap -m $MATRIX -out $OUT.htmp.png
