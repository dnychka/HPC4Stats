HPC4Stats <- function(RNamelist=NULL,...){
  
cat("*************************************",fill=TRUE)
cat("***** Begining HPC4Stats batch script",fill=TRUE)
cat("*************************************",fill=TRUE) 
# if the R object   RNamelist is not around then read it in from the environemnt 
# grab the file name of the namelist from the environmental varaible
# HPC4Stats
if( is.null( "RNamelist") ) {
     RNamelist     <- Sys.getenv("HPC4StatsNAMELIST")
  }   
  cat("Reading R Namelist (.rnl file)", RNamelist, fill=TRUE)
  source(RNamelist)
  copyRNamelist<- scan(RNamelist, what="a", sep="\r" ) 
  cat("Done sourcing R Namelist file:", RNamelist, fill=TRUE)
  cat( "****", fill=TRUE)
  cat("Project directory set from the R namelist file: ", fill=TRUE)
  cat(  projectDir, fill=TRUE)
  cat("Working directory for this script:", fill=TRUE )
  cat(  getwd(), fill=TRUE )
#  
# sourcing RNamelist should 
# 1) define all relavent file names and constants
# 2) load all functions including  doTask
# 3) run any supervisor setup scripts.
# Essentially once the .rnl is sourced 
# It should make sense to call doTask(myTaskID)
# in the supervisor session where myTaskID is
# any  integer value that is in the task range.
#  
# figure out number of workers  
  nWorkersEnv<- Sys.getenv("HPC4StatsnWorkers")
# use the environment variable for the number of workers
# this makes it convenient instead of editing the .rnl file.  
  if( nWorkersEnv != ""){
    nWorkers<- as.numeric( nWorkersEnv )
    cat("number of workers from environment", nWorkers, fill=TRUE)
  }  
  nTask1Env<- Sys.getenv("HPC4StatsnTask1")
  if( nTask1Env != ""){
    nTask1<- as.numeric( nTask1Env )
    cat("nTask1  read from environment", fill=TRUE)
  }  
  nTask2Env<- Sys.getenv("HPC4StatsnTask2")
  if( nTask2Env != ""){
    nTask2<- as.numeric( nTask2Env )
    cat("nTask2  read from environment", fill=TRUE)
  }
# load libraries for supervisor
library( Rmpi)
if( !is.null(namesLibraries)){ 
cat( "****", fill=TRUE)  
for( objName in namesLibraries ) {
  cat( "loading library: ", objName, fill=TRUE)
  suppressPackageStartupMessages(
    library( package= objName, lib.loc = namesLibraryLocations,
           character.only = TRUE)
   )
}
}
######################################################
# following should not depend on a specific project 
###################################################### 
  cat( "****", fill=TRUE)  
  cat("number of workers", nWorkers, fill=TRUE)
  #some checks  
  nTasks<- nTask2 - nTask1 + 1
  cat("number of tasks:", nTasks, "from ", nTask1,
                   "to" , nTask2, fill=TRUE)
  if( nTasks < nWorkers){ 
    cat("nTasks: ", nTasks, " nWorkers: ", nWorkers, fill=TRUE)
    stop("Stopping. Why so many Workers?")
  }
# figure out the number of chunks if this variable is set
# 
if( !exists("chunkSize") ){
    chunkStart<- nTask1
    chunkEnd<- nTask2
    chunkSize <- 1
      }else{
       if( chunkSize < nWorkers){
        stop("chunkSize too small")
        }
  chunkStart <- seq( nTask1, nTask2 - 1, chunkSize)
  chunkEnd  <-  c(chunkStart[-1] - 1 , nTask2 )
  }
  nChunks<- length( chunkStart )
  cat( "****", fill=TRUE)  
  cat("Number of output chunks:" , nChunks, fill=TRUE)  
#  
# list R working directory  
  cat("Workspace of supervisor :", fill=TRUE) 
  ls()
############
# Rmpi it up!
############
# Spawn the workers
  tick<- proc.time()[3]
    mpi.spawn.Rslaves(nslaves=nWorkers)
  tock<- proc.time()[3]
  timeSpawn<-tock - tick

# loop over the list of data objects and  broadcast to workers
  tick<- proc.time()[3]
# if data objects not given just use all the objects in the supervisor
# workspace.
  if( !exists("namesDataObjects")){
    namesDataObjects<- ls()
    cat("NOTE: All data objects and functions in the supervisor workspace will be 
        broadcast to the workers", fill=TRUE)
  }
  for( objName in namesDataObjects ) {
  	cat("broadcasting: ", objName, fill=TRUE)
  	do.call( "mpi.bcast.Robj2slave", 
 	         list( obj = as.name(objName) ))
  } 
  # loop over the list of libraries and  broadcast to workers
  cat( "****", fill=TRUE)
  for( objName in namesLibraries ) {
    cmd<- paste0( "library( ", objName, ",
                  character.only = TRUE)")
    cat(" broadcasting library: ", objName, fill=TRUE)
    do.call( "mpi.bcast.cmd", 
             list(     cmd = "library", 
                   package = objName,
                   lib.loc = namesLibraryLocations,
            character.only = TRUE) 
             )
  } 
  tock<- proc.time()[3]
  timeBroadcast<-  tock - tick
###################################################################
 
###################################################################  
# here is where the heavy lifting happens
# do this in chunks
  if( nChunks > 1){
    chunkNames<- paste0(projectName, uniqueTime, "Chunk", 1:nChunks) 
    }else{
    chunkNames<- paste0(projectName,uniqueTime) 
    }
outputFileName<- paste0(outputDir,"/",chunkNames)
#
tick<- proc.time()[3] 
cat( "****", fill=TRUE)
for(  k in 1 : nChunks){
  tick0<- proc.time()[3]
  result <- mpi.iapplyLB( chunkStart[k] : chunkEnd[k], doTask)
  #
  tock0<- proc.time()[3]
  cat(" ", fill=TRUE)
#  
  saveList<- list( chunk = k,  
                  result = result, 
                  nTask1 = nTask1,
                  nTask2 = nTask2,
                  chunkStart = chunkStart,
                  chunkEnd = chunkEnd,
                  copyRNamelist= copyRNamelist
                  ) 
  fname<-outputFileName[k]
  chunkName<- chunkNames[k]
  cat("Time (sec) for ", chunkName, " : ",
                  tock0 - tick0, fill=TRUE)
  assign(chunkName, saveList)
  save( list=chunkName,
        file=fname)
  cat("output file: ", fname, fill= TRUE )
}
tock<- proc.time()[3]
  timeApply<- tock - tick
###################################################################  
# table of timing stats  
  timingStats<- c( timeSpawn,timeBroadcast,  timeApply)
  names( timingStats)<- c(  "Spawn", "Broadcast","Apply")
  cat( "****", fill=TRUE)
  cat("Summary", fill=TRUE)
  cat(nWorkers ," Workers  and ", nTasks, "tasks", fill=TRUE)
  cat("timing from Supervisor: ", fill=TRUE)
  print( timingStats)
  averageTime<- timeApply*nWorkers/ ( nTasks)
  cat( "average task time: timeApply*nWorkers/nTasks ", 
       averageTime, fill=TRUE )
cat( "****", fill=TRUE)
# Hints about reading back  in results
  cat( "To load an output file, in R try:", fill=TRUE)
cat( paste0("load( '",outputFileName[1],"' )"), fill=TRUE)
cat("This is a list object. Use the names function to
 list the different components", fill =TRUE)
# Listing of all the output files handy for cutting and pasting.
  if( length(outputFileName) > 1 ){
  cat("The full outputFileName list for is:", fill=TRUE)
  cat( "####", fill=TRUE)
  cat("outFileName <- ", fill=TRUE)
  dput(outputFileName)
  cat( "####", fill=TRUE)
  }
 
# close up everything -- bad things may happen if workers are not closed.
mpi.close.Rslaves()
}

