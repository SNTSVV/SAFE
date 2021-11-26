# Distance based sampling for JAVA_RUN
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
pp<-"results/TOSEM_mix/ESAIL_SAFE/Run01"
ENV$PARAMS  <- c(pp, sprintf("%s/_phase2", pp))
print(sprintf("WORK_PATH : %s", ENV$BASE))
print(sprintf("CODE_BASE : %s", ENV$CODE_BASE))
print(sprintf("PARAMS    : %s", ENV$PARAMS))

############################################################
# Load libraries
############################################################
setwd(ENV$CODE_BASE)  # SET code path
suppressMessages(library(neldermead))
source("libs/lib_config.R")
source("libs/lib_sampling.R")  # find_x_range
source("libs/lib_model.R")     # generate_line_function
source("libs/lib_draw.R")      # draw graph
setwd(ENV$BASE) 			# SET current local directory

############################################################
# R Parameter passing
############################################################
if (length(args)<1){
	cat("Error:: Required parameters: target folder\n\n")
	quit(status=0)
}
BASE_PATH <- getAbsolutePath(ENV$PARAMS[1], ENV$BASE)  # for loading settings
DATA_PATH <- getAbsolutePath(ENV$PARAMS[2], ENV$BASE)
modelFile       <- sprintf("%s/_samples/sample_best_size_%%03d.md", DATA_PATH)
trainingFile    <- sprintf("%s/workdata.csv", DATA_PATH)
resultFile      <- sprintf("%s/workdata_model_result.csv", DATA_PATH)
outputFile      <- sprintf("%s/_verify", DATA_PATH)
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
results$nUpdate <- as.integer(results$nUpdate)
#
#for (name in colnames(training)){
#    if (name == "result") next
#    training[[name]] <- training[[name]] * TIME_QUANTA
#}



# Draw each updates
prevPoints <- 0
idx<-100
modelNum<-c(min(results$nUpdate), max(results$nUpdate))
for (idx in modelNum){
	result<-results[results$nUpdate==idx,]
	update <-result$nUpdate
	modelNum <-result$nUpdate
	nPoints <-result$TrainingSize
	P <- result$Probability
	cat(sprintf("Drawing %d model ...", update))
	
	if (update!=0){
		result<-results[results$nUpdate==idx-1,]
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
		XID <- ifelse(length(XID)==0, yID, XID)
		fx<-generate_line_function(model, P, yID, TASK_INFO$WCET.MIN[yID], TASK_INFO$WCET.MAX[yID])
	}
	
	# GET sampled points
	if (length(XID)==1){
		#points <- training[prevPoints:nPoints,]
		points <- training[1:nPoints,]
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
