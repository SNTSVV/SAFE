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
#args <- c("results/TOSEM_20a/ICS/Run18", "_phase2/_samples/sample_best_size.md", 0.053600)
setwd(CODE_PATH)
suppressMessages(library(neldermead))
source("libs/lib_config.R")
source("libs/lib_area.R")          # get_bestsize_point
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
BASE_PATH       <- sprintf("%s/%s", EXEC_PATH, args[1])
modelFile       <- sprintf("%s/%s", BASE_PATH, args[2])  # "_phase2"
probability     <- as.double(args[3])

############################################################
# SAFE Parameter parsing and setting
############################################################
settingFile   <- sprintf("%s/settings.txt", BASE_PATH)
taskinfoFile  <- sprintf("%s/input_reduced.csv", BASE_PATH)
if (file.exists(taskinfoFile)==FALSE){
    taskinfoFile  <- sprintf("%s/input.csv", BASE_PATH)
}

settings        <- parsingParameters(settingFile)
TIME_QUANTA     <- settings[['TIME_QUANTA']]

TASK_INFO <- load_taskInfo(taskinfoFile, TIME_QUANTA)

#cat(sprintf("ModelFile: %s\n", modelFile))
#cat(sprintf("settingFile: %s\n", settingFile))
#cat(sprintf("TASK_INFO: %d\n", nrow(TASK_INFO)))



# load model
md.csv<-read.csv(modelFile,header=FALSE, stringsAsFactors=FALSE)
model.coef <- as.double(md.csv[2,])
names(model.coef) <- md.csv[1,]
model <- list(coefficients=model.coef)



# new learning (for test)
#suppressMessages(library(MASS))    # stepAIC
#cat(":: load model ... \n")
#dataFile<- sprintf("%s/_results/sampledata.csv", BASE_PATH)
#training <- read.csv(dataFile, header= TRUE)
##md <- glm(formula = model.formula, family = "binomial", data = training)
#
#model.formula <- "result ~ T2 + T3 + I(T2^2) + I(T3^2) + T2:T3"
## model.formula <- "result ~ T2 + T3 + T4 + I(T2^2) + I(T3^2) + I(T4^2) + T2:T3 + T2:T4 + T3:T4"
#model <- glm(formula = model.formula, family = "binomial", data = training)
#model <- stepAIC(model, direction = 'both', trace=0) # trace=0, stop to print processing
#model$coefficients
## Get formula
#cl<- as.character(model$formula)
#formula_str <- sprintf("%s %s %s", cl[2], cl[1], cl[3])
#cat(sprintf("\t Reduced formula: %s\n",formula_str))



# execute sampling
targetIDs <- get_base_names(names(model$coefficients), isNum=TRUE)
if (length(targetIDs)>=2){
    yID <- targetIDs[length(targetIDs)]
    XID <- targetIDs[1:(length(targetIDs)-1)]
}else{
    yID <- targetIDs[length(targetIDs)]
    XID <- c()
}

bestPoint <- list(X=NULL, Y=NULL, Area=NULL)

tryCatch({
    bestPoint <- get_bestsize_point(TASK_INFO, model, probability, targetIDs)
}, error = function(e) {
    message(e)
})
sink()
close(f)

if (is.null(bestPoint$X)==TRUE){
    cat('\nERROR:: Error to calculate bestsize point\n')
    cat("X: NULL, Y: NULL, Area: NULL")
}else{
    # write results
    cat(sprintf("X: %f, Y: %f, Area: %f", bestPoint$X, bestPoint$Y, bestPoint$Area))
}