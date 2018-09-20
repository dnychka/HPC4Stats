doTaskGPDExample <- function(TaskID){
  require(extRemes)
  
  # pull the TS for a single gridbox
  Y <- ppt[taskTable[TaskID,1],taskTable[TaskID,2],]
  
  # all Doug's code now
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
  outSummary <-  c(threshold, GPFit$results$par, frac, returnLevel)
  
  # return the outlist
  return( list( outSummary=outSummary, TaskID= TaskID) )
}
