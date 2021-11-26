# Calculating best-size point for JAVA_RUN
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
pp <- "../../../../results/TOSEM_mix/ESAIL_SAFE/Run01"
ENV$PARAMS<- c(pp, sprintf("%s/_phase2/_samples/sample_best_size_000.md", pp), sprintf("%s/_phase2/workdata.csv", pp), 0.0674)

print(sprintf("WORK_PATH : %s", ENV$BASE))
print(sprintf("CODE_BASE : %s", ENV$CODE_BASE))
print(sprintf("PARAMS    : %s", ENV$PARAMS))

############################################################
# Load libraries
###########################################################
setwd(ENV$CODE_BASE)  # SET code path
suppressMessages(library(stringr))
suppressMessages(library(pracma))
source("../libs/lib_config.R")
source("../libs/lib_sampling.R")	# find_x_range
source("../libs/lib_model.R")		# generate_line_function
source("../libs/lib_area.R")		# get_bestsize_point
source("../libs/lib_draw.R")           # for drawing the last graph  # test
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
training     <- read.csv(trainingFile, header=TRUE)
cat(sprintf("TASK_INFO    : %d\n", nrow(TASK_INFO)))

# load model ----------------------------
md.csv<-read.csv(modelFile,header=FALSE, stringsAsFactors=FALSE)
model.coef <- as.double(md.csv[2,])
names(model.coef) <- md.csv[1,]
model <- list(coefficients=model.coef)
print(model)

# get best size
targetIDs <- get_base_names(names(model$coefficients), isNum=TRUE)
msg <- ""
tryCatch({
if (length(targetIDs)>=2){
    yID <- targetIDs[length(targetIDs)]
    XID <- targetIDs[1:(length(targetIDs)-1)]
    
    fx<-generate_line_function(model, probability, yID, TASK_INFO$WCET.MIN[yID], TASK_INFO$WCET.MAX[yID])
    # xRange<- xRange <- find_x_range(TASK_INFO, fx, XID, training, 0.00)
    TASK_INFO$WCET.MIN[XID]
    bestPoint <- get_bestsize_point_multi(fx, xRange, TASK_INFO, XID, yID, try=10)
}else{
    yID <- targetIDs[length(targetIDs)]
    XID <- c()

    fx<-generate_line_function(model, probability, yID, TASK_INFO$WCET.MIN[yID], TASK_INFO$WCET.MAX[yID])
    bestPoint <- get_bestsize_point_singleD(fx, TASK_INFO, XID, yID)
}

},error = function(e) {
    msg <- sprintf("Error to find best point")
}) #


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

########################################################################
# Plotting the results
########################################################################

library(ggplot2)
{
    dt<-data.frame(T30=bestPoint$X, T33=bestPoint$Y, type=2)

    g <- generate_WCET_scatter(training, TASK_INFO, XID, yID, model.func=fx, probability=probability)
    print(g)
}


########################################################################
# nelder-mead algorithm comparision
#    - renjin has nloptr library in mvn repository
########################################################################
library(ggplot2)
library(nloptr)
{
    target<- data.frame(x=100, y=150, type=2)
    
    fx <- function(x){ return (-0.005*x^2+120) }
    dist_func <- function(x){
        vy<-abs(fx(x)-target$y)
        vx<-abs(x-target$x)
        return (sqrt(vy^2+vx^2))
    }
    
    
    nm <- neldermead(x0=0, fn=dist_func)
    #, lower=, uppper=XRange$max)
    minP <- data.frame(x=nm$par, y=fx(nm$par), type=1)
    print(sprintf("min: (%.2f, %.2f), dist: %.2f ::: iter: %d", nm$par, fx(nm$par), nm$value, nm$iter))
    
    dt<- rbind(target, minP)
    
    ggplot()+
        geom_function(fun=fx, color="blue")+
        geom_point(data=dt, aes(x=x, y=y, color=type, shape=as.factor(type)), size=5)+
        xlim(0, 200)+ylim(0, 200)+
        theme_bw()
    
}

library(optimization)
{
    target<- data.frame(x=50, y=50, type=2)
    
    fx <- function(x){ return (-0.005*x^2+120) }
    dist_func <- function(x){
        vy<-abs(fx(x)-target$y)
        vx<-abs(x-target$x)
        return (sqrt(vy^2+vx^2))
    }
    
    
    nm <- optim_nm(fun=dist_func, k=1, start=0)
    minP <- data.frame(x=nm$par, y=fx(nm$par), type=1)
    print(sprintf("min: (%.2f, %.2f), dist: %.2f ::: iter: %d", nm$par, fx(nm$par), nm$function_value, nm$control$iterations))
    
    dt<- rbind(target, minP)
    
    ggplot()+
        geom_function(fun=fx, color="blue")+
        geom_point(data=dt, aes(x=x, y=y, color=type, shape=as.factor(type)), size=5)+
        xlim(0, 200)+ylim(0, 200)+
        theme_bw()
    
}

# multi-dimension requires ( over 3)
library(pracma)