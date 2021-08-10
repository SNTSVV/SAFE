# Title     : TODO
# Objective : TODO
# Created by: jaekwon.lee
# Created on: 4/14/21
# Distance based sampling for JAVA_RUN
options(warn=-1)
############################################################
# Load libraries
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
ENV<-getENV("scripts/graphs")   # the codeBase parameter is for debug, it will be ignored when this script is executed by RScript
# ENV$PARAMS<- c("results/TOSEM/_analysis/EXP3")
print(sprintf("WORK_PATH : %s", ENV$BASE))
print(sprintf("FILE      : %s", ENV$FILE))
print(sprintf("CODE_BASE : %s", ENV$CODE_BASE))
print(sprintf("PARAMS    : %s", ENV$PARAMS))

setwd(ENV$CODE_BASE)
source("lib_draw.R")
setwd(ENV$BASE)

#########################################################################################
# Settings
#########################################################################################
colorPalette <- c("#000000", "#AAAAAA")
#colorPalette <- c("#5C6777", "#F05628", "#1CA491", "#FFC91B")  #c("#F4D006", "#D9EF93", "#6D99FE", "#6D99FE")
SUBJECTS<-c("ADCS")

BASE_PATH <- sprintf("%s/%s", ENV$BASE, ENV$PARAMS[1])
if (length(ENV$PARAMS)>1){
  SUBJECTS <- unlist(strsplit(ENV$PARAMS[2], ","))
  SUBJ_NAMES <- unlist(strsplit(ENV$PARAMS[2], ","))
}

OUTPUT_PATH <- sprintf("%s/%s-graphs", ENV$BASE, ENV$PARAMS[1])
if (file.exists(OUTPUT_PATH)==FALSE){ dir.create(OUTPUT_PATH, recursive = TRUE) }
#########################################################################################
# Precision Graph for k-fold (RQ3)
#########################################################################################
for(subject in SUBJECTS)
{
    # load data
    data <- read.csv(sprintf("%s/kfold_%s_SAFE.csv", BASE_PATH, subject), header=TRUE)
    
    # drawing graph
    g<-generate_box_plot_single(data, "nUpdate", "CV.Precision.Avg", "# of model refinements", "Precision",
                       nBox=10, title="", ylimit=c(0.9985,1.0), colorList=colorPalette, start=0)
    print(g)
    filename <- sprintf("%s/rq3_%s_prec.pdf", OUTPUT_PATH, subject)
    ggsave(filename, g, width=8, height=3)
}