# This code is for feature reduction and generating logistic model
# Jaekwon LEE
options(warn=-1)
############################################################
# Load libraries
############################################################
EXEC_PATH <- '~/projects/RTA_SAFE'
CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)
args <- c("results/TOSEM3/CCS")

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
suppressMessages(library(MASS))    # stepAIC
suppressMessages(library(dplyr))   # ??
suppressMessages(library(randomForest))
suppressMessages(library(ggplot2))
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
# intercept test
uncertainIDs <- get_base_names(names(md$coefficients), isNum=TRUE)
draw_model(training, md, TASK_INFO, uncertainIDs, NULL)

# get threshold
threshold <- find_noFPR(md, training, precise=0.0001)  # lowest probability
intercepts <- get_intercepts(md, threshold, uncertainIDs, TASK_INFO)
as.double(intercepts[1,])==Inf
if (as.double(intercepts[1,])==Inf){
  cat("Not applicable Phase 2 ")
}

threshold <- find_noFNR(md, training, precise=0.0001)  # highest probability
intercepts <- get_intercepts(md, threshold, uncertainIDs, TASK_INFO)
if (as.double(intercepts[1,])==Inf){
  cat("Not applicable Phase 2 ")
}
