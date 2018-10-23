\name{HPC4Stats}
\alias{HPC4Stats}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
HPC4Stats(RNamelist = NULL, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{RNamelist}{
%%     ~~Describe \code{RNamelist} here~~
}
  \item{\dots}{
%%     ~~Describe \code{\dots} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (RNamelist = NULL, ...) 
{
    cat("*************************************", fill = TRUE)
    cat("***** Begining HPC4Stats batch script", fill = TRUE)
    cat("*************************************", fill = TRUE)
    if (is.null("RNamelist")) {
        RNamelist <- Sys.getenv("HPC4StatsNAMELIST")
    }
    cat("Reading R Namelist (.rnl file)", RNamelist, fill = TRUE)
    source(RNamelist)
    copyRNamelist <- scan(RNamelist, what = "a", sep = "\r")
    cat("Done sourcing R Namelist file:", RNamelist, fill = TRUE)
    cat("****", fill = TRUE)
    cat("Project directory set from the R namelist file: ", fill = TRUE)
    cat(projectDir, fill = TRUE)
    cat("Working directory for this script:", fill = TRUE)
    cat(getwd(), fill = TRUE)
    nWorkersEnv <- Sys.getenv("HPC4StatsnWorkers")
    if (nWorkersEnv != "") {
        nWorkers <- as.numeric(nWorkersEnv)
        cat("number of workers from environment", nWorkers, fill = TRUE)
    }
    nTask1Env <- Sys.getenv("HPC4StatsnTask1")
    if (nTask1Env != "") {
        nTask1 <- as.numeric(nTask1Env)
        cat("nTask1  read from environment", fill = TRUE)
    }
    nTask2Env <- Sys.getenv("HPC4StatsnTask2")
    if (nTask2Env != "") {
        nTask2 <- as.numeric(nTask2Env)
        cat("nTask2  read from environment", fill = TRUE)
    }
    library(Rmpi)
    if (!is.null(namesLibraries)) {
        cat("****", fill = TRUE)
        for (objName in namesLibraries) {
            cat("loading library: ", objName, fill = TRUE)
            suppressPackageStartupMessages(library(package = objName, 
                lib.loc = namesLibraryLocations, character.only = TRUE))
        }
    }
    cat("****", fill = TRUE)
    cat("number of workers", nWorkers, fill = TRUE)
    nTasks <- nTask2 - nTask1 + 1
    cat("number of tasks:", nTasks, "from ", nTask1, "to", nTask2, 
        fill = TRUE)
    if (nTasks < nWorkers) {
        cat("nTasks: ", nTasks, " nWorkers: ", nWorkers, fill = TRUE)
        stop("Stopping. Why so many Workers?")
    }
    if (!exists("chunkSize")) {
        chunkStart <- nTask1
        chunkEnd <- nTask2
        chunkSize <- 1
    }
    else {
        if (chunkSize < nWorkers) {
            stop("chunkSize too small")
        }
        chunkStart <- seq(nTask1, nTask2 - 1, chunkSize)
        chunkEnd <- c(chunkStart[-1] - 1, nTask2)
    }
    nChunks <- length(chunkStart)
    cat("****", fill = TRUE)
    cat("Number of output chunks:", nChunks, fill = TRUE)
    cat("Workspace of supervisor :", fill = TRUE)
    ls()
    tick <- proc.time()[3]
    mpi.spawn.Rslaves(nslaves = nWorkers)
    tock <- proc.time()[3]
    timeSpawn <- tock - tick
    tick <- proc.time()[3]
    if (!exists("namesDataObjects")) {
        namesDataObjects <- ls()
        cat("NOTE: All data objects and functions in the supervisor workspace will be \n        broadcast to the workers", 
            fill = TRUE)
    }
    for (objName in namesDataObjects) {
        cat("broadcasting: ", objName, fill = TRUE)
        do.call("mpi.bcast.Robj2slave", list(obj = as.name(objName)))
    }
    cat("****", fill = TRUE)
    for (objName in namesLibraries) {
        cmd <- paste0("library( ", objName, ",\n                  character.only = TRUE)")
        cat(" broadcasting library: ", objName, fill = TRUE)
        do.call("mpi.bcast.cmd", list(cmd = "library", package = objName, 
            lib.loc = namesLibraryLocations, character.only = TRUE))
    }
    tock <- proc.time()[3]
    timeBroadcast <- tock - tick
    if (nChunks > 1) {
        chunkNames <- paste0(projectName, uniqueTime, "Chunk", 
            1:nChunks)
    }
    else {
        chunkNames <- paste0(projectName, uniqueTime)
    }
    outputFileName <- paste0(outputDir, "/", chunkNames)
    tick <- proc.time()[3]
    cat("****", fill = TRUE)
    for (k in 1:nChunks) {
        tick0 <- proc.time()[3]
        result <- mpi.iapplyLB(chunkStart[k]:chunkEnd[k], doTask)
        tock0 <- proc.time()[3]
        cat(" ", fill = TRUE)
        saveList <- list(chunk = k, result = result, nTask1 = nTask1, 
            nTask2 = nTask2, chunkStart = chunkStart, chunkEnd = chunkEnd, 
            copyRNamelist = copyRNamelist)
        fname <- outputFileName[k]
        chunkName <- chunkNames[k]
        cat("Time (sec) for ", chunkName, " : ", tock0 - tick0, 
            fill = TRUE)
        assign(chunkName, saveList)
        save(list = chunkName, file = fname)
        cat("output file: ", fname, fill = TRUE)
    }
    tock <- proc.time()[3]
    timeApply <- tock - tick
    timingStats <- c(timeSpawn, timeBroadcast, timeApply)
    names(timingStats) <- c("Spawn", "Broadcast", "Apply")
    cat("****", fill = TRUE)
    cat("Summary", fill = TRUE)
    cat(nWorkers, " Workers  and ", nTasks, "tasks", fill = TRUE)
    cat("timing from Supervisor: ", fill = TRUE)
    print(timingStats)
    averageTime <- timeApply * nWorkers/(nTasks)
    cat("average task time: timeApply*nWorkers/nTasks ", averageTime, 
        fill = TRUE)
    cat("****", fill = TRUE)
    cat("To load an output file, in R try:", fill = TRUE)
    cat(paste0("load( '", outputFileName[1], "' )"), fill = TRUE)
    cat("This is a list object. Use the names function to\n list the different components", 
        fill = TRUE)
    if (length(outputFileName) > 1) {
        cat("The full outputFileName list for is:", fill = TRUE)
        cat("####", fill = TRUE)
        cat("outFileName <- ", fill = TRUE)
        dput(outputFileName)
        cat("####", fill = TRUE)
    }
    mpi.close.Rslaves()
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
