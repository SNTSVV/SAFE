# Distance based sampling for JAVA_RUN
options(warn=-1)
f <- file()  # annonymous file
sink(f)
############################################################
# Load libraries
############################################################
EXEC_PATH <- getwd()
CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)
#EXEC_PATH <- "~/projects/RTA_SAFE"
#CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)

setwd(CODE_PATH)
suppressMessages(library(neldermead))
source("libs/lib_config.R")
source("libs/lib_model.R")          # get_intercepts#
source("libs/lib_sampling.R")       # generate_samples_by_distance
source("libs/lib_draw.R")           # for drawing the last graph
setwd(CODE_PATH)

############################################################
# R Parameter passing
############################################################
args <- commandArgs()
args <- args[-(1:5)]  # get sublist from arguments (remove unnecessary arguments)
#args <- c("results/TOSEM_80a/CCS/Run01", "_phase2", 10, 20, 0.0023)
if (length(args)<1){
    cat("Error:: Required parameters: target folder\n\n")
    quit(status=0)
}
BASE_PATH       <- sprintf("%s/%s", EXEC_PATH, args[1])
phase2DirName   <- args[2]  # "_phase2"
nSamples        <- as.integer(args[3])
nCandidates     <- as.integer(args[4])
probability     <- as.double(args[5])
workID          <- args[6]
PRINT_SAMPLE    <- FALSE

############################################################
# SAFE Parameter parsing and setting
############################################################
settingFile   <- sprintf("%s/settings.txt", BASE_PATH)
taskinfoFile  <- sprintf("%s/input_reduced.csv", BASE_PATH)
if (file.exists(taskinfoFile)==FALSE){
    taskinfoFile  <- sprintf("%s/input.csv", BASE_PATH)
}
trainingFile   <- sprintf("%s/%s/workdata.csv", BASE_PATH,phase2DirName)
modelFile   <- sprintf("%s/%s/_samples/sample_%s.md", BASE_PATH, phase2DirName, workID)
sampleFile   <- sprintf("%s/%s/_samples/sample_%s.data", BASE_PATH, phase2DirName, workID)
sampleGraph  <- sprintf("%s/%s/_samples/sample_%s.pdf", BASE_PATH, phase2DirName, workID)

#cat(sprintf("trainingFile: %s\n", trainingFile))
#cat(sprintf("modelFile: %s\n", modelFile))
#cat(sprintf("sampleFile: %s\n", sampleFile))
#cat(sprintf("sampleGraph: %s\n", sampleGraph))


settings        <- parsingParameters(settingFile)
TIME_QUANTA     <- settings[['TIME_QUANTA']]

TASK_INFO <- load_taskInfo(taskinfoFile, TIME_QUANTA)
training <- read.csv(trainingFile, header=TRUE)


# load model
md.csv<-read.csv(modelFile,header=FALSE)
model.coef <- as.double(md.csv[2,])
names(model.coef) <- md.csv[1,]
model <- list(coefficients=model.coef)

# execute sampling
targetIDs <- get_base_names(names(model$coefficients), isNum=TRUE)
if (length(targetIDs)>=2){
    yID <- targetIDs[length(targetIDs)]
    XID <- targetIDs[1:(length(targetIDs)-1)]
}else{
    yID <- targetIDs[length(targetIDs)]
    XID <- c()
}

fx<-generate_line_function(model, probability, yID, TASK_INFO$WCET.MIN[yID], TASK_INFO$WCET.MAX[yID])
xRange <- find_x_range(TASK_INFO, fx, XID, training, 0.00)
samples <- generate_samples_by_distance(TASK_INFO, fx, yID, XID, xRange, nSamples, nCandidates)

# write results
write.table(samples, file=sampleFile,
            append=FALSE, sep=",", dec=".", row.names = FALSE, col.names = TRUE)

################################################################################
# printing model into file
if (PRINT_SAMPLE==TRUE){
    if ((length(targetIDs)==2 || length(targetIDs)==1)){
        if (length(XID)==0){
            allIDs <- get_task_names(samples, isNum=TRUE)
            allIDs <- allIDs[-yID]
            XID <- allIDs[1]
        }
        g <- generate_WCET_scatter(samples, TASK_INFO, XID, yID, model.func=fx, probability=probability)
        ggsave(sampleGraph, g,  width=7, height=5)
    }
}
sink()
close(f)

# save model
#write.table(t(as.data.frame(md$coefficients)), file="my_model1.rda",
#            append=FALSE, sep=",", dec=".", row.names = FALSE, col.names = TRUE)
