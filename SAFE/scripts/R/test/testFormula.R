
# This code is for feature reduction and generating logistic model
# Jaekwon LEE
options(warn=-1)
############################################################
# Load libraries
############################################################
EXEC_PATH <- '~/projects/RTA_SAFE'
CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)
args <- c("results/TOSEM_mix2/ICS_20a_SAFE/Run01")

setwd(CODE_PATH)
source("libs/lib_config.R")
source("libs/lib_features.R")
source("libs/lib_data.R")       # update_data in the WCET_plot
source("libs/lib_metrics.R")    # FPRate in the find_noFPR
source("libs/lib_evaluate.R")   # find_noFPR in the WCET_plot
source("libs/lib_model.R")   # generate_line_function in WCET_plot
source("libs/lib_draw.R")
source("libs/lib_formula.R")
source("libs/lib_sampling.R")
library(MASS)    # stepAIC
library(dplyr)   # ??
library(randomForest)
library(ggplot2)
setwd(CODE_PATH)

############################################################
# R Parameter passing
############################################################
if (length(args)<1){
  cat("Error:: Required parameters: target folder\n\n")
  quit(status=0)
}
BASE_PATH <- sprintf("%s/%s", EXEC_PATH, args[1])
phase1DirName <- ifelse(length(args)>=2, args[2], "_results")
formulaDirName <- ifelse(length(args)>=3, args[3], "_formula")


OUTPUT_PATH <- sprintf("%s/%s", BASE_PATH, formulaDirName)
if(dir.exists(OUTPUT_PATH)==FALSE) dir.create(OUTPUT_PATH, recursive=TRUE)

cat("============== Environment ===================\n")
cat(sprintf("EXEC_PATH  : %s\n", EXEC_PATH))
cat(sprintf("CODE_PATH  : %s\n", CODE_PATH))
cat(sprintf("BASE_PATH  : %s\n", BASE_PATH))
cat(sprintf("OUTPUT_PATH: %s\n", OUTPUT_PATH))

############################################################
# SAFE Parameter parsing and setting
############################################################
settingFile   <- sprintf("%s/settings.txt", BASE_PATH)
taskinfoFile  <- sprintf("%s/input.csv", BASE_PATH)
formulaFile   <- sprintf('%s/%s/formula', BASE_PATH, formulaDirName)
dataFile      <- sprintf('%s/%s/sampledata.csv', BASE_PATH, phase1DirName)
modelTestFile <- sprintf('%s/%s/model_graph_test.pdf', BASE_PATH, formulaDirName)

settings        <- parsingParameters(settingFile)
nSamples        <- settings[["N_SAMPLE_WCET"]]
populationSize  <- settings[['GA_POPULATION']]
iterations.P1   <- settings[['GA_ITERATION']]
TIME_QUANTA     <- settings[['TIME_QUANTA']]

TASK_INFO <- load_taskInfo(taskinfoFile, TIME_QUANTA)
cat(sprintf("nSamples      : %d\n", nSamples))
cat(sprintf("populationSize: %d\n", populationSize))
cat(sprintf("iterations.P1 : %d\n", iterations.P1))
cat(sprintf("time quanta   : %.4f\n", TIME_QUANTA))
cat(sprintf("# of Tasks    : %d\n", nrow(TASK_INFO)))

############################################################
# load traning data
############################################################
cat("==============Started===================\n")
print(dataFile)
training <- read.csv(dataFile, header=TRUE)
nMissed <- nrow(training[training$result==1,])
nPassed <- nrow(training[training$result==0,])
cat(sprintf("Loaded training data: %d samples (nPassed: %d, nMissed: %d, Ratio of Missed: %.2f%%)\n", nrow(training), nPassed, nMissed, nMissed/nrow(training)*100))

# load formula
model.formula <- toString(read.delim(formulaFile, header=FALSE)[1,])

# learning logistic model
cat("Learning logistic regression...\n")
md <- glm(formula = model.formula, family = "binomial", data = training)

################################################################################
# showing
cat(":: Print model after...\n")
uncertainIDs <- get_base_names(names(md$coefficients), isNum=TRUE)
draw_model(training, md, TASK_INFO, uncertainIDs, NULL)



###############################################################
# multi dimensional 에서 잘 동작하는지 확인 (Test )
# check for the sample_based_euclid_distance (nelder-mead)

