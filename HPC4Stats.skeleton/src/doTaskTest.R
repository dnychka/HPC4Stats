doTaskTest<- function( taskID){
  day<- taskTable[taskID]
  # stats of ozone data for given day
  out<-stats( ozone2$y[day,])
  return(out)
}