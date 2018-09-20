
library( ncdf4)
library( fields)
setwd("~/sandbox/HPC4StatsCMIP/data")
dataFileName<- "pr_day_CCSM4_historical_r1i1p1_19550101-19891231.nc"
dataHandle <- nc_open(dataFileName)
# 25 50
# 241 250

lon<- ncvar_get(dataHandle, "lon")
 lat<- ncvar_get(dataHandle,"lat")
 
 tm<- ncvar_get(dataHandle,"time")
 m<- 120
 n<- 120
 m1<- 150
 m2<- 150 + m -1
 n1<- 50
 n2 <- n1 + n -1
 prExample<- ncvar_get(dataHandle, "pr", 
                       start = c(m1, n1, 1),
                       count=c( (m), (n),3000) )
quartz()
 look<- apply( prExample,c( 1,2), mean)
 image.plot( lon[m1:m2], lat[n1:n2], 
             log10(look) )
 map("world2", add=TRUE,col="grey20")
 
 
 m1<- 185
 m2<- 205
 n1<- 110
 n2 <- 160
 m<- m2 - m1 + 1
 n<- n2 - n1 +1
 prExample<- ncvar_get(dataHandle, "pr", 
                       start = c(m1, n1, 1),
                       count=c( (m), (n), 20*365) )
 
xr<-range (lon[m1:m2])
yr<- range(lat[n1:n2])  
xline( xr)
yline( yr)
map("world2", xlim=c(200,300), ylim=c( 0, 60))
rect(xr[1], yr[1], xr[2], yr[2], border="red")
look<- apply( prExample,c( 1,2), mean)
image.plot( lon[m1:m2], lat[n1:n2], 
            log10(look) )
map("world2", add=TRUE,col="grey20")
lonExample<- lon[m1:m2]
latExample<- lat[n1:n2]
bounds<- cbind( c( m1, m2), c( n1, n2))
prExample<-array( as.single( prExample), dim( prExample))
save(prExample,bounds,lonExample, latExample, file="prExample.rda")






