##############################################################
# To run: 
# Rscript run_depmix.R GPSeq_data.txt outputdir 0.75:0.90:0.99 L:M:H:VH 6 
# GPSeq_data.txt should have the following columns: 
# <chr><start><end><ID><t1_umicount><t2_umicount>....<tn_umicount>
# The 0.75:0.90:0.99 are the quantiles to split the counts into
# The L:M:H:VH are the labels for the quantiles
# The 6 is the number of states for the HMM

##################################################
# Read in command line arguments
args <- commandArgs(trailingOnly=TRUE)
gpsdatafile <- args[1]
outputprefix <- args[2]
quantilestr <- args[3]
myquantiles <- as.numeric(strsplit(quantilestr, ":")[[1]])
nstates <- as.numeric(args[4])

##################################################
# Load appropriate libraries
# Need to add this to R's path 
.libPaths("/exports/igmm/eddie/NextGenResources/software/R/x86_64-pc-linux-gnu-library/3.5") 
library(depmixS4)

#################################################
# Read in the data
gpsdat <- read.table(gpsdatafile, header=T) 
datcnts <- gpsdat[,c(5:ncol(gpsdat))]
datcnts[datcnts < 0]=0

#################################################
# Change the data to quantiles. 
datqnt <- datcnts 
for (j in seq(1:ncol(datcnts))){
	qvals <- c(-1, quantile(datcnts[,j], c(myquantiles, 1)))
	for (i in seq(1,(length(qvals) -1))){
        xi <- (datcnts[,j] > qvals[[i]]) & (datcnts[,j] <= qvals[[i+1]])
        datqnt[xi,j] <- i
    }
}
myntimes <- rle(as.character(gpsdat$chr))$lengths
## Creating the depmix models 
mod <- depmix(list(min5~1, min10~1, min15~1, min30~1), data=datqnt, 
		ntimes=myntimes, nstates=nstates, 
		family=list(multinomial("identity"), multinomial("identity"), multinomial("identity"), multinomial("identity")))
fmod <- fit(mod, verbose=T)

## save model 
save(fmod, file=paste0(outputprefix, "_fmod.rdf"))

