# Distance based sampling for JAVA_RUN
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
ENV<-getENV("..")  # the codeBase parameter is for debug, when this script execute by RScript it will be ignored
pp <- "../../../../results/TOSEM_mix_a/UAV_50a_SAFE/Run01" # "results/TOSEM_mix/ESAIL_SAFE/Run01"
ENV$PARAMS <- c(pp, sprintf("%s/_phase2/_samples/sample_0003.md",pp), sprintf("%s/_phase2/workdata.csv",pp), 10, 20, 0.0674)
print(sprintf("WORK_PATH : %s", ENV$BASE))
print(sprintf("CODE_BASE : %s", ENV$CODE_BASE))
print(sprintf("PARAMS    : %s", ENV$PARAMS))

############################################################
# Load libraries
###########################################################
setwd(ENV$CODE_BASE)  # SET code path
source("../libs/lib_config.R")
source("../libs/lib_model.R")          # get_intercepts#
source("../libs/lib_sampling.R")       # generate_samples_by_distance
source("../libs/lib_draw.R")           # for drawing the last graph
setwd(ENV$BASE) 			# SET current local directory

############################################################
# R Parameter passing
############################################################
if (length(ENV$PARAMS)<6){
    cat("Error:: Missed required parameters: \n")
    cat("\t[1] target folder (string) \n")
    cat("\t[2] model file, relative path inside in target folder (string) \n")
    cat("\t[3] training data file, relative path inside in target folder (string) \n")
    cat("\t[4] Number of samples (integer) \n")
    cat("\t[5] Number of candidates for sampling (integer) \n")
    cat("\t[6] model probability (double) \n")
    quit(status=0)
}

BASE_PATH       <- getAbsolutePath(ENV$PARAMS[1], ENV$BASE)
modelFile       <- getAbsolutePath(ENV$PARAMS[2], ENV$BASE)
trainingFile    <- getAbsolutePath(ENV$PARAMS[3], ENV$BASE)
nSamples        <- as.integer(ENV$PARAMS[4])
nCandidates     <- as.integer(ENV$PARAMS[5])
probability     <- as.double(ENV$PARAMS[6])
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

# Load Settings
settings        <- parsingParameters(settingFile)
TIME_QUANTA     <- settings[['TIME_QUANTA']]
TASK_INFO <- load_taskInfo(taskinfoFile, TIME_QUANTA)
# training <- read.csv(trainingFile, header=TRUE)

# load model
md.csv<-read.csv(modelFile,header=FALSE, stringsAsFactors=FALSE)
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
# xRange <- find_x_range(TASK_INFO, fx, XID, training, 0.00)
samples <- generate_samples_by_distance(TASK_INFO, fx, yID, XID, nSamples, nCandidates)

print(samples)
