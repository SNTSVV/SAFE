# This code is for feature reduction and generating logistic model
# Jaekwon LEE
options(warn=-1)
############################################################
# Load libraries
############################################################
EXEC_PATH <- getwd()
CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)
#EXEC_PATH <- '~/projects/RTA_SAFE'
#CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)
#args <- c("", "", "", "", "", "results/TOSEM2/ICS")

setwd(CODE_PATH)
source("libs/lib_config.R")
source("libs/lib_data.R")
source("libs/lib_features.R")
source("libs/lib_draw.R")
suppressMessages(library(MASS))    # stepAIC
suppressMessages(library(dplyr) )  # ??
suppressMessages(library(randomForest))
suppressMessages(library(ggplot2))
setwd(CODE_PATH)

############################################################
# R Parameter passing
############################################################
args <- commandArgs()
args <- args[-(1:5)]  # get sublist from arguments (remove unnecessary arguments)
if (length(args)<1){
    cat("Error:: Required parameters: target folder\n\n")
    quit(status=0)
}
BASE_PATH <- sprintf("%s/%s", EXEC_PATH, args[1])
phase1DirName <- ifelse(length(args)>=2, args[2], "_results")
outputDirName <- ifelse(length(args)>=3, args[3], "_sampleView")

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

cat("==============Started===================\n")
cat(sprintf("time quanta   : %.4f\n", TIME_QUANTA))
cat(sprintf("# of Tasks    : %d\n", nrow(TASK_INFO)))
cat(sprintf("Training data : %s\n",dataFile))
############################################################
# load traning data
############################################################
training <- read.csv(dataFile, header=TRUE)
nMissed <- nrow(training[training$result==1,])
nPassed <- nrow(training[training$result==0,])
cat(sprintf("Loaded training data: %d samples (nPassed: %d, nMissed: %d, Ratio of Missed: %.2f%%)\n", nrow(training), nPassed, nMissed, nMissed/nrow(training)*100))


################################################################################
# printing model into file
taskIDs <- get_task_names(training, isNum=TRUE)
for (x in 1:(length(taskIDs)-1)){
    for (y in (x+1):length(taskIDs)){
        g <- generate_WCET_scatter(training, TASK_INFO, taskIDs[x], taskIDs[y])
        ggsave(sprintf("%s/graph_T%d_T%d.pdf", OUTPUT_PATH, taskIDs[x], taskIDs[y]), g,  width=7, height=5)
        cat(sprintf("Generated WCET space with x(T%d), y(T%d)\n", taskIDs[x], taskIDs[y]))
    }
}
cat("Done.\n")


