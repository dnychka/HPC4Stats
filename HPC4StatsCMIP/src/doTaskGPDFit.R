doTaskGPDFit<- function(TaskID){
  require(extRemes)
# assume that   taskTable,  threshold, returnLevelYear,  and tailProb are 
# defined in the workers session.
# that means they need to be created in supervisor session and broadcast.  
# hardwire to only consider one latitude band 
# but hooks are here to consider more than one.  
  numLat<- 1
  latID<- taskTable[TaskID]
  subDataset <- getSlice(latID, dataFileName)
  numLon<- dim( subDataset )[1]
  numResults<- 5
# outSummary is designed to handle a slice that includes several 
# latitude levels although not implemented in this code
  outSummary<-array(NA, c(numLat, numLon, numResults))
# double for loop for clarity ...  
  for( latindex in 1: numLat){
     for(lonindex in 1: numLon){
       Y <- subDataset[lonindex,latindex,]
       threshold <- quantile(Y, 1-tailProb)
       frac <- sum(Y > threshold)/length(Y)
# Fit Generalized Pareto Distribution
      GPFit <- fevd(Y, threshold=threshold, type="GP", method="MLE")
# try is a handy function that returns the error message if a function 
# call fails. 
      returnLevel <- try(
             return.level(GPFit, returnLevelYear, do.ci=FALSE)
             )
# data structure returned from inner loop
      outSummary[ latindex, lonindex, ]<-
          c(threshold, GPFit$results$par, frac=frac, returnLevel)
     }
# end loop over longitude    
}
 return( list( outSummary=outSummary, TaskID= TaskID,
               numLon= numLon, numLat=numLat)
         ) 
}  
  
