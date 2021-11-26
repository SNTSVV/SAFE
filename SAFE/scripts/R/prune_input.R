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
#ENV$PARAMS  <- c("results/test", "results/test/_results", "results/test/_formula")
print(sprintf("WORK_PATH : %s", ENV$BASE))
print(sprintf("CODE_BASE : %s", ENV$CODE_BASE))
print(sprintf("PARAMS    : %s", ENV$PARAMS))

############################################################
# Load libraries
###########################################################
setwd(ENV$CODE_BASE)  # SET code path
suppressMessages(library(MASS))
suppressMessages(library(dplyr))
suppressMessages(library(MLmetrics))
source("libs/lib_config.R")
source("libs/lib_data.R")       # get_task_names
source("libs/lib_model.R")      # get_intercepts#
source("libs/lib_pruning.R")    # pruning
source("libs/lib_formula.R")    # get_raw_names, get_base_name does not need lib_data.R
source("libs/lib_metrics.R")    # find_noFPR, FPRate
source("libs/lib_evaluate.R")   # find_noFPR
source("libs/lib_draw.R")       # for drawing the last graph
setwd(ENV$BASE) 			# SET current local directory

############################################################
# R Parameter passing
############################################################
if (length(ENV$PARAMS)<1){
    cat("Error:: Missed required parameters: \n")
    cat("\t[1] target folder (string) \n")
    cat("\tOptional parameters:")
    cat("\t[2] phase1 results path, default: _results, relative path inside in target folder (string) \n")
    cat("\t[3] formula path, default: _formula, relative path inside in target folder (string) \n")
    quit(status=0)
}
BASE_PATH <- getAbsolutePath(ENV$PARAMS[1], ENV$BASE)  # for loading settings
DATA_PATH <- getAbsolutePath(ENV$PARAMS[2], ENV$BASE)
FORMULA_PATH <- getAbsolutePath(ENV$PARAMS[3], ENV$BASE)


if(dir.exists(FORMULA_PATH)==FALSE){
    print("You should create formula first!!")
    quit(status=0)
}
cat(sprintf("BASE_PATH     : %s\n", BASE_PATH))
cat(sprintf("DATA_PATH     : %s\n", DATA_PATH))
cat(sprintf("FORMULA_PATH  : %s\n", FORMULA_PATH))


############################################################
# SAFE Parameter parsing and setting 
############################################################
settingFile     <- sprintf("%s/settings.txt", BASE_PATH)
taskinfoFile    <- sprintf("%s/input.csv", BASE_PATH)
newTaskFile     <- sprintf("%s/input_reduced.csv", BASE_PATH)

dataFile        <- sprintf('%s/sampledata.csv', DATA_PATH)
newTrainingFile <- sprintf('%s/sampledata_reduced.csv', DATA_PATH)

formulaFile     <- sprintf('%s/formula', FORMULA_PATH)
modelAfterFile  <- sprintf('%s/model_graph_after.pdf', FORMULA_PATH)

params                  <- parsingParameters(settingFile)
nSamples                <- params[["N_SAMPLE_WCET"]]
populationSize          <- params[['GA_POPULATION']]
iterations.P1           <- params[['GA_ITERATION']]
TIME_QUANTA             <- params[['TIME_QUANTA']]
MODEL_PROB_PRECISION    <- params[['MODEL_PROB_PRECISION']]

TASK_INFO<-load_taskInfo(taskinfoFile, TIME_QUANTA)
cat(sprintf("nSamples      : %d\n", nSamples))
cat(sprintf("populationSize: %d\n", populationSize))
cat(sprintf("iterations.P1 : %d\n", iterations.P1))
cat(sprintf("time quanta   : %.4f\n", TIME_QUANTA))
cat(sprintf("# of Tasks    : %d\n", nrow(TASK_INFO)))


################################################################################
# load data and train model
cat(":: load model ... \n")
model.formula <- toString(read.delim(formulaFile, header=FALSE)[1,])
training <- read.csv(dataFile, header= TRUE)
base_model <- glm(formula = model.formula, family = "binomial", data = training)
#base_model$coefficients

################################################################################
# calculating balance level
cat(":: calculating balance level ... \n")
positive <- nrow(training[training$result==0,])
negative <- nrow(training[training$result==1,])
if (positive > negative){
    balanceRate <- negative/positive
    balanceSide <- "positive"
    balanceProb <- find_noFPR(base_model, training, precise=MODEL_PROB_PRECISION)
}else{
    balanceRate <- positive/negative
    balanceSide <- "negative"
    balanceProb <- find_noFNR(base_model, training, precise=MODEL_PROB_PRECISION)
    # if (balanceProb<0.999) balanceProb<-0.999
}

cat(sprintf(":: Number of training data: %d (nPositive: %d, nNegative: %d)\n", nrow(training), positive, negative))
cat(sprintf(":: BalanceRate: %.2f, BalanceSide: %s, balanceProb: %.4f \n", balanceRate, balanceSide, balanceProb))


targetIDs <- get_base_names(names(base_model$coefficients), isNum=TRUE)

################################################################################
# pruning
if(balanceSide=="negative" && balanceRate<0.50){
    cat(":: Pruning... ")
    taskInfo <- data.frame(TASK_INFO)
    intercepts <- get_intercepts(base_model, balanceProb, targetIDs, taskInfo)
    #intercepts <- complement_intercepts(intercepts, targetIDs, taskInfo)
    training <- pruning(training, balanceSide, intercepts, targetIDs)

    # change input data
    for (tID in targetIDs){
        tname <- sprintf("T%d", tID)
        taskInfo$WCET.MAX[[tID]] <- intercepts[1, tname]
        # print(sprintf("T%d=%d", tID, TASK_INFO$WCET.MAX[[tID]]))
    }

    ################################################################################
    # Save the new tasks
    copy <- data.frame(taskInfo)
    copy$OFFSET  <- copy$OFFSET*TIME_QUANTA
    copy$WCET.MIN <- copy$WCET.MIN*TIME_QUANTA
    copy$WCET.MAX <- copy$WCET.MAX*TIME_QUANTA
    copy$PERIOD   <- copy$PERIOD*TIME_QUANTA
    copy$INTER.MIN <- copy$INTER.MIN*TIME_QUANTA
    copy$INTER.MAX <- copy$INTER.MAX*TIME_QUANTA
    copy$DEADLINE  <- copy$DEADLINE*TIME_QUANTA
    write.table(copy, newTaskFile, append = FALSE, sep = ",", dec = ".", row.names = FALSE, col.names = TRUE)

    # Save traning data
    write.table(training, newTrainingFile, append = FALSE, sep = ",", dec = ".", row.names = FALSE, col.names = TRUE)

}else{
    cat(":: Pruning doesn't need.\n")
}

################################################################################
# printing model into file
draw_model(training, base_model, TASK_INFO, targetIDs, modelAfterFile)

cat("\nDone.\n")


