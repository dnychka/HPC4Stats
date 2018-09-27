
getSlice<- function(numLat, dataFileName){
    load(dataFileName)
    tempData<- prExample[,numLat,]
    return( tempData)
}
