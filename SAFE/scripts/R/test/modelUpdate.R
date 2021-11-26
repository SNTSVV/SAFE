# Title     : TODO
# Objective : TODO
# Created by: jaekwon.lee
# Created on: 3/21/21
############################################################
# Load libraries
############################################################
EXEC_PATH <- "~/projects/RTA_SAFE"
CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)
args <- ("results/SAFE_CCS")

setwd(CODE_PATH)
source("libs/lib_config.R")
source("libs/lib_data.R")          # dependency for lib_evalu
source("libs/lib_metrics.R")         # dependency for lib_evaluate (noF
source("libs/lib_evaluate.R")          # find_noFPR, integrateMC, calculate_metrics, kfol
source("libs/lib_pruning.R")         # pruning functi
source("libs/lib_formula.R")         # formula functions (get_raw_names, get_base_nam
source("libs/lib_model.R")         # dependency for sampling (generate_model_li
source("libs/lib_sampling.R")          # sampling functi
setwd(CODE_PATH)

BASE_PATH <- sprintf("%s/%s", EXEC_PATH, args[1])

cat("============== Environment ===================\n")
cat(sprintf("EXEC_PATH: %s\n", EXEC_PATH))
cat(sprintf("CODE_PATH: %s\n", CODE_PATH))
cat(sprintf("BASE_PATH: %s\n", BASE_PATH))

############################################################
# SAFE Parameter parsing and setting
############################################################
settingFile   <- sprintf("%s/settings.txt", BASE_PATH)
taskinfoFile  <- sprintf("%s/input.csv", BASE_PATH)
dataFile      <- sprintf('%s/_results/sampledata.csv', BASE_PATH)

settings      <- parsingParameters(settingFile)
TIME_QUANTA   <- settings[['TIME_QUANTA']]
UNIT          <- 1
TASK_INFO     <- load_taskInfo(taskinfoFile, TIME_QUANTA)

SAMPLE_PATH   <- sprintf("%s/_results/sampledata.csv", BASE_PATH)
FORMULA_PATH  <- sprintf("%s/_formula/formula", BASE_PATH)
OUTPUT_PATH   <- sprintf("%s/_phase2", BASE_PATH)
TRAINING_PATH <- sprintf("%s/_phase2/workdata.csv", BASE_PATH)
TEST_PATH     <- sprintf("%s/_results/testdata.csv", BASE_PATH)
Balance       <- FALSE
MODEL_PROB_PRECISION <- 0.0001

if(dir.exists(OUTPUT_PATH)==FALSE) dir.create(OUTPUT_PATH, recursive=TRUE)

############################################################
# Second Phase
############################################################
formula <- trimws(readChar(FORMULA_PATH, file.info(FORMULA_PATH)$size))
training <- read.csv(SAMPLE_PATH, header=TRUE)
write.table(training, TRAINING_PATH, append = FALSE, sep = ",", dec = "..", row.names = FALSE, col.names = TRUE)


termination.results <- data.frame()


# load TEST DATA
if (TEST_PATH!=""){
    test.results <- data.frame()
    test.samples <-read.csv(TEST_PATH, header=TRUE)
    positive <-test.samples[test.samples$result==0,]
    negative <-test.samples[test.samples$result==1,]
    cat(sprintf("Test data (positive): %d\n", nrow(positive)))
    cat(sprintf("Test data (negative): %d\n", nrow(negative)))
}

# make balanced data
if (Balance==TRUE){
    # get uncertainIDs from formula
    .removedLabel <- strsplit(formula, "~")[[1]][2]
    .terms <- strsplit(trimws(.removedLabel), "\\+")[[1]]
    uncertainIDs <- get_base_names(.terms, isNum=TRUE)

    uncertainIDs
    # make intercept information from the TASK_INFO
    intercepts<-data.frame(t(TASK_INFO$WCET.MAX[uncertainIDs]))
    colnames(intercepts) <- sprintf("T%d", uncertainIDs)

    # create blanceSide and
    positive <- nrow(training[training$result==0,])
    negative <- nrow(training[training$result==1,])
    balanceSide <- ifelse(positive > negative, "positive", "negative")
    training <- pruning(training, balanceSide, intercepts, uncertainIDs)

    # save training data
    write.table(training, TRAINING_PATH, append = FALSE, sep = ",", dec = "..", row.names = FALSE, col.names = TRUE)
}

# Initialize value
{
    #  learning logistic regression with simple formula
    base_model <- glm(formula = formula, family ="binomial", data = training)
    cntUpdate <- 0

    # pdate borderProbability and area
    uncertainIDs <- get_base_names(names(base_model$coefficients), isNum=TRUE)
    borderProbability <- find_noFPR(base_model, training, precise=MODEL_PROB_PRECISION)
    borderProbability <- ifelse(borderProbability==0, MODEL_PROB_PRECISION, borderProbability)
    print(sprintf("The result of find_noFPR: %.6f", borderProbability))
    areaMC <- integrateMC(10000, base_model, IDs=uncertainIDs, prob=0.0001, UNIT.WCET=UNIT)
    bestPoint <- get_bestsize_point(base_model, borderProbability, targetIDs=uncertainIDs, isGeneral=TRUE)

    # keep coefficients
    coef <- t(data.frame(base_model$coefficients))
    colnames(coef) <- get_raw_names(names(base_model$coefficients))
    coef.item <- data.frame(nUpdate=cntUpdate, TrainingSize=nrow(training), Probability=borderProbability, BestX=bestPoint$X, BestY=bestPoint$Y, BestPointArea=bestPoint$Area, Area=areaMC, coef)
    rownames(coef.item) <- c(cntUpdate)
    coef.results <- coef.item

    cat(sprintf("probability: %.6f", borderProbability))
}

# Initialize value
NUM_SAMPLES <- 1
NUM_CANDIDATE <- 20

tnames <- get_task_names(training)
sampled_data <- sample_based_euclid_distance(tnames, base_model, nSample=NUM_SAMPLES, nCandidate=NUM_CANDIDATE, P=borderProbability)

sampled_data <- sample_by_random(tnames, NUM_SAMPLES)
