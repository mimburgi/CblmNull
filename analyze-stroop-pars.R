
strooppars<-read.table("fastdm/Stroop/strooppars_ml_150.txt", header = T, stringsAsFactors = F)


#reorganize pars
pars<-strooppars[1,c("dataset", "a_congruent_S", "v_congruent_S", "t0_congruent_S")]
colnames(pars)<-c("subject", "a", "v", "t0")

pars$cond<-"T"
pars$stim<-"T"

condlevels<-c("congruent", "incongruent")
stimlevels<-c("S", "A")


for (subj in levels(as.factor(strooppars$dataset))){
  for (stim in stimlevels){
    for (cond in condlevels){
      row<-c(
        subj,#subject
        strooppars[[paste("a", cond, stim, sep = "_")]][strooppars$dataset == subj],#a
        strooppars[[paste("v", cond, stim, sep = "_")]][strooppars$dataset == subj],#v
        strooppars[[paste("t0", cond, stim, sep = "_")]][strooppars$dataset == subj],#t0
        cond,
        stim
      )
      pars<-rbind(pars, row)
    }
  }
}


pars<-pars[-c(1),]

pars$a<-as.numeric(pars$a)
pars$v<-as.numeric(pars$v)
pars$t0<-as.numeric(pars$t0)
pars$subject<-as.factor(pars$subject)
pars$cond<-as.factor(pars$cond)
pars$stim<-as.factor(pars$stim)

library(ez)

#resp boundary
shapiro.test(pars$a) #not normal
shapiro.test(log(pars$a)) #still not normal
#good amount of upper range "outliers"
#probably don't want to remove that many
plot(density(pars$a)) 

#drift
shapiro.test(pars$v) #not normal
shapiro.test(log(pars$v)) #still not normal
#looks like two upper range outliers
plot(density(pars$v)) 
#try removing them
shapiro.test(pars$v[pars$v < 10]) #still not normal
#try a log transform of the subset
#this is now normal, but possibly confusing
#would require us to remove a couple of subjects entirely to use an ANOVA
shapiro.test(log(pars$v[pars$v < 10]))

#t0
shapiro.test(pars$t0) #not normal
shapiro.test(log(pars$t0)) #still not normal
#skewed distribution, possibly indicating anticipatory responses?
#the subject raw data does't look out of the ordinary
plot(density(pars$t0))

#try nonpar
library(nparLD)

#nothing sign
ld.f2(y=pars$a, time1 = pars$cond, time2 = pars$stim, time1.name = "cond", time2.name = "stim", subject = pars$subject)

#better drift for cong than incong
ld.f2(y=pars$v, time1 = pars$cond, time2 = pars$stim, time1.name = "cond", time2.name = "stim", subject = pars$subject)
aggregate(v ~ cond, data = pars, FUN = median)

#nonsign
ld.f2(y=pars$t0, time1 = pars$cond, time2 = pars$stim, time1.name = "cond", time2.name = "stim", subject = pars$subject)
