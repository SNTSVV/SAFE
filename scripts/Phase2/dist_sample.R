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
source("libs/lib_sampling.R")       # for drawing the last graph
setwd(CODE_PATH)

############################################################
# R Parameter passing
############################################################
args <- commandArgs()
args <- args[-(1:5)]  # get sublist from arguments (remove unnecessary arguments)
#args <- c("results/TOSEM3/ICS", "_phase2", 10, 20, 0.0036)
if (length(args)<1){
    cat("Error:: Required parameters: target folder\n\n")
    quit(status=0)
}
BASE_PATH       <- sprintf("%s/%s", EXEC_PATH, args[1])
phase2DirName   <- args[2]  # "_phase2"
nSamples        <- as.integer(args[3])
nCandidates     <- as.integer(args[4])
probability     <- as.double(args[5])

############################################################
# SAFE Parameter parsing and setting
############################################################
settingFile   <- sprintf("%s/settings.txt", BASE_PATH)
taskinfoFile  <- sprintf("%s/input.csv", BASE_PATH)
modelFile   <- sprintf("%s/%s/samples.md", BASE_PATH, phase2DirName)
sampleFile   <- sprintf("%s/%s/samples.data", BASE_PATH,phase2DirName)

settings        <- parsingParameters(settingFile)
TIME_QUANTA     <- settings[['TIME_QUANTA']]

TASK_INFO <- load_taskInfo(taskinfoFile, TIME_QUANTA)

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

sink()
close(f)

# save model
#write.table(t(as.data.frame(md$coefficients)), file="my_model1.rda",
#            append=FALSE, sep=",", dec=".", row.names = FALSE, col.names = TRUE)
