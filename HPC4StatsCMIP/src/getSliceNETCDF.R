
getSliceNETCDF<- function(numLat, dataFileName){
 require(ncdf4)
#  dataFileName<- "data/pr_day_CCSM4_historical_r1i1p1_19550101-19891231.nc"
dataHandle <- nc_open(dataFileName) # location of data file relative to working directory
# lon<- ncvar_get(dataHandle, "lon")
# lat<- ncvar_get(dataHandle,"lat")
# tm<- ncvar_get(dataHandle,"time")
timeRead<- system.time(
dataset <- ncvar_get(dataHandle, "pr", start = c(1, numLat, 1),
                     count=c(-1, 1,-1))
)
print( timeRead)
nc_close(dataHandle)
# NOTE: extracting just on latitude results in dataset being only 2d!
#dimTest<- dim(dataset)
return( dataset) 
}
