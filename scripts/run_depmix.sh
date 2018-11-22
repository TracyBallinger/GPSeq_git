#!/bin/bash

#$ -N depmix
#$ -cwd
#$ -j y
#$ -l h_rt=5:00:00  # This takes about 20 minutes with the whole genome, and 3 states.  It takes more than 2 hours for the whole genome with more than 5 states. 
#$ -l h_vmem=10G 

# Run this via: 
# qsub -v GPSEQDATA=gps_data.txt -v PARAMS=params.txt -v NSTATES=nstates -v OUTPUT=out_prefix run_depmix.sh 

# The files out_prefix_fmod.rdf and out_prefix_params.txt will be created. 
# GPSeq_data.txt should have the following columns: 
# <chr><start><end><ID><min1><min5><min10><min15><min30><on>
# params.txt should have the quantiles to break the umicounts into, 
# the labels for the quantiles, and the number of states of the HMM. 
# Ex: This is what should go into a param file that has 4 quantiles,
# one that is the bottom 75% labeled "L", 
# one that is the top 25-10%, labeled "M",
# the top 10%, "H", and the top 1%, "VH"
# There are six states.
# param.txt
# ---------------------------------
# 0.75 0.90 0.99
# L M H VH
# 6
# ---------------------------------

unset MODULEPATH
. /etc/profile.d/modules.sh
module load igmm/apps/R/3.5.0 

QUANTILES=`sed -n 1p $PARAMS | tr ' ' ':'`
QLABELS=`sed -n 2p $PARAMS | tr ' ' ':'`
# NSTATES=`sed -n 3p $PARAMS`
head -1 $PARAMS > $OUTPUT"_params.txt"
echo $NSTATES | cat $PARAMS - >> $OUTPUT"_params.txt" 
scripts=/home/tballing/bioinfsvice/GPSeq/scripts
echo "Rscript $scripts/run_depmix.R $GPSEQDATA $OUTPUT $QUANTILES $NSTATES" >> $OUTPUT"_params.txt" 
echo "Rscript $scripts/run_depmix.R $GPSEQDATA $OUTPUT $QUANTILES $NSTATES" 
Rscript $scripts/run_depmix.R $GPSEQDATA $OUTPUT $QUANTILES $NSTATES


