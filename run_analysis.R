##Entry point for the whole process
## - inputFolder is the root folder where the files have been unzipped
## - outputFolder is the folder to leave the outcome from the process
fullProcess<-function(inputFolder, outputFolder)
{
  ##
  ##First step: merge training & tests set, return the name of the folder
  ##where it is possible to find merged subject/X_test/Y_test 
  mergedFolder<-mergeTrnAndTest(inputFolder, outputFolder)
  ##
  ##Second step: reduces the merged file, just select columns
  ## - Read variables of the measures (only the second column)
  allVariables<-read.table(getFileName(inputFolder,"/features.txt"),sep=" ")[,2]
  filterVars<-c("-std()","-mean()")
  redmgdFile<-selectColumns(allVariables,filterVars,mergedFolder, outputFolder)
  ##
  ##Third step: replace activity code by namesv
  activityLabels<-read.table(getFileName(inputFolder,"/activity_labels.txt"),sep=" ")
  redmgdFileActLabel<-relabelActivityNames(redmgdFile,activityLabels, outputFolder)
  ##
  ##Last step: summarizez dataset (activity, subject, average(variable))
  summarizedFile<-summByActAndSub(redmgdFileActLabel, outputFolder)
}
##
##Merge training & tests set, return the name of the csv file
mergeTrnAndTest<-function(inputFolder, outputFolder)
{
  ##
  ##
  destFolder<-paste(outputFolder,"/step1",sep="")
  dir.create(destFolder,recursive=TRUE)
  ##subject  
  fileSubject<-mergeFiles(getFileName(inputFolder,"/train/subject_train.txt"),
                          getFileName(inputFolder,"/test/subject_test.txt"),
                          getFileName(destFolder,"/subject.txt"))
  ##X
  fileSubject<-mergeFiles(getFileName(inputFolder,"/train/x_train.txt"),
                          getFileName(inputFolder,"/test/x_test.txt"),
                          getFileName(destFolder,"/x.txt")) 
  ##Y
  fileSubject<-mergeFiles(getFileName(inputFolder,"/train/Y_train.txt"),
                          getFileName(inputFolder,"/test/Y_test.txt"),
                          getFileName(destFolder,"/Y.txt")) 
   
  destFolder
}
##
##Responsible for merging file1 & file 2 into fileoutput
mergeFiles<-function(file1, file2, fileoutput)
{
  table1<-read.table(file1)
  if (file.exists(fileoutput))
    file.remove(fileoutput)
  file.create(fileoutput)
  write.table(table1,file=fileoutput,append=FALSE,row.names=FALSE,col.names=FALSE)
  table2<-read.table(file2)
  write.table(table2,file=fileoutput,append=TRUE,row.names=FALSE,col.names=FALSE)
  fileoutput
}

getFileName<-function(folder, filename)
{
  fname<-paste(folder,filename,sep="")
  fname
}
##
##
selectColumns<-function(allVariables,filterVars,mergedFolder, outputFolder)
{
  ##
  ##Filter variables (take only those with mean & std)
  filterVariables=vector()
  for (var in filterVars)
    filterVariables=sort(c(filterVariables,grep(var,allVariables,fixed=TRUE)))
  ##
  ##
  ##Read subject
  subject<-read.table(getFileName(mergedFolder,"/subject.txt"))
  ##Activity
  activity<-read.table(getFileName(mergedFolder,"/y.txt"))
  ##Observations (only those matching the criteria)
  observations<-read.table(getFileName(mergedFolder,"/x.txt"))[,posvariables]
  ##Merge values
  observations<-cbind(subject,activity,observations)
  ##Names
  namestotal<-c("subject","activity",as.character(allVariables)[filterVariables])
  ##Assign names
  names(observations)<-namestotal
  ##Write file
  destFolder<-paste(outputFolder,"/step2",sep="")
  dir.create(destFolder,recursive=TRUE)   
  fileOutput<-getFileName(destFolder,"/mergedDS.txt")
  if (file.exists(fileOutput))
    file.remove(fileOutput)
  file.create(fileOutput)
  write.table(observations,fileOutput,row.names=FALSE)
  fileOutput  
}
##
##Responsible for reassigning the factors
relabelActivityNames<-function(redmgdFile,activityLabels, outputFolder)
{ 
  
  reducedDS<-read.table(redmgdFile,header=TRUE)
  reducedDS$activity<-factor(reducedDS$activity,activityLabels[,1],activityLabels[,2])
  ##Write file
  destFolder<-paste(outputFolder,"/step3",sep="")
  dir.create(destFolder,recursive=TRUE)   
  fileOutput<-getFileName(destFolder,"/mergedDSWithAct.txt")
  if (file.exists(fileOutput))
    file.remove(fileOutput)
  file.create(fileOutput)
  write.table(reducedDS,fileOutput,row.names=FALSE)
  fileOutput  

}

summByActAndSub<-function(redmgdFileActLabel, outputFolder)
{
  ##Read inputDS  
  inputDS<-read.table(redmgdFileActLabel,header=TRUE)
  
  library(plyr)
  
  summarizedDS<-ddply(inputDS,c("subject","activity"),numcolwise(mean))
  
  ##Write file
  destFolder<-paste(outputFolder,"/step4",sep="")
  dir.create(destFolder,recursive=TRUE)   
  fileOutput<-getFileName(destFolder,"/summarizedDS.txt")
  if (file.exists(fileOutput))
    file.remove(fileOutput)
  file.create(fileOutput)
  write.table(summarizedDS,fileOutput,row.names=FALSE)
  fileOutput    
 }
