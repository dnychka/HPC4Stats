## creating data slice for example
## 
library( fields)
library( ncdf4)
library( extRemes)

#
load( "~/scratch/result.rda")
dim( outObject)

lonB<- 360 - 105.27
latB<- 40
ix1<- which.min( lonB >= gridData$x)
iy1<- which.min( latB >= gridData$y)

dataDir  <- paste0("/glade/p/CMIP/CMIP5/output1/NCAR/CCSM4/historical/day/atmos",
#                   "/day/r1i1p1/files/pr_20120202")
#dataDir<- "~"
dataFile<- "pr_day_CCSM4_historical_r1i1p1_19550101-19891231.nc"
dataName<- paste0(dataDir, "/", dataFile)

dataHandle<-nc_open(dataName)
dataSlice<- ncvar_get( dataHandle, "pr",
                       start = c(    ix1,    iy1,  1),
                       count = c( 2, 2, -1)
)   
tm<- ncvar_get( dataHandle, "time")
nc_close( dataHandle)

tailProb<- .01    # quantile for picking threshhold

save( dataSlice, tm, ix1,iy1, dataFile,gridData,
      file="CMIPExample.rda" )
