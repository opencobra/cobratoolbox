#obtained from German Preciat 18/05/2016

library(VennDiagram)
library(limma)
#install.packages('venneuler') #Uncommet if isn't installed
library(rJava)
library(venneuler)

vd <- venneuler(c(A=400, B=160, C=29, "A&B"=40, "A&C"=4, "B&C"=0 ,"A&B&C"=0))
plot(vd)


