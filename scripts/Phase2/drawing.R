# This code is for feature reduction and generating logistic model
# Jaekwon LEE
options(warn=-1)
############################################################
# Load libraries
############################################################
#EXEC_PATH <- getwd()
#CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)
EXEC_PATH <- '~/projects/RTA_SAFE'
CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)
args <- c("", "", "", "", "", "results/TOSEM2/ICS")

setwd(CODE_PATH)
source("libs/lib_config.R")
source("libs/lib_data.R")
source("libs/lib_features.R")
source("libs/lib_draw.R")
library(MASS)    # stepAIC
library(dplyr)   # ??
library(randomForest)
library(ggplot2)
setwd(CODE_PATH)

############################################################
# R Parameter passing
############################################################
#args <- commandArgs()
args <- args[-(1:5)]  # get sublist from arguments (remove unnecessary arguments)
if (length(args)<1){
    cat("Error:: Required parameters: target folder\n\n")
    quit(status=0)
}
BASE_PATH <- sprintf("%s/%s", EXEC_PATH, args[1])
phase1DirName <- ifelse(length(args)>=2, args[2], "_results")
outputDirName <- ifelse(length(args)>=3, args[3], "_sampleView")


cat("============== Environment ===================\n")
cat(sprintf("EXEC_PATH  : %s\n", EXEC_PATH))
cat(sprintf("CODE_PATH  : %s\n", CODE_PATH))
cat(sprintf("BASE_PATH  : %s\n", BASE_PATH))

############################################################
# SAFE Parameter parsing and setting 
############################################################
settingFile   <- sprintf("%s/settings.txt", BASE_PATH)
taskinfoFile  <- sprintf("%s/input.csv", BASE_PATH)
dataFile      <- sprintf('%s/%s/sampledata.csv', BASE_PATH, phase1DirName)
OUTPUT_PATH   <- sprintf('%s/%s', BASE_PATH, outputDirName)
if(dir.exists(OUTPUT_PATH)==FALSE) dir.create(OUTPUT_PATH, recursive=TRUE)

settings        <- parsingParameters(settingFile)
TIME_QUANTA     <- settings[['TIME_QUANTA']]

TASK_INFO <- load_taskInfo(taskinfoFile, TIME_QUANTA)
cat(sprintf("time quanta   : %.4f\n", TIME_QUANTA))
cat(sprintf("# of Tasks    : %d\n", nrow(TASK_INFO)))

############################################################
# load traning data
############################################################
cat("==============Started===================\n")
print(dataFile)
training <- read.csv(dataFile, header=TRUE)
nMissed <- nrow(training[training$result==1,])
nPassed <- nrow(training[training$result==0,])
cat(sprintf("Loaded training data: %d samples (nPassed: %d, nMissed: %d, Ratio of Missed: %.2f%%)\n", nrow(training), nPassed, nMissed, nMissed/nrow(training)*100))


################################################################################
# printing model into file
taskIDs <- get_task_names(training, isNum=TRUE)
for (x in 1:(length(taskIDs)-1)){
    for (y in (x+1):length(taskIDs)){
        g<-get_WCETspace_plot(data=training, form=NULL, xID=taskIDs[x], yID=taskIDs[y],
                              showTraining=TRUE, showMessage=FALSE, nSamples=0, probLines=c(), showThreshold=FALSE)
        ggsave(sprintf("%s/graph_T%d_T%d.pdf", OUTPUT_PATH, taskIDs[x], taskIDs[y]), g,  width=7, height=5)
        cat(sprintf("Generated WCET space with x(T%d), y(T%d)\n", taskIDs[x], taskIDs[y]))
    }
}
cat("Done.\n")


