# This code is for feature reduction and generating logistic model
# Jaekwon LEE
options(warn=-1)
############################################################
# Load libraries
############################################################
EXEC_PATH <- getwd()
CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)
#EXEC_PATH <- "~/projects/RTA_SAFE"
#CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)

setwd(CODE_PATH)
source("libs/lib_config.R")
source("libs/lib_features.R")
source("libs/lib_formula.R")
source("libs/lib_draw.R")
suppressMessages(library(MASS))    # stepAIC
suppressMessages(library(dplyr))   # ??
suppressMessages(library(randomForest))
suppressMessages(library(ggplot2))
suppressMessages(setwd(CODE_PATH))

############################################################
# R Parameter passing
############################################################
args <- commandArgs()
args <- args[-(1:5)]  # get sublist from arguments (remove unnecessary arguments)
if (length(args)<1){
    cat("Error:: Required parameters: target folder\n\n")
    quit(status=0)
}
BASE_PATH <- sprintf("%s/%s", EXEC_PATH, args[1])
phase1DirName <- ifelse(length(args)>=2, args[2], "_results")
outputDirName <- ifelse(length(args)>=3, args[3], "_formula")


OUTPUT_PATH <- sprintf("%s/%s", BASE_PATH, outputDirName)
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
dataFile      <- sprintf('%s/%s/sampledata.csv', BASE_PATH, phase1DirName)
modelBeforeFile<- sprintf('%s/%s/model_graph_before.pdf', BASE_PATH, outputDirName)
modelErrorFile<- sprintf('%s/%s/model_graph_error.pdf', BASE_PATH, outputDirName)

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
    features <- select_terms(import_df, mean_import)

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
uncertainIDs <- get_base_names(names(md2$coefficients), isNum=TRUE)
draw_model(training, md2, TASK_INFO, uncertainIDs, modelBeforeFile)

# verification
threshold <- find_noFPR(md, training, precise=0.0001)  # lowest probability
intercepts <- get_intercepts(md, threshold, uncertainIDs, TASK_INFO)
if (as.double(intercepts[1,])==Inf){
    cat("\n\nNot applicable Phase 2 with the lowest probability\n\n")
    threshold <- find_noFNR(md, training, precise=0.0001)  # highest probability
    draw_model(training, md2, TASK_INFO, uncertainIDs, modelErrorFile)
    quit(status=1)
}

#threshold <- find_noFNR(md, training, precise=0.0001)  # highest probability
#intercepts <- get_intercepts(md, threshold, uncertainIDs, TASK_INFO)
#if (as.double(intercepts[1,])==Inf){
#    cat("Not applicable Phase 2 with the heighest probability")
#}
#
cat("Done.\n")