############################################################
# basic setting
{
  nSamples <- 10
  nCandidates <- 20
  targetIDs <- get_base_names(names(md$coefficients), isNum=TRUE)
  yID <- targetIDs[length(targetIDs)]
  XID <- targetIDs[1:(length(targetIDs)-1)]
  # Get border probability
  probPrecision <- 0.0001
  borderProbability <- find_noFPR(md, training, probPrecision)  # precision = 0.0001
  borderProbability <- ifelse(borderProbability==0, probPrecision, borderProbability)
  borderProbability
}
############################################################
# distance based sampling - by each step
{
  candidates <- sample_by_random(nCandidates, TASK_INFO)
  targetIDs <- get_base_names(names(md$coefficients), isNum=TRUE)
  selected <- ..select_based_euclid_distance(candidates, md, borderProbability, targetIDs, isGeneral=TRUE)

  # update candidates
  selectedID <- as.integer(rownames(selected))
  IDs <- as.integer(rownames(candidates))
  candidates <- data.frame(candidates, selected=ifelse(IDs==selectedID, "selcted", "none"))

  # draw
  fx<-generate_line_function(md, borderProbability, yID, TASK_INFO$WCET.MIN[yID]*UNIT, TASK_INFO$WCET.MAX[yID]*UNIT)
  print(generate_WCET_scatter(candidates, TASK_INFO, XID, yID, labelCol="selected", legendLoc="rt", model.func=fx,
                              labelColor=c("#F8766D", "#00BFC4"), labelShape=c(16, 25)))
}

# distance based sampling - by full function
{
  start <- Sys.time()
  samples<-sample_based_euclid_distance(md, 10, nCandidates, borderProbability)
  fx<-generate_line_function(md, borderProbability, yID, TASK_INFO$WCET.MIN[yID]*UNIT, TASK_INFO$WCET.MAX[yID]*UNIT)
  end <- Sys.time()
  print(generate_WCET_scatter(samples, TASK_INFO, XID, yID, model.func=fx))
  end-start
}

# 1 sampling by distance based (multi-dimension)
{
  # generate candidates and select
  fx<-generate_line_function(md, borderProbability, yID, TASK_INFO$WCET.MIN[yID]*UNIT, TASK_INFO$WCET.MAX[yID]*UNIT)
  xRange <- find_x_range(TASK_INFO, fx, XID, training, 0.0)
  candidates <- sample_by_random(nCandidates, TASK_INFO)
  selected <- ..select_based_euclid_distance_multi(candidates, fx, yID, XID, xRange)

  # update candidates
  selectedID <- as.integer(rownames(selected))
  IDs <- as.integer(rownames(candidates))
  candidates <- data.frame(candidates, selected=ifelse(IDs==selectedID, "selcted", "none"))

  # draw
  print(generate_WCET_scatter(candidates, TASK_INFO, XID, yID, labelCol="selected", legendLoc="rt", model.func=fx))
}

# N sampling by distance based - full function (multi-dimension)
{
  start<-Sys.time()
  nSamples <- 100
  fx<-generate_line_function(md, borderProbability, yID, TASK_INFO$WCET.MIN[yID]*UNIT, TASK_INFO$WCET.MAX[yID]*UNIT)
  xRange <- find_x_range(TASK_INFO, fx, XID, training, 0.00)
  samples <- generate_samples_by_distance(TASK_INFO, fx, yID, XID, xRange, nSamples, nCandidates)
  end<-Sys.time()
  print(generate_WCET_scatter(samples, TASK_INFO, XID, yID, model.func=fx))
  end-start
}


# compare previous one and new one.
{
  candidates <- sample_by_random(nCandidates, TASK_INFO)

  # Previous one
  selected <- ..select_based_euclid_distance(candidates, md, borderProbability, targetIDs, isGeneral=TRUE)
  selectedID <- as.integer(rownames(selected))

  # new one
  fx<-generate_line_function(md, borderProbability, yID, TASK_INFO$WCET.MIN[yID]*UNIT, TASK_INFO$WCET.MAX[yID]*UNIT)
  xRange <- find_x_range(TASK_INFO, fx, XID, training, 0.0)
  selected <- ..select_based_euclid_distance_multi(candidates, fx, yID, XID, xRange)
  selectedIDnew <- as.integer(rownames(selected))

  cat(sprintf("%s -- old: %d, new: %d", selectedID==selectedIDnew, selectedID, selectedIDnew))
}


