# Distance based sampling for JAVA_RUN
options(warn=-1)

############################################################
# Load libraries
############################################################
EXEC_PATH <- "~/projects/RTA_SAFE"
CODE_PATH <- sprintf("%s/scripts/Phase2", EXEC_PATH)
args <- c("results/TOSEM_20a/GAP/Run01", "_phase2")
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
initial <- training[1:20200,]
refine <- training[20200:nrow(training),]

tID<-21
data <- data.frame()
for (tID in c(1:nrow(TASK_INFO))){
  vRange <- TASK_INFO$WCET.MAX[tID] - TASK_INFO$WCET.MIN[tID]

  #initial
  values <- initial[[sprintf("T%d",tID)]]
  normInitial <- (values-TASK_INFO$WCET.MIN[tID])/vRange

  #refine
  values <- refine[[sprintf("T%d",tID)]]
  normRefine <- (values-TASK_INFO$WCET.MIN[tID])/vRange

  avgI<- mean(normInitial)
  avgR<- mean(normRefine)
  sdR<-sd(normRefine)
  sdI<-sd(normInitial)
  cat(sprintf("%d, %.2f, %.2f\n", tID, avgR/avgI, sdR/sdI))

  item <- data.frame(TaskID=tID, Type="average", value=avgR/avgI, rSd=sdR/sdI)

  data<- rbind(data, data.frame(TaskID=tID, Type="average", value=avgR/avgI-1))
  data<- rbind(data, data.frame(TaskID=tID, Type="stdev", value=sdR/sdI-1))

}

ggplot(data, aes(y=value, x=as.factor(TaskID), fill=Type))+
  geom_bar(stat="identity", position=position_dodge())+
  scale_fill_manual(values=c('black','gray'))+
  ylab("Ratio (Phase2/Phase1)")+xlab("Task ID")+ylim(-1,1)+
  theme_bw() +
  theme(axis.text=element_text(size=20), axis.title=element_text(size=18, face="bold"),
        legend.justification=c(1,1), legend.position=c(0.999, 0.999),
        legend.direction = "vertical", legend.title=element_blank(),
        legend.text = element_text(size=15), legend.background = element_rect(colour = "black", size=0.2))


# draw graph
#histData<-data.frame(value=normInitial)
#ggplot(histData, aes(value))+geom_histogram(binwidth = 0.01)
#histData<-data.frame(value=normRefine)
#ggplot(histData, aes(value))+ geom_histogram(binwidth = 0.01)

