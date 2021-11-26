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
ENV<-getENV("StressTesting/scripts/R")  # the codeBase parameter is for debug, when this script execute by RScript it will be ignored
ENV$PARAMS <- c("results/TOSEM_mix/ICS_20a_SAFE/Run24", "_random", 0.041300)
print(sprintf("WORK_PATH : %s", ENV$BASE))
print(sprintf("CODE_BASE : %s", ENV$CODE_BASE))
print(sprintf("PARAMS    : %s", ENV$PARAMS))

############################################################
# Load libraries
###########################################################
setwd(ENV$CODE_BASE)  # SET code path
suppressMessages(library(neldermead))
source("libs/lib_config.R")
source("libs/lib_model.R")          # get_intercepts#
source("libs/lib_evaluate.R")       # generate_samples_by_distance
setwd(ENV$BASE) 			# SET current local directory

############################################################
# R Parameter passing
############################################################
if (length(ENV$PARAMS)<2){
    cat("Error:: Missed required parameters: \n")
    cat("\t[1] target folder (string) \n")
    cat("\t[2] model probability (double) \n")
    quit(status=0)
}

BASE_PATH       <- getAbsolutePath(ENV$PARAMS[1], ENV$BASE)
trainingFile    <- sprintf("%s/%s/workdata.csv", BASE_PATH, ENV$PARAMS[2])
testFile        <- sprintf("%s/testdata.csv", BASE_PATH)
modelFile       <- sprintf("%s/_formula/formula", BASE_PATH)
probability     <- as.double(ENV$PARAMS[3])

############################################################
# SAFE Parameter parsing and setting
############################################################
settingFile   <- sprintf("%s/settings.txt", BASE_PATH)
taskinfoFile  <- sprintf("%s/input_reduced.csv", BASE_PATH)
if (file.exists(taskinfoFile)==FALSE){
    taskinfoFile  <- sprintf("%s/input.csv", BASE_PATH)
}

cat(sprintf("trainingFile: %s\n", trainingFile))
cat(sprintf("modelFile: %s\n", modelFile))
cat(sprintf("testFile: %s\n", testFile))


# Load Settings
settings        <- parsingParameters(settingFile)
TIME_QUANTA     <- settings[['TIME_QUANTA']]
TASK_INFO <- load_taskInfo(taskinfoFile, TIME_QUANTA)


# load data and train model
training <- read.csv(trainingFile, header=TRUE)
test.samples <- read.csv(testFile, header=TRUE)
model.formula <- toString(read.delim(modelFile, header=FALSE)[1,])
base_model <- glm(formula = model.formula, family = "binomial", data = training)

test.item <- calculate_metrics(base_model, test.samples, probability)
print(test.item)