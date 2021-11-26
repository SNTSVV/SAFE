# pruning of input.csv from the phase1 result
# if there are imbalanced data, it generates input_reduced.csv
# if there are imbalanced data, it generates sampledata_reduced.csv
# This file works for only one run of phase1
options(warn=-1)
############################################################
# Load libraries
############################################################
EXEC_PATH <- "~/projects/RTA_SAFE"
CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)
args <- c("results/TOSEM_30a/ESAIL/Run01")

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


targetIDs <- get_base_names(names(base_model$coefficients), isNum=TRUE)

################################################################################
# pruning
if(balanceSide=="negative" && balanceRate<0.50){
    cat(":: Pruning... ")
    taskInfo <- data.frame(TASK_INFO)
    intercepts <- get_intercepts(base_model, balanceProb, targetIDs, taskInfo)
    #intercepts <- complement_intercepts(intercepts, targetIDs, taskInfo)
    intercepts
    #
    #yID <- 30
    #XID <- 33
    #fx <- generate_line_function(base_model, balanceProb, yID, taskInfo$WCET.MIN[yID], taskInfo$WCET.MAX[yID])
    #intercept <- fx(taskInfo$WCET.MIN[XID])
    #taskInfo$WCET.MIN[XID]
    #intercepts
    #
    #intercept <- intercept[intercept <= taskInfo$WCET.MAX[yID]]
    #intercept <- intercept[intercept >= taskInfo$WCET.MIN[yID]]
    #intercept <- min(intercept)
    #intercept
    #source("libs/lib_draw.R")
    #uData <- update_data(training, labels=c("No deadline miss", "Deadline miss"))
    #
    #g<-generate_WCET_scatter(uData, TASK_INFO, XID, yID, labelCol = "labels", legendLoc="rt",
    #                         model.func=fx, probability = balanceProb,
    #                         labelColor=c("#3ECCFF", "#F2A082"), labelShape=c(1, 25))
    #print(g)


    #print(intercepts)
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
draw_model(training, base_model, TASK_INFO, targetIDs, modelAfterFile)

cat("\nDone.\n")
df1 <- data.frame(dm)
df1

dm <- data.frame(update = 1, as.data.frame(t(base_model$coefficients)))
nameList <- colnames(dm)
nameList
dm <- format(dm, digits=20, scientific = TRUE)
dm

for( idx in 1:length(nameList)){
    dm[[ nameList[idx] ]] <- format(dm[[ nameList[idx] ]], digits=20, scientific = TRUE)
}
dm

df1
write.csv(dm, sprintf("%s/test.csv", BASE_PATH), quote=FALSE)
as.double(dm[1,])
typeof(dm[[1]])
typeof(dm[[2]])
typeof(dm[[4]])
typeof(dm[[3]])