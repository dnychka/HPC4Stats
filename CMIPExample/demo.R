#grab data
load("/Users/cooleyd/Dropbox/Tex Files (1)/EnvrPaper/R Stuff/historical.maxima.Rdata")
ls()
class(past.maxima)
length(past.maxima)
dim(past.maxima[[1]])
ens1 <- 8640000*past.maxima[[1]]  #grabs first ensemble member, converts to cm/day


#lon/lat info
load("/Users/cooleyd/Dropbox/Tex Files (1)/EnvrPaper/R Stuff/lonlat.Rdata")
Longitude <- (360-lon[189:235])*-1
Latitude <- lat[123:149]


#quick image of first year's annual maxima
library(fields)
image.plot(x = Longitude, y = Latitude, z = ens1[1,,])
US(add = T)
#add dot at FC grid cell
lon.fc <- 17
lat.fc <- 18
points(Longitude[17], Latitude[18], pch = 19)


#get and fit FC data
fcAnnMax <- ens1[, 17, 18]
library(extRemes)
?fevd
gevFitOut <- fevd(x = fcAnnMax, type = "GEV")
gevFitOut
return.level(gevFitOut, return.period = 100, alpha = .05)
ci(gevFitOut, return.period = 100)

#fit nonstationary GEV
load("Research/Miranda/Data/avgTempHistorical.RData")
plot(fcAnnMax)
dataMatrix <- data.frame(cbind(avgTempHistorical, fcAnnMax))
head(dataMatrix)
nsGevFitOut <- fevd(x = fcAnnMax, data = dataMatrix, type = "GEV", location.fun = ~avgTempHistorical)
nsGevFitOut
attributes(nsGevFitOut)
nsGevFitOut$results

library(evd)
mu0 <- nsGevFitOut$results$par[1]
mu1 <- nsGevFitOut$results$par[2]
loc <- mu0 + avgTempHistorical*mu1
sigma <- nsGevFitOut$results$par[3]
xi <- nsGevFitOut$results$par[4]
line.1 <- qgev(p = .1, loc = loc, scale = sigma, shape = xi)
line.5 <- qgev(p = .5, loc = loc, scale = sigma, shape = xi)
line.9 <- qgev(p = .9, loc = loc, scale = sigma, shape = xi)
x <- seq(1, 86)
lines(x, line.1, lty = 3)
lines(x, line.5, lty = 3)
lines(x, line.9, lty = 3)





