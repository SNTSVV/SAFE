# This code is for feature reduction and generating logistic model
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
ENV$PARAMS  <- c("results/test", "results/test/_results", "results/test/_formula")
print(sprintf("WORK_PATH : %s", ENV$BASE))
print(sprintf("CODE_BASE : %s", ENV$CODE_BASE))
print(sprintf("PARAMS    : %s", ENV$PARAMS))

############################################################
# Load libraries
###########################################################
setwd(ENV$CODE_BASE)  # SET code path
suppressMessages(library(MASS))    # stepAIC
suppressMessages(library(dplyr))   # ??
suppressMessages(library(randomForest))
suppressMessages(library(ggplot2))
source("libs/lib_config.R")
source("libs/lib_features.R")
source("libs/lib_formula.R")
source("libs/lib_draw.R")
setwd(ENV$BASE) 			# SET current local directory

############################################################
# R Parameter passing
############################################################
if (length(ENV$PARAMS)<1){
  cat("Error:: Missed required parameters: \n")
  cat("\t[1] target folder (string) \n")
  cat("\t[2] phase1 results path (string) \n")
  cat("\t[3] output path for formula (string) \n")
  cat("\tOptional parameters:")
  cat("\t[4] Number of terms (integer) \n")
  quit(status=0)
}

BASE_PATH <- getAbsolutePath(ENV$PARAMS[1], ENV$BASE)  # for loading settings
DATA_PATH <- getAbsolutePath(ENV$PARAMS[2], ENV$BASE)
OUTPUT_PATH <- getAbsolutePath(ENV$PARAMS[3], ENV$BASE)
termLimits <- NULL
if (length(ENV$PARAMS)>=4){
  termLimits <- as.integer(ENV$PARAMS[4])
  if (termLimits==0) termLimits <- NULL
}

if(dir.exists(OUTPUT_PATH)==FALSE) dir.create(OUTPUT_PATH, recursive=TRUE)
{
cat(sprintf("BASE_PATH   : %s\n", BASE_PATH))
cat(sprintf("DATA_PATH   : %s\n", DATA_PATH))
cat(sprintf("OUTPUT_PATH : %s\n", OUTPUT_PATH))
cat(sprintf("TermLimits  : %s\n", ifelse(is.null(termLimits)==TRUE, "NULL", as.character(termLimits))))
}
############################################################
# SAFE Parameter parsing and setting
############################################################
settingFile    <- sprintf("%s/settings.txt", BASE_PATH)
taskinfoFile   <- sprintf("%s/input.csv", BASE_PATH)
dataFile       <- sprintf('%s/sampledata.csv', DATA_PATH)
modelBeforeFile<- sprintf('%s/model_graph_before.pdf', OUTPUT_PATH)
modelErrorFile <- sprintf('%s/model_graph_error.pdf', OUTPUT_PATH)

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
cat(sprintf("Training Data : %s\n",dataFile))
training <- read.csv(dataFile, header=TRUE)
# check data validity
nMissed <- nrow(training[training$result==1,])
nPassed <- nrow(training[training$result==0,])
if (nMissed ==0){
  print(sprintf("No data missed deadline"))
  quit(status=2)
}
if (nPassed ==0){
  print(sprintf("All data missed deadline"))
  quit(status="no")
}
cat(sprintf("Loaded training data: %d samples (nPassed: %d, nMissed: %d, Ratio of Missed: %.2f%%)\n", nrow(training), nPassed, nMissed, nMissed/nrow(training)*100))

############################################################
# variables
############################################################
# feature selection vars
nTree <- 100#, 2000, 3000, 4000, 5000) #c(100, 142, 200, 300,400, 500)
nDepth <- floor(sqrt(ncol(training)-1))#, floor((ncol(training)-1)/3))  #c(1, 3, 12, 15, 18, 20, 23, 26)
# stepwise vars
direction <- "both"


############################################################
## selecting features
############################################################
cat("Selecting features...\n")
features <- c()
{
  cat(sprintf("\tRamdomForest with parameters (nDepth=%d, nTree=%d)...\n", nDepth, nTree))
  rf<-randomForest(result ~ ., data=training, mtry=nDepth, ntree=nTree, importance = TRUE)
  # varImpPlot(rf)  #-- check importance by graph
  
  import_df<- get_relative_importance(rf, 2)  # Use only Column 2 (IncNodePurity)
  mean_import<-mean(import_df$Importance)
  features <- select_terms(import_df, mean_import, limits=termLimits)  # only selectes less than 2 terms
  
  values<-data.frame(t(import_df$Importance))
  colnames(values) <- import_df$Task
  
  # draw barchart
  g <- make_bar_chart(import_df, nTree, nDepth)
  filepath <- sprintf("%s/RF_nDeepth%d_mean%.4f.pdf", OUTPUT_PATH, nDepth, mean_import)
  ggsave(filepath, g, width=7, height=5)
}

# Print result
#print(features)

# save initial formula
formula_str <-  get_formula_complex("result", features)
#formula_str <-  get_formula_linear("result", features)
cat(sprintf("\tFormula: %s\n",formula_str))
write(formula_str, file=sprintf("%s/formula_init", OUTPUT_PATH))

############################################################################
# Logistic regression with formula by choosen significant Tasks from the RF
############################################################################
cat("Learning logistic regression...\n")
# stepwise function
md <- glm(formula = formula_str, family = "binomial", data = training)
md2 <- stepAIC(md, direction = direction, trace=0) # trace=0, stop to print processing

# Get formula
cl<- as.character(md2$formula)
formula_str <- sprintf("%s %s %s", cl[2], cl[1], cl[3])
cat(sprintf("\t Reduced formula: %s\n",formula_str))


# Save formula into R results folder
formulaPath <- sprintf("%s/formula", OUTPUT_PATH)
write(formula_str, file=formulaPath)
cat(sprintf("\tSaved formula into %s\n", formulaPath))


# Draw current model
targetIDs <- get_base_names(names(md2$coefficients), isNum=TRUE)
draw_model(training, md2, TASK_INFO, targetIDs, modelBeforeFile)


## verification
#threshold <- find_noFPR(md2, training, precise=0.0001)  # lowest probability
#cat(sprintf("Probability: %.4f\n",threshold))
#for(taskID in targetIDs){
#    intercept <- get_intercepts(md2, threshold, taskID, TASK_INFO)
#    if (ncol(intercept)>=2 || is.infinite(intercept[1,1])==TRUE){
#        cat(sprintf("Intercepts: %s\n",namedDoubleArrayToStr(intercept)))
#        cat("\nNot applicable Phase 2 with the lowest probability\n\n")
#        threshold <- find_noFNR(md2, training, precise=0.0001)  # highest probability
#        draw_model(training, md2, TASK_INFO, targetIDs, modelErrorFile)
#        quit(status=1)
#    }else{
#        cat(sprintf("Intercepts: %s\n",namedDoubleArrayToStr(intercept)))
#    }
#
#}
cat("Done.\n")

