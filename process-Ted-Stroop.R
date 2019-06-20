setwd("/Users/mimburgi/Downloads")

#stroop
stroopfiles<-list.files(pattern = "*ef stroop*")

file1<-stroopfiles[1]
file2<-stroopfiles[2]
library(stringr)

title<-nchar(file1)
str_sub(file1, title-4, title-4)
str_sub(file1, title-7, title-6)




for (filenum in 1:length(stroopfiles)){
  filename<-stroopfiles[filenum]
  file<-read.csv(filename)
  
  #get session num and subnum from filename
  titlelen<-nchar(filename)
  sessionnum<-str_sub(filename, titlelen-4, titlelen-4)
  subnum<-str_sub(file1, title-7, title-6)
  #account for single digit subject numbers
  if (str_sub[subnum, 1, 1] == " "){#if the first character of the subnum is a space
    subnum<-str_sub[subnum, 2, 2] #keep only the second character
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

#still need to add tDCS condition for stroop