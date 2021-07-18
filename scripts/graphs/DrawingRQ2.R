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
ENV<-getENV("scripts/graphs")   # the codeBase parameter is for debug, when this script execute by RScript it will be ignored
# ENV$PARAMS<- c("results/TOSEM/_analysis/EXP2")
print(sprintf("WORK_PATH : %s", ENV$BASE))
print(sprintf("FILE      : %s", ENV$FILE))
print(sprintf("CODE_BASE : %s", ENV$CODE_BASE))
print(sprintf("PARAMS    : %s", ENV$PARAMS))

setwd(ENV$CODE_BASE)
suppressMessages(library(grid))
suppressMessages(library(gridExtra))
source("lib_data.R")
source("lib_draw.R")
setwd(ENV$BASE)

#########################################################################################
# Settings
#########################################################################################
colorPalette <- c("#000000", "#AAAAAA")
#colorPalette <- c("#5C6777", "#F05628", "#1CA491", "#FFC91B")  #c("#F4D006", "#D9EF93", "#6D99FE", "#6D99FE")
SUBJECTS<-c("ADCS", "ICS", "UAV")
SUBJ_NAMES<-c("ADCS", "ICS", "UAV")
APPROACHES<-c("dist", "random")
APPR_NAMES<-c("D", "R")

BASE_PATH <- sprintf("%s/%s", ENV$BASE, ENV$PARAMS[1])
if (length(ENV$PARAMS)>1){
    SUBJECTS <- unlist(strsplit(ENV$PARAMS[2], ","))
    SUBJ_NAMES <- unlist(strsplit(ENV$PARAMS[2], ","))
}

OUTPUT_PATH <- sprintf("%s/%s-graphs", ENV$BASE, ENV$PARAMS[1])
if (file.exists(OUTPUT_PATH)==FALSE){ dir.create(OUTPUT_PATH, recursive = TRUE) }
#########################################################################################
# Precision & Recall Graph
#########################################################################################
# load data from csv files
{
    data <- data.frame()
    for(subject in SUBJECTS) {
        for(appr in APPROACHES) {
            dataFile <- sprintf("%s/test_%s_%s.csv", BASE_PATH, subject, appr)
            item <- read.csv(dataFile, header=TRUE)
            data <- rbind(data, data.frame(Subject=subject, Approach=appr, nUpdate=item$nUpdate, Prec=item$Prec, Recall=item$Rec))
        }
    }
    data$Approach <- change_factor_names(data$Approach, APPROACHES, APPR_NAMES)
    data$Subject <- change_factor_names(data$Subject, SUBJECTS, SUBJ_NAMES)
}

# draw full precision graphs
for(subject in SUBJ_NAMES)
{
    subs<-data[data$Subject==subject,]

    gt <-generate_box_plot(subs,"nUpdate", "Prec", "Approach","# of model refinements", "", nBox=5, title="",
                                ylimit=NULL, colorList=colorPalette, legend="", legend_direct="horizontal", legend_font=15, trans=NULL)
    filename <- sprintf("%s/rq2_%s_prec_full.pdf", OUTPUT_PATH, subject)
    ggsave(filename, gt, width=4, height=3)
}

# draw precision graphs
for(subject in SUBJ_NAMES)
{
    subs<-data[data$Subject==subject,]

    gt <-generate_box_plot_part(subs,"nUpdate", "Prec", "Approach","# of model refinements", "", nBox=5, title="",
                              ylimit=c(0.996,1.0), colorList=colorPalette, legend="", legend_direct="horizontal", legend_font=15, trans=NULL, part="top", part_breaks=NULL)
    gb <-generate_box_plot_part(subs,"nUpdate", "Prec", "Approach", "# of model refinements", "", nBox=5, title="",
                              ylimit=c(0.96,0.98), colorList=colorPalette, legend="rb", legend_direct="horizontal", legend_font=15, trans=NULL, part="bottom", part_breaks=c(0.97))
    # print(gb)
    # output both graphs
    to_print<-grid.arrange(gt, gb, nrow=2, left=textGrob("Precision",gp=gpar(fontsize=15), rot=90, hjust=0.3), heights = c(2, 1))
    filename <- sprintf("%s/rq2_%s_prec.pdf", OUTPUT_PATH, subject)
    ggsave(filename, to_print, width=4, height=3)
}


