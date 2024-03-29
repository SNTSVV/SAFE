# Distance based sampling for JAVA_RUN
options(warn=-1)
############################################################
# Load libraries
############################################################
EXEC_PATH <- "~/projects/RTA_SAFE/StressTesting"
CODE_PATH <- sprintf("%s/scripts/R", EXEC_PATH)
args <- c("../results/TestQ/ICS_20a_SAFE/Run01", "_random/_samples/sample_0018.md", "_random/workdata.csv", 10, 20, 0.039200)
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
if (length(args)<1){
    cat("Error:: Required parameters: target folder\n\n")
    quit(status=0)
}
BASE_PATH       <- sprintf("%s/%s", EXEC_PATH, args[1])
modelFile       <- sprintf("%s/%s", BASE_PATH, args[2])
trainingFile    <- sprintf("%s/%s", BASE_PATH, args[3])
nSamples        <- as.integer(args[4])
nCandidates     <- as.integer(args[5])
probability     <- as.double(args[6])
PRINT_SAMPLE    <- TRUE

############################################################
# SAFE Parameter parsing and setting
############################################################
settingFile   <- sprintf("%s/settings.txt", BASE_PATH)
taskinfoFile  <- sprintf("%s/input_reduced.csv", BASE_PATH)
if (file.exists(taskinfoFile)==FALSE){
    taskinfoFile  <- sprintf("%s/input.csv", BASE_PATH)
}
sampleFile   <- sprintf("%s.data", modelFile)
sampleGraph  <- sprintf("%s.pdf", modelFile)

cat(sprintf("trainingFile: %s\n", trainingFile))
cat(sprintf("modelFile: %s\n", modelFile))
cat(sprintf("sampleFile: %s\n", sampleFile))
cat(sprintf("sampleGraph: %s\n", sampleGraph))


settings        <- parsingParameters(settingFile)
TIME_QUANTA     <- settings[['TIME_QUANTA']]

TASK_INFO <- load_taskInfo(taskinfoFile, TIME_QUANTA)
samples <- sample_by_random(20, TASK_INFO)
samples[1,]

training <- read.csv(trainingFile, header=TRUE)


# load model
md.csv<-read.csv(modelFile,header=FALSE, stringsAsFactors=FALSE)
model.coef <- as.double(md.csv[2,])
names(model.coef) <- md.csv[1,]
model <- list(coefficients=model.coef)
model

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
