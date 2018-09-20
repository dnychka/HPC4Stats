pGP<- function(x, scale, shape, threshold){
  z<- (x - threshold)/scale
  z[ z<0]<- NA
  temp<- 1 - (1 + shape*(z))^(-1/shape)
  temp[ is.na( temp)]<- 0
  return( temp)
}

qGP<- function(p, scale, shape, threshold){
  
  ( ((1-p)^(-shape) - 1)/shape )*scale + threshold
}

dGP<-  function(x, scale, shape, threshold){
  z<- (x - threshold)/scale
  z[ z<0 ]<- NA
  out<- (1 + shape*(z))^(-1*(shape+1)/shape)/ scale
}