# draw Precision (p-value) graphs
for(subject in SUBJ_NAMES)
{
    subs<-data[data$Subject==subject,]
    # save significant
    stats_data <-  compare_RQ2_results(subs, "nUpdate", "Prec", "Approach", APPR_NAMES)
    g <- generate_significant_plot(stats_data, 0.05, "# of model refinements", "p-value")
    filename <- sprintf("%s/pvalue-rq2_%s_prec.pdf", OUTPUT_PATH, subject)
    ggsave(filename, g, width=5, height=4)
    maxIter<-max(stats_data$nUpdate)
    lastP <- stats_data[stats_data$nUpdate==maxIter,]$p
    print(sprintf("[%s] P-value of precision: %.4f", subject, lastP))
}


# draw recall graphs
for(subject in SUBJ_NAMES)
{
    subs<-data[data$Subject==subject,]

    g<-generate_box_plot(subs,
                         "nUpdate", "Recall", "Approach",
                         "# of model refinements", "Recall",
                         nBox=5, title="", ylimit=c(0,1), colorList=colorPalette, legend="rb",
                         legend_direct="horizontal", legend_font=15)
    #print(g)
    filename <- sprintf("%s/rq2_%s_recall.pdf", OUTPUT_PATH, subject)
    ggsave(filename, g, width=4, height=3)

    # save significant
    # g<-generate_significant_plot(data, "nUpdate", "Rec", "Approach", APPR_NAMES, 0.05, "# of model refinements", "p-value")
    # filename <- sprintf("%s/rq2_%s_recall_pvalue.pdf", OUTPUT_PATH, subject)
    #
    # ggsave(filename, g, width=5, height=4)
    stats_data <-  compare_RQ2_results(subs, "nUpdate", "Recall", "Approach", APPR_NAMES)
    g<-generate_significant_plot(stats_data, 0.05, "# of model refinements", "p-value")
    filename <- sprintf("%s/pvalue-rq2_%s_recall.pdf", OUTPUT_PATH, subject)
    ggsave(filename, g, width=5, height=4)
    maxIter<-max(stats_data$nUpdate)
    lastP <- stats_data[stats_data$nUpdate==maxIter,]$p
    print(sprintf("[%s] P-value of recall: %.4f", subject, lastP))

}



#########################################################################################
# Execution time of Phase 2
#########################################################################################
# load data from csv files
{
    data <- load_multi_files(BASE_PATH, SUBJECTS, APPROACHES, "%s/exec_%s_%s.csv")
    data <- data.frame(Subject=data$Subject, Approach=data$Approach, Run=data$Run, ExecTime=data$Total.s.)
    data$Subject <- change_factor_names(data$Subject, SUBJECTS, SUBJ_NAMES)
    data$Approach <- change_factor_names(data$Approach, APPROACHES, APPR_NAMES)
}

# statistics
for (subject in  SUBJ_NAMES){
    one<-data[data$Subject==subject & data$Approach==APPR_NAMES[1],]
    two<-data[data$Subject==subject & data$Approach==APPR_NAMES[2],]
    avgOne <- mean(one$ExecTime)
    avgTwo <- mean(two$ExecTime)
    cat(sprintf("[%s] Average execution time of %s: %10.4fs (%.2fh)\n", subject, APPR_NAMES[1], avgOne, avgOne/3600))
    cat(sprintf("[%s] Average execution time of %s: %10.4fs (%.2fh)\n", subject, APPR_NAMES[2],  avgTwo, avgTwo/3600))
    # cat(sprintf("[%s] p-value=%.8e, A12=%.8e\n\n", subject, dt[dt$Type=='p-value',]$value, dt[dt$Type=='A12',]$value))
}
