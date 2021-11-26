# Calculating best-size point for JAVA_RUN
options(warn=-1)
f <- file()  # annonymous file
sink(f)
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
#ENV$PARAMS<- c("results/test", "results/test/_phase2/_samples/sample_best_size_006.md", "results/test/_phase2/workdata.csv", 0.0597)

print(sprintf("WORK_PATH : %s", ENV$BASE))
print(sprintf("CODE_BASE : %s", ENV$CODE_BASE))
print(sprintf("PARAMS    : %s", ENV$PARAMS))

############################################################
# Load libraries
###########################################################
setwd(ENV$CODE_BASE)  # SET code path
suppressMessages(library(stringr))
source("libs/lib_config.R")
source("libs/lib_sampling.R")	# find_x_range
source("libs/lib_model.R")		# generate_line_function
source("libs/lib_area.R")		# get_bestsize_point
setwd(ENV$BASE) 			# SET current local directory

############################################################
# Code Starts
############################################################
# Execution parameters
if (length(ENV$PARAMS)<4){
    cat("Error:: Missed required parameters: \n")
    cat("\t[1] target folder (string) \n")
    cat("\t[2] model file, relative path inside in target folder (string) \n")
    cat("\t[3] training data file, relative path inside in target folder (string) \n")
    cat("\t[4] model probability (double) \n")
    quit(status=0)
}

BASE_PATH     <- getAbsolutePath(ENV$PARAMS[1], ENV$BASE)
modelFile     <- getAbsolutePath(ENV$PARAMS[2], ENV$BASE)
trainingFile  <- getAbsolutePath(ENV$PARAMS[3], ENV$BASE)
probability   <- as.double(ENV$PARAMS[4])
settingFile   <- sprintf("%s/settings.txt", BASE_PATH)
taskinfoFile  <- sprintf("%s/input_reduced.csv", BASE_PATH)
if (file.exists(taskinfoFile)==FALSE){
    taskinfoFile  <- sprintf("%s/input.csv", BASE_PATH)
}

cat(sprintf("BASE_PATH    : %s\n", BASE_PATH))
cat(sprintf("ModelFile    : %s\n", modelFile))
cat(sprintf("TrainingFile : %s\n", trainingFile))
cat(sprintf("Probability  : %f\n", probability))
cat(sprintf("Setting File : %s\n", settingFile))
cat(sprintf("Task File    : %s\n", taskinfoFile))

############################################################
# SAFE Parameter parsing and setting
############################################################
settings     <- parsingParameters(settingFile)
TIME_QUANTA  <- settings[['TIME_QUANTA']]
TASK_INFO    <- load_taskInfo(taskinfoFile, TIME_QUANTA)
# training     <- read.csv(trainingFile, header=TRUE)
cat(sprintf("TASK_INFO    : %d\n", nrow(TASK_INFO)))

# load model ----------------------------
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
    # xRange<- xRange <- find_x_range(TASK_INFO, fx, XID, training, 0.00)
    bestPoint <- get_bestsize_point_multi(fx, TASK_INFO, XID, yID, try=10)
}else{
    yID <- targetIDs[length(targetIDs)]
    XID <- c()

    fx<-generate_line_function(model, probability, yID, TASK_INFO$WCET.MIN[yID], TASK_INFO$WCET.MAX[yID])
    bestPoint <- get_bestsize_point_singleD(fx, TASK_INFO, XID, yID)
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