#################################################################
## check 3d model
#################################################################
# add dm results training data
evaluate_training<-function(data, fx, XID, yID){
  results<-c()
  for (idx in 1:nrow(data)){
    X <-c()
    for(id in XID){
      x <- data[idx,][[sprintf("T%d",id)]]
      X <- c(X, x)
    }
    y <- fx(X)
    if (!is.infinite(y) && y < data[idx,][[sprintf("T%d",yID)]])
    {
      results<- c(results, 0)
    }else{
      results<- c(results, 1)
    }
  }
  return (data.frame(result=as.integer(results), data))
}
library(ggplot2)
source("../libs/lib_model.R")
source("../libs/lib_sampling.R")
# load model
{
  # T1 + T2 + T3 = 15
  model.coef <- c(15, -1,-1, -1)
  names(model.coef) <-c("(Intercept)", "T1", "T2", "T3")
  model <- list(coefficients=model.coef)
  XID <- c(1,2)
  yID <- 3
  nSamples<-200
  TASK_INFO <- data.frame(WCET.MIN=c(1,1,1), WCET.MAX=c(30, 60, 45))
  UNIT <- 1
}
# generate training data
{
  training<- sample_by_random(nSamples, TASK_INFO)
  fx <- generate_line_function(model, 0.001, yID, TASK_INFO$WCET.MIN[[yID]], TASK_INFO$WCET.MAX[[yID]])
  training <- evaluate_training(training, fx, XID, yID)
  training$selected <- ifelse(training$result==0, "No deadline miss", "Deadline miss")

  print(generate_WCET_scatter(training, TASK_INFO, 1, 2, labelCol="selected", legendLoc="rt"))

}
# distance based sampling
{
  nSamples <- 10
  xRange <- find_x_range(TASK_INFO, fx, XID, training, -0.5)
  samples <- generate_samples_by_distance(TASK_INFO, fx, yID, XID, xRange, nSamples, nCandidates)
  xRange
  print(generate_WCET_scatter(samples, TASK_INFO, xID=1, yID=2))
}
# 1 sampling by distance based (multi-dimension)
{
  # generate candidates and select
  # fx<-generate_line_function(md, borderProbability, yID, TASK_INFO$WCET.MIN[yID]*UNIT, TASK_INFO$WCET.MAX[yID]*UNIT)
  xRange <- find_x_range(TASK_INFO, fx, XID, training, -0.3)
  xRange
  candidates <- sample_by_random(nCandidates, TASK_INFO)
  selected <- ..select_based_euclid_distance_multi(candidates, fx, yID, XID, xRange)
  # update candidates
  selectedID <- as.integer(rownames(selected))
  IDs <- as.integer(rownames(candidates))
  candidates <- data.frame(candidates, selected=ifelse(IDs==selectedID, "selcted", "none"))

  # draw
  print(generate_WCET_scatter(candidates, TASK_INFO, 1, 2, labelCol="selected", isSelected=TRUE, legendLoc="rt", model.func = fx))
}



#################################################################
## check 1d model
#################################################################
# load model
{
  # T1 = 15  // there are 4 tasks more
  model.coef <- c(15, -1)
  names(model.coef) <-c("(Intercept)", "T1")
  model <- list(coefficients=model.coef)
  XID <- c()   # among uncertain tasks, nothing related to yID
  yID <- 1
  nSamples<-200
  nCandidates <- 20
  TASK_INFO <- data.frame(WCET.MIN=c(1,2,3,4,5), WCET.MAX=c(30,10,10,10,10))
  UNIT <- 1
  borderProbability <- 0.01
}

# N sampling by distance based - full function (multi-dimension)
{
  samples <- sample_by_random(nSamples, TASK_INFO)

  start<-Sys.time()
  nSamples <- 100
  fx<-generate_line_function(model, borderProbability, yID, TASK_INFO$WCET.MIN[yID]*UNIT, TASK_INFO$WCET.MAX[yID]*UNIT)
  xRange <- find_x_range(TASK_INFO, fx, XID, training, 0.00)
  samples <- generate_samples_by_distance(TASK_INFO, fx, yID, XID, xRange, nSamples, nCandidates)
  end<-Sys.time()
  print(generate_WCET_scatter(samples, TASK_INFO, c(2), yID, model.func = fx))
  end-start
}

#############################################
# 3D points
#############################################
#install_github("AckerDWM/gg3D")
#install.packages('devtools')
#devtools::install_github("AckerDWM/gg3D")
#library("gg3D")

## An empty plot with 3 axes
#qplot(x=0, y=0, z=0, geom="blank") +
#  theme_void() +
#  axes_3D()
