# pruning of input.csv from the phase1 result
# if there are imbalanced data, it generates input_reduced.csv and sampledata_reduced.csv
# This file works for only one run of phase1
options(warn=-1)

############################################################
# get script environement
############################################################
getENV<-function(codeBase=NULL){
    # collect working environment information
    # - codeBase: only works when it is executed by IDE
    env<-list()
    args <- commandArgs(trailingOnly = FALSE)
    env$BASE <- getwd()
    fname <- args[startsWith(args,"--file=" )==TRUE]
    if (length(fname)!=0){
        fname <- substring(fname, 8)
        if (!startsWith(fname, "/") && !startsWith(fname, "~")){
            fname <- sprintf("%s/%s", env$BASE, fname)
        }
        env$FILE <- basename(fname)
        env$CODE_BASE <- dirname(fname)
        env$PARAMS <- commandArgs(trailingOnly = TRUE)
    }else{
        env$FILE <- ""
        env$CODE_BASE <- sprintf("%s/%s",getwd(), codeBase)
        env$PARAMS <- c()
    }
    return (env)
}
ENV<-getENV("SAFE/scripts/R")  # the codeBase parameter is for debug, it will be ignored when this script is executed by RScript
#ENV$PARAMS <- c("results/test")
print(sprintf("WORK_PATH : %s", ENV$BASE))
print(sprintf("CODE_BASE : %s", ENV$CODE_BASE))
print(sprintf("PARAMS    : %s", ENV$PARAMS))


############################################################
# Load libraries
###########################################################
setwd(ENV$CODE_BASE)  # SET code path
suppressMessages(library(dplyr) )  # ??
suppressMessages(library(ggplot2))
source("libs/lib_config.R")
source("libs/lib_data.R")
source("libs/lib_features.R")
source("libs/lib_draw.R")
setwd(ENV$BASE) 			# SET current local directory

############################################################
# R Parameter passing
############################################################
if (length(ENV$PARAMS)<1){
    cat("Error:: Missed required parameters: \n")
    cat("\t[1] target folder (string) \n")
    cat("\tOptional parameters:")
    cat("\t[2] phase1 results path (string) \n")
    cat("\t[3] output path, default (string) \n")
    quit(status=0)
}
BASE_PATH <- getAbsolutePath(ENV$PARAMS[1], ENV$BASE)
DATA_PATH <- getAbsolutePath(ENV$PARAMS[2], ENV$BASE)
OUTPUT_PATH <- getAbsolutePath(ENV$PARAMS[3], ENV$BASE)
if(dir.exists(OUTPUT_PATH)==FALSE) dir.create(OUTPUT_PATH, recursive=TRUE)

############################################################
# SAFE Parameter parsing and setting 
############################################################
settingFile   <- sprintf("%s/settings.txt", BASE_PATH)
taskinfoFile  <- sprintf("%s/input.csv", BASE_PATH)
dataFile      <- sprintf('%s/sampledata.csv', DATA_PATH)


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
training <- update_data(training, c("No deadline miss", "Deadline miss"))
for (x in 1:(length(taskIDs)-1)){
    for (y in (x+1):length(taskIDs)){
        #g <- generate_WCET_scatter(training, TASK_INFO, taskIDs[x], taskIDs[y], labelCol="labels")
        g<-generate_WCET_scatter(training, TASK_INFO, taskIDs[x], taskIDs[y],
                                 labelCol = "labels", legendLoc="rt",
                                 labelColor=c("#00BFC4", "#F8766D"), labelShape=c(1, 25))

        ggsave(sprintf("%s/graph_T%d_T%d.pdf", OUTPUT_PATH, taskIDs[x], taskIDs[y]), g,  width=7, height=5)
        cat(sprintf("Generated WCET space with x(T%d), y(T%d)\n", taskIDs[x], taskIDs[y]))
    }
}
cat("Done.\n")


