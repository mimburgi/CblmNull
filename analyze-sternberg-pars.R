library(nparLD)
sternpars<-read.table("fastdm/Sternberg/sternbergpars_ml_150.txt", header = T, stringsAsFactors = F)

#reorganize pars
pars<-sternpars[1,c("dataset", "a_L_S", "v_L_S", "t0_L_S")]
colnames(pars)<-c("subject", "a", "v", "t0")

pars$load<-"T"
pars$stim<-"T"

loadlevels<-c("H", "M", "L")
stimlevels<-c("S", "A")


for (subj in levels(as.factor(sternpars$dataset))){
  for (stim in stimlevels){
    for (load in loadlevels){
      row<-c(
        subj,#subject
        sternpars[[paste("a", load, stim, sep = "_")]][sternpars$dataset == subj],#a
        sternpars[[paste("v", load, stim, sep = "_")]][sternpars$dataset == subj],#v
        sternpars[[paste("t0", load, stim, sep = "_")]][sternpars$dataset == subj],#t0
        load,
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
pars$load<-as.factor(pars$load)
pars$stim<-as.factor(pars$stim)

#check normality

#resp boundary
shapiro.test(pars$a) #not normal
shapiro.test(log(pars$a)) #still not normal
#one gigantic outlier, but fit looks pretty good
#woudl still be skewed even if we removed it
plot(density(pars$a)) 

#drift
shapiro.test(pars$v) #not normal
shapiro.test(log(pars$v)) #still not normal
#basically two populations because some subjects were so bd at the high one
plot(density(pars$v)) 

#t0
shapiro.test(pars$t0) #normal
plot(density(pars$t0))

ld.f2(y=pars$a, time1 = pars$load, time2 = pars$stim, time1.name = "load", time2.name = "stim", subject = pars$subject)
#load sign, follow up with paired wilcox
wilcox.test(subset(pars, load == "H")$a, subset(pars, load == "L")$a, paired = T) #this is sign
wilcox.test(subset(pars, load == "H")$a, subset(pars, load == "M")$a, paired = T)
wilcox.test(subset(pars, load == "M")$a, subset(pars, load == "L")$a, paired = T)
p.adjust(c(.003522, .1022, .1757), method = "bonferroni")
aggregate(a ~ load, data = pars, FUN = median)

#load sign, follow up with paired wilcox
ld.f2(y=pars$v, time1 = pars$load, time2 = pars$stim, time1.name = "load", time2.name = "stim", subject = pars$subject)
#theyre all different in the expected directions
wilcox.test(subset(pars, load == "H")$v, subset(pars, load == "L")$v, paired = T)
wilcox.test(subset(pars, load == "H")$v, subset(pars, load == "M")$v, paired = T)
wilcox.test(subset(pars, load == "M")$v, subset(pars, load == "L")$v, paired = T)
p.adjust(c(.000000000071, .0000000009022, .005905), method = "bonferroni")
aggregate(v ~ load, data = pars, FUN = median)

library(ez)
ezANOVA(data = pars, dv = t0, wid = subject, within = .(load, stim), type = 3, detailed = T, return_aov = T)
t0aov<-aov(t0 ~ load, data = pars)
TukeyHSD(t0aov)
aggregate(t0 ~ load, data = pars, FUN = mean) #low load quicker
aggregate(t0 ~ load, data = pars, FUN = sd) #low load quicker
