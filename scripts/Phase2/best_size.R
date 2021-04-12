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
suppressMessages(library(stringr))
suppressMessages(library(neldermead))
source("libs/lib_config.R")
source("libs/lib_sampling.R")  # find_x_range
source("libs/lib_model.R")     # generate_line_function
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
modelFile       <- sprintf("%s/%s", BASE_PATH, args[2])
trainingFile    <- sprintf("%s/%s", BASE_PATH, args[3])
probability     <- as.double(args[4])

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
training <- read.csv(trainingFile, header=TRUE)

#cat(sprintf("ModelFile: %s\n", modelFile))
#cat(sprintf("settingFile: %s\n", settingFile))
#cat(sprintf("TASK_INFO: %d\n", nrow(TASK_INFO)))



# load model
md.csv<-read.csv(modelFile,header=FALSE, stringsAsFactors=FALSE)
model.coef <- as.double(md.csv[2,])
names(model.coef) <- md.csv[1,]
model <- list(coefficients=model.coef)


# get best size
targetIDs <- get_base_names(names(model$coefficients), isNum=TRUE)
msg <- ""
tryCatch({
if (length(targetIDs)>=2){
    yID <- targetIDs[length(targetIDs)]
    XID <- targetIDs[1:(length(targetIDs)-1)]

    fx<-generate_line_function(model, probability, yID, TASK_INFO$WCET.MIN[yID], TASK_INFO$WCET.MAX[yID])
    xRange<- xRange <- find_x_range(TASK_INFO, fx, XID, training, 0.00)
    bestPoint <- get_bestsize_point_multi(fx, xRange, TASK_INFO, XID, yID, try=10)
}else{
    yID <- targetIDs[length(targetIDs)]
    XID <- c()

    fx<-generate_line_function(model, probability, yID, TASK_INFO$WCET.MIN[yID], TASK_INFO$WCET.MAX[yID])
    value <- fx(TASK_INFO$WCET.MIN[XID])
    bestPoint <- list(X=NULL, Y=value, Area=value)
}

},error = function(e) {
    msg <- sprintf("Error to find best point")
}) #


sink()
close(f)

if (is.null(bestPoint$Area)==TRUE){
    cat(sprintf('\nERROR:: Not found the bestsize point',msg))
    values<-rep(NaN,length(targetIDs))
    values <- paste(values, collapse = ', ')
    cat(sprintf("\nArea: NaN; point: %s", values))
}else{
    # write results
    values <- paste(c(bestPoint$X,bestPoint$Y), collapse = ', ')
    cat(sprintf("\nArea: %f; point: %s", bestPoint$Area, values))
}