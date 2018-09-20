
# In UNIX on YS: module load R/3.0.1
# read in results from parallel fitting
  library( extRemes)
# some helpful functions (e.g. GP pdf) for later
  source("GPFunctions.R")
# load in data set in R binary format
# makeExampleData.R for how this was created from reading the 
# historical NCAR/CMIP run 
  load("CMIPExample.rda")

#
  Y<- dataSlice[1,1,]
# normalize to cm/day, I still find kg/m^2/sec mysterious!
  Y<- Y*3600*24/10
  tailProb<- .01
  threshold<- quantile( Y, 1- tailProb)
# fitting GP to data
  GPFit<- fevd( Y, threshold=threshold, type="GP",
             method="MLE")
  plot( GPFit)
  return.level( GPFit, 100, do.ci=TRUE)

# GEV fit
  Y<- dataSlice[1,1,]
# normalize to cm/day, I still find kg/m^2/sec mysterious
  Y<- Y*3600*24/10 
# extract years from each time
  yr<- floor((tm- min( tm))/365.25)
# A more correct but obscure way: 
# library( lubridate)  
# realYears<- year( as.Date( tm, origin="1850-01-01")) 
# yearly maxima:
  Ymax<- tapply( Y, yr, "max")
# fitting GP to data
  GEVFit<- fevd( Ymax, type="GEV",
               method="MLE")
  return.level( GEVFit, 100, do.ci=TRUE)





GPFit$results$par
scale<- GPFit$results$par[1]
shape<- GPFit$results$par[2]

xg<- seq( threshold, 10,,200)
ind<- Y > threshold
##########
xg<- seq( threshold, 10,,200)
ind<- Y>threshold
Yt<- Y[ind]
# to find real dates tDates<- as.Date( tm, origin="1850-01-01")

# work with GP function  for
# concreteness
source( "GPFunctions.R")

# histogram fit
hist( Yt, nclass=20, prob=TRUE,
      border="green1",
      col="green4")
lines( xg, dGP(xg,scale, shape, threshold), lwd=2, col="grey")

# return levels ( in years)
yr<- seq(10,500,,100)
r1<- return.level( GPFit, yr, do.ci=TRUE)
matplot(yr, r1, log="x", type="l" , lty=c(2,1,2),
        col=c(2,1,2), lwd=2)


 
