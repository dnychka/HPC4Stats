doTaskGPDProduction<- function(TaskID){
  require(extRemes)
  # that means they need to be created in supervisor session and broadcast.  
  # hardwire to only consider one latitude band 
  # but hooks are here to consider more than one.  
  latindex<- taskTable[TaskID]
  subDataset <- getSliceNETCDF(latindex, dataFileName)
  numLon<- dim( subDataset )[1]
  # outSummary is designed to handle a slice of just one latitude
  # band
  outSummary<-array(NA, c(numLon, 5))
  # double for loop for clarity ...  
 
    for(lonindex in 1 : numLon){
      print( lonindex)
      Y <- subDataset[ lonindex,]
      threshold <- quantile(Y, 1-tailProb)
      tailData<- Y[Y > threshold]
      frac <- length(tailData)/length(Y)
      # Fit Generalized Pareto Distribution
      GPFit <- fevd(Y, threshold=threshold, type="GP", method="MLE")
      # try is a handy function that returns the error message if a function 
      # call fails. 
      returnLevel <- try(
        return.level(GPFit, returnLevelYear, do.ci=FALSE)
      )
      # data structure returned from inner loop
      outSummary[ lonindex, ]<-
        c(threshold, GPFit$results$par, frac, returnLevel)
      #print(  c(threshold, GPFit$results$par, frac, returnLevel))
    }
    # end loop over longitude    
  return( list( outSummary=outSummary, 
           TaskID = TaskID,
           numLon = numLon,
                I = 1:numLon,
                J = rep(latindex,numLon) )
  ) 
}  
