doTaskTEST<- function(TaskID){

  # that means they need to be created in supervisor session and broadcast.  
  # hardwire to only consider one latitude band 
  # but hooks are here to consider more than one.  
  latindex<- taskTable[TaskID]
  subDataset <- getSlice(latindex, dataFileName)
  numLon<- dim( subDataset )[1]
  # outSummary is designed to handle a slice of just one latitude
  # band
  outSummary<-array(NA, c(numLon, 5))
  # double for loop for clarity ...  
 
    for(lonindex in 1 : numLon){
      Y <- subDataset[ lonindex,]
      threshold <- quantile(Y, 1-tailProb)
      tailData<- Y[Y > threshold]
      frac <- length(tailData)/length(Y)
      qStat<- quantile( tailData , probs = c(.5,.9,.99) )
      # fill data structure returned from loop
      outSummary[ lonindex, ]<-
        c(threshold, qStat, frac)
    }
    # end loop over longitude    
  return( list( outSummary=outSummary, TaskID= TaskID,
                numLon= numLon, I = 1:numLon, J = rep(latindex,numLon) )
  ) 
}  