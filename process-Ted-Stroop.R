#stroop
setwd("rawdata/Stroop/")
stroopfiles<-list.files(pattern = "*ef stroop*")
setwd("../../")
library(stringr)

for (filenum in 1:length(stroopfiles)){
  filename<-stroopfiles[filenum]
  if (str_sub(filename, -3, -1) != "csv"){
    filename <- paste(filename, ".csv", sep = "")
  }
  filepath<-paste("rawdata/Stroop/", filename, sep = "")
  file<-read.csv(filepath)
  #make file structures match
  file<-file[,c("trial_id", "exp_stage", "rt", "key_press", "correct_response", "correct", "condition",
                                  "stim_color", "stim_word")]
  #get session num and subnum from filename
  titlelen<-nchar(filename)
  sessionnum<-str_sub(filename, titlelen-4, titlelen-4)
  subnum<-str_sub(filename, titlelen-7, titlelen-6)
  #account for single digit subject numbers
  if (str_sub(subnum, 1, 1) == " "){#if the first character of the subnum is a space
    subnum<-str_sub(subnum, 2, 2) #keep only the second character
  } 
  #add them to df
  file$session<-sessionnum
  file$subj<-subnum
  #construct summary file
  if (filenum == 1) {#for the first file, read it in normally (to keep the header and create the file)
    stroopsummary<-file
  }
  else{#for the rest, just append to that file
    stroopsummary<-rbind(stroopsummary, file)
  }
}

#keep only the rows we need
stroopsummary<-subset(stroopsummary, trial_id == "stim" & exp_stage == "test")
#get rid of the columns that mean nothing 
stroopsummary<-stroopsummary[,c("rt", "key_press", "correct_response", "correct", "condition",
                                "stim_color", "stim_word", "session", "subj")]

#odd is real first
stroopsummary$subj<-as.numeric(as.character(stroopsummary$subj))
stroopsummary$stim[stroopsummary$subj%%2 == 1 & stroopsummary$session == "1"]<-"A"
stroopsummary$stim[stroopsummary$subj%%2 == 1 & stroopsummary$session == 2]<-"S"
stroopsummary$stim[stroopsummary$subj%%2 == 0 & stroopsummary$session == 1]<-"S"
stroopsummary$stim[stroopsummary$subj%%2 == 0 & stroopsummary$session == 2]<-"A"

#mark outliers
for (subject in stroopsummary$subj){
  mrt<-mean(stroopsummary$rt[stroopsummary$subj == subject])
  sdrt<-sd(stroopsummary$rt[stroopsummary$subj == subject])
  upperlim<-mrt + 3*sdrt
  lowerlim<-mrt - 3*sdrt
  stroopsummary$rtoutlier[stroopsummary$subj == subject & stroopsummary$rt > upperlim]<-T
  stroopsummary$rtoutlier[stroopsummary$subj == subject & stroopsummary$rt < lowerlim]<-T
}

#save summaryfile with all the extra shit we may ever need
write.table(stroopsummary, "stroopsummary.txt", row.names = F)

#format for fastdm
stroopfdminput<-subset(stroopsummary, is.na(rtoutlier))
stroopfdminput$response[stroopfdminput$correct == T]<-1
stroopfdminput$response[stroopfdminput$correct == F]<-0
stroopfdminput$response[stroopfdminput$correct == 'true']<-1
stroopfdminput$response[stroopfdminput$correct == 'false']<-0
stroopfdminput<-subset(stroopfdminput, rt > 150)
stroopfdminput$rt<-stroopfdminput$rt/1000
stroopfdminput<-stroopfdminput[c("subj", "rt", "response", "condition", "stim")]
#write fastdm files
setwd("fastdm/Stroop")
for (subject in as.factor(stroopfdminput$subj)){
  trimmedfile<-subset(stroopfdminput, subj == subject)
  trimmedfile<-trimmedfile[,c("response", "rt", "condition", "stim")]
  write.table(trimmedfile, paste(subject, "stroopfdminput.dat", sep = "_"),
              sep = " ", row.names = F, col.names = F)
}