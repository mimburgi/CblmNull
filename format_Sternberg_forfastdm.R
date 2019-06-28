summary<-read.table("sternbergsummary.txt", header = T, sep = "\t")


summary<-subset(summary, RT > 150)

#mark outliers
for (subject in summary$sub){
  mrt<-mean(summary$RT[summary$sub == subject])
  sdrt<-sd(summary$RT[summary$sub == subject])
  upperlim<-mrt + 3*sdrt
  lowerlim<-mrt - 3*sdrt
  summary$rtoutlier[summary$sub == subject & summary$RT > upperlim]<-T
  summary$rtoutlier[summary$sub == subject & summary$RT < lowerlim]<-T
}

summary$response[summary$acc == "Correct"]<-1
summary$response[summary$acc == "Incorrect"]<-0
summary$RT<-summary$RT/1000
fdminput<-subset(summary, is.na(rtoutlier))
fdminput<-fdminput[c("sub", "response", "RT", "load", "stim")]
for (subject in as.factor(fdminput$sub)){
  trimmedfile<-subset(fdminput, sub == subject)
  trimmedfile<-trimmedfile[,c("response", "RT", "load", "stim")]
  write.table(trimmedfile, paste("fastdm/Sternberg/", subject, "_sternbergfdminput.dat", sep = ""),
              row.names = F, col.names = F)
}