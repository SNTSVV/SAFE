# pruning of input.csv from the phase1 result
# if there are imbalanced data, it generates input_reduced.csv
# if there are imbalanced data, it generates sampledata_reduced.csv
# This file works for only one run of phase1
options(warn=-1)
############################################################
# Load libraries
############################################################
EXEC_PATH <- getwd()
CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)
#EXEC_PATH <- "~/projects/RTA_SAFE"
#CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)
#args <- c("results/TOSEM3/ICS", "_results", "_formula", "print")

setwd(CODE_PATH)
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
BASE_PATH      <- sprintf("%s/%s", EXEC_PATH, args[1])
phase1DirName  <- ifelse(length(args)>=2, args[2], "_results")
formulaDirName <- ifelse(length(args)>=3, args[3], "_formula")
FORMULA_PATH   <- sprintf("%s/%s", BASE_PATH, formulaDirName)

if(dir.exists(FORMULA_PATH)==FALSE){
    print("You should create formula first!!")
}

cat("============== Environment ===================\n")
cat(sprintf("EXEC_PATH     : %s\n", EXEC_PATH))
cat(sprintf("CODE_PATH     : %s\n", CODE_PATH))
cat(sprintf("BASE_PATH     : %s\n", BASE_PATH))
cat(sprintf("FORMULA_PATH  : %s\n", FORMULA_PATH))


############################################################
# SAFE Parameter parsing and setting 
############################################################
settingFile   <- sprintf("%s/settings.txt", BASE_PATH)
taskinfoFile  <- sprintf("%s/input.csv", BASE_PATH)
dataFile      <- sprintf('%s/%s/sampledata.csv', BASE_PATH, phase1DirName)
newTaskFile   <- sprintf("%s/input_reduced.csv", BASE_PATH)
newTrainingFile <- sprintf('%s/%s/sampledata_reduced.csv', BASE_PATH, phase1DirName)
formulaFile   <- sprintf('%s/%s/formula', BASE_PATH, formulaDirName)
modelAfterFile<- sprintf('%s/%s/model_graph_after.pdf', BASE_PATH, formulaDirName)

params<- parsingParameters(settingFile)
nSamples <- params[["N_SAMPLE_WCET"]]
populationSize <- params[['GA_POPULATION']]
iterations.P1 <- params[['GA_ITERATION']]
TIME_QUANTA <- params[['TIME_QUANTA']]
MODEL_PROB_PRECISION <- params[['MODEL_PROB_PRECISION']]

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


uncertainIDs <- get_base_names(names(base_model$coefficients), isNum=TRUE)

################################################################################
# pruning
if(balanceSide=="negative" && balanceRate<0.50){
    cat(":: Pruning... ")
    taskInfo <- data.frame(TASK_INFO)
    df<-list()
    for(tID in uncertainIDs){
        df[sprintf("T%d",tID)] <- taskInfo$WCET.MAX[[tID]]
    }

    intercepts <- as.data.frame(df)  # ??
    intercepts <- get_intercepts(base_model, balanceProb, uncertainIDs)
    intercepts <- complement_intercepts(intercepts, uncertainIDs, taskInfo)
    #print(intercepts)
    training <- pruning(training, balanceSide, intercepts, uncertainIDs)

    # change input data
    for (tID in uncertainIDs){
        tname <- sprintf("T%d", tID)
        taskInfo$WCET.MAX[[tID]] <- intercepts[1, tname]
        # print(sprintf("T%d=%d", tID, TASK_INFO$WCET.MAX[[tID]]))
    }

    ################################################################################
    # Save the new tasks
    copy <- data.frame(taskInfo)
    copy$WCET.MIN <- copy$WCET.MIN*TIME_QUANTA
    copy$WCET.MAX <- copy$WCET.MAX*TIME_QUANTA
    copy$PERIOD   <- copy$PERIOD*TIME_QUANTA
    copy$INTER.MIN <- copy$INTER.MIN*TIME_QUANTA
    copy$INTER.MAX <- copy$INTER.MAX*TIME_QUANTA
    copy$DEADLINE  <- copy$DEADLINE*TIME_QUANTA
    write.table(copy, newTaskFile, append = FALSE, sep = ",", dec = ".",row.names = FALSE, col.names = TRUE)

    # Save traning data
    write.table(training, newTrainingFile, append = FALSE, sep = ",", dec = ".",row.names = FALSE, col.names = TRUE)

}else{
    cat(":: Pruning doesn't need.\n")
}

################################################################################
# printing model into file
draw_model(training, base_model, TASK_INFO, uncertainIDs, modelAfterFile)

cat("\nDone.\n")


