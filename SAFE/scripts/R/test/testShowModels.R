# Distance based sampling for JAVA_RUN
options(warn=-1)

############################################################
# Load libraries
############################################################
EXEC_PATH <- "~/projects/RTA_SAFE"
CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)
args <- c("results/TOSEM_mix/ESAIL/Run01", "_phase2")
setwd(CODE_PATH)
suppressMessages(library(neldermead))
source("libs/lib_config.R")
source("libs/lib_sampling.R")  # find_x_range
source("libs/lib_model.R")     # generate_line_function
source("libs/lib_draw.R")      # draw graph
setwd(CODE_PATH)

############################################################
# R Parameter passing
############################################################
if (length(args)<1){
  cat("Error:: Required parameters: target folder\n\n")
  quit(status=0)
}
BASE_PATH       <- sprintf("%s/%s", EXEC_PATH, args[1])
modelFile       <- sprintf("%s/%s/_samples/sample_best_size_%%03d.md", BASE_PATH, args[2])
trainingFile    <- sprintf("%s/%s/workdata.csv", BASE_PATH, args[2])
resultFile      <- sprintf("%s/%s/workdata_model_result.csv", BASE_PATH, args[2])
outputFile      <- sprintf("%s/%s/_verify", BASE_PATH, args[2])
if(dir.exists(outputFile)==FALSE) dir.create(outputFile, recursive=TRUE)
outputFile      <- sprintf("%s/model_graph_%%03d.pdf", outputFile)

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

training <- read.csv(trainingFile, header= TRUE)
results <- read.csv(resultFile, header= TRUE)

# Draw each updates
prevPoints <- 0
idx<-2
for (idx in c(1, 11,12, nrow(results))){
    result<-results[idx,]
    update <-result$nUpdate
    modelNum <-result$nUpdate
    nPoints <-result$TrainingSize
    P <- result$Probability
    cat(sprintf("Drawing %d model ...", update))

    if (update!=0){
      result<-results[idx-1,]
      modelNum <-result$nUpdate
      P <- result$Probability
    }

    # load model
    md.csv<-read.csv(sprintf(modelFile, modelNum),header=FALSE, stringsAsFactors=FALSE)
    model.coef <- as.double(md.csv[2,])
    names(model.coef) <- md.csv[1,]
    model <- list(coefficients=model.coef)

    # find model function
    targetIDs <- get_base_names(names(model$coefficients), isNum=TRUE)
    if (length(targetIDs)>=2){
      yID <- targetIDs[length(targetIDs)]
      XID <- targetIDs[1:(length(targetIDs)-1)]
      fx<-generate_line_function(model, P, yID, TASK_INFO$WCET.MIN[yID], TASK_INFO$WCET.MAX[yID])
    }else{
      yID <- targetIDs[length(targetIDs)]
      XID <- TASK_INFO$ID[-yID][1]
      fx<-generate_line_function(model, P, yID, TASK_INFO$WCET.MIN[yID], TASK_INFO$WCET.MAX[yID])
    }

    # GET sampled points
    if (length(XID)==1){
      points <- training[prevPoints:nPoints,]
      uData <- update_data(points, labels=c("No deadline miss", "Deadline miss"))
      g<-generate_WCET_scatter(uData, TASK_INFO, XID, yID, labelCol = "labels", legendLoc="rt",
                               model.func=fx, probability = P,
                               labelColor=c("#3ECCFF", "#F2A082"), labelShape=c(1, 25))
      #print(g)
      ggsave(sprintf(outputFile, update), width=7, height=5)
    }else{
      cat("Cannot generate graph because the high-dimension\t")
    }
    prevPoints <- nPoints
    cat("Done\n")
}
