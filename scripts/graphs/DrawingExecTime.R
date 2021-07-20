# Title     : TODO
# Objective : TODO
# Created by: jaekwon.lee
# Created on: 4/14/21
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
# ENV$PARAMS<- c("results/TOSEM/_analysis/EXP1")
print(sprintf("WORK_PATH : %s", ENV$BASE))
print(sprintf("FILE      : %s", ENV$FILE))
print(sprintf("CODE_BASE : %s", ENV$CODE_BASE))
print(sprintf("PARAMS    : %s", ENV$PARAMS))

setwd(ENV$CODE_BASE)
suppressMessages(library(ggplot2))
suppressMessages(library(dplyr))
suppressMessages(library(effsize))
suppressMessages(library(latex2exp))
suppressMessages(library(gridExtra))
source("lib_data.R")
setwd(ENV$BASE)


colorPalette <- c("#000000", "#AAAAAA")
#colorPalette <- c("#5C6777", "#F05628", "#1CA491", "#FFC91B")  #c("#F4D006", "#D9EF93", "#6D99FE", "#6D99FE")
SUBJECTS <- c("ADCS", "ICS", "UAV")
SUBJ_NAMES <- c("ADCS", "ICS", "UAV")
APPROACHES<-c("SAFE", "Baseline")
APPR_NAMES<-c("SAFE", "Baseline")

BASE_PATH <- sprintf("%s/%s", ENV$BASE, ENV$PARAMS[1])
if (length(ENV$PARAMS)>1){
    SUBJECTS <- unlist(strsplit(ENV$PARAMS[2], ","))
    SUBJ_NAMES <- unlist(strsplit(ENV$PARAMS[2], ","))
}
OUTPUT_PATH <- sprintf("%s/%s-graphs", ENV$BASE, ENV$PARAMS[1])
if (file.exists(OUTPUT_PATH)==FALSE){ dir.create(OUTPUT_PATH, recursive = TRUE) }

###############################################
# Load data
###############################################
{
    phase1 <- load_multi_files(BASE_PATH, SUBJECTS, APPROACHES, "%s/P1_%s_%s.csv")
    phase1$Approach<-change_factor_names(phase1$Approach, APPROACHES, APPR_NAMES)
    phase1$Subject<-change_factor_names(phase1$Subject, SUBJECTS, SUBJ_NAMES)
    
    phase2<-data.frame()
    for(subject in SUBJECTS) {
        for(approach in APPROACHES){
            item<-read.csv(sprintf("%s/P2_%s_%s.csv", BASE_PATH, subject, approach), header=TRUE)
            item<-data.frame(Subject=subject, Approach=approach, Run=item$Run,
                               BestSize=item$BestSize, nTerms=item$nTerms, ExecTime=item$ExecutionTime.s.)
            phase2<-rbind(phase2, item)
        }
    }
    # Convert data values for the paper
    phase2$Approach<-change_factor_names(phase2$Approach, APPROACHES, APPR_NAMES)
    phase2$Subject<-change_factor_names(phase2$Subject, SUBJECTS, SUBJ_NAMES)
}
################################################
########## Execution Time         ##############
################################################

########################################################################
# Phase 1 Execution Time for each Subject
########################################################################
cat("\n\nPhase1 execution time:\n")
subjID<-1
for(subjID in c(1:length(SUBJ_NAMES))) {
    subject <- SUBJ_NAMES[subjID]
    phase1S <- phase1[phase1$Subject==subject,]
    if (nrow(phase1S)==0)next

    g <- ggplot(data=phase1S, aes(x=as.factor(.data[["Subject"]]), y=.data[["Total.s."]]/3600.0, color=as.factor(.data[["Approach"]]))) +  #, linetype=as.factor(Type)
        stat_boxplot(geom = "errorbar", width = 0.7, alpha=1, size=0.7) +
        stat_boxplot(geom = "boxplot", width = 0.7, alpha=1, size=0.7, outlier.shape=1, outlier.size=1) +
        xlab("")+ ylab("Execution time of P1 (hours)")+
        scale_color_manual(values=colorPalette) +
        theme_bw()+
        theme(axis.text = element_text(size=20),
              axis.title = element_text(face="bold", size=20),
              legend.justification=c(1,0),
              legend.position=c(0.999, 0.001),
              legend.direction = "vertical",
              legend.title=element_blank(),
              legend.text = element_text(size=20),
              legend.background = element_rect(colour = "black", size=0.2))
    print(g)
    outputName <- sprintf("%s/ExpTime_P1_%d_%s.pdf", OUTPUT_PATH, subjID, subject)
    ggsave(outputName, g, width=5, height=6)
    
    meanAppr1 <- mean(phase1S[phase1S$Approach==APPR_NAMES[1],]$Total.s.)
    meanAppr2 <- mean(phase1S[phase1S$Approach==APPR_NAMES[2],]$Total.s.)
    cat(sprintf("[%s] Average execution time (s) of P1 in %10s: %10.3f \t (%.2fh)\n",subject, APPR_NAMES[1], meanAppr1, meanAppr1/3600.0))
    cat(sprintf("[%s] Average execution time (s) of P1 in %10s: %10.3f \t (%.2fh)\n",subject, APPR_NAMES[2], meanAppr2, meanAppr2/3600.0))
}

########################################################################
## Phase 2 Execution time
########################################################################
cat("\n\nPhase2 execution time:\n")
for(subjID in c(1:length(SUBJ_NAMES))){
    subject <- SUBJ_NAMES[subjID]
    phase2S <- phase2[phase2$Subject==subject,]
    
    g <- ggplot(data=phase2S, aes(x=as.factor(.data[["Subject"]]), y=.data[["ExecTime"]]/3600.0, color=.data[["Approach"]])) +  #, linetype=as.factor(Type)
        stat_boxplot(geom = "errorbar", width = 0.7, alpha=1, size=0.7) +
        stat_boxplot(geom = "boxplot", width = 0.7, alpha=1, size=0.7, outlier.shape=1, outlier.size=1) +
        xlab("")+ ylab("Execution time of P2 (hours)")+
        scale_color_manual(values=colorPalette) +
        theme_bw()+
        theme(axis.text = element_text(size=20),
              axis.title = element_text(face="bold", size=20),
              legend.justification=c(1,1),
              legend.position=c(0.999, 0.999),
              legend.direction = "vertical",
              legend.title=element_blank(),
              legend.text = element_text(size=20),
              legend.background = element_rect(colour = "black", size=0.2))
    print(g)
    outputName <- sprintf("%s/ExpTime_P2_%d_%s.pdf", OUTPUT_PATH, subjID, subject)
    ggsave(outputName, g, width=5, height=6)
    
    meanAppr1 <- mean(phase2S[phase2S$Approach==APPR_NAMES[1],]$ExecTime)
    meanAppr2 <- mean(phase2S[phase2S$Approach==APPR_NAMES[2],]$ExecTime)
    cat(sprintf("[%s] Average execution time (s) of P2 in %10s: %10.4f \t (%.2fh)\n",subject, APPR_NAMES[1], meanAppr1, meanAppr1/3600.0))
    cat(sprintf("[%s] Average execution time (s) of P2 in %10s: %10.4f \t (%.2fh)\n",subject, APPR_NAMES[2], meanAppr2, meanAppr2/3600.0))
}

########################################################################
## All Execution time (phase1 + phase2), randomsearch calculates the calculating best size
########################################################################
cat("\n\nTotal execution time:\n")
for(subject in SUBJ_NAMES)
{
    if (nrow(phase1[phase1$Subject==subject,])==0) next
 
    total <- data.frame()
    for(approach in APPR_NAMES){
        for(runID in phase1$Run){
            t1 <- phase1[phase1$Subject==subject & phase1$Approach==approach & phase1$Run==runID,]
            t2 <- phase2[phase2$Subject==subject & phase2$Approach==approach & phase2$Run==runID,]
            ts <- ifelse(nrow(t1)==0 || nrow(t2)==0, 0, t1$Total.s.+t2$ExecTime)
            item <- data.frame(Subject=subject, Approach=approach, Run=runID, AllTime=ts)
            total <- rbind(total, item)
        }
    }
    head(total)

    g <- ggplot(data=total, aes(x=as.factor(.data[["Subject"]]), y=.data[["AllTime"]]/3600.0, color=as.factor(.data[["Approach"]]))) +  #, linetype=as.factor(Type)
      stat_boxplot(geom = "errorbar", width = 0.7, alpha=1, size=0.7) +
      stat_boxplot(geom = "boxplot", width = 0.7, alpha=1, size=0.7, outlier.shape=1, outlier.size=1) +
      xlab("")+ ylab("Execution time of all (hours)")+
      scale_color_manual(values=colorPalette) +
      theme_bw()+
      theme(axis.text = element_text(size=20),
            axis.title = element_blank(),#element_text(face="bold", size=20),
            legend.justification=c(1,1),
            legend.position=c(0.999, 0.999),
            legend.direction = "vertical",
            legend.title=element_blank(),
            legend.text = element_text(size=20),
            legend.background = element_rect(colour = "black", size=0.2))
    print(g)
  
    # calculate statistical information
    ret <- stats_function(total, "AllTime", APPR_NAMES[1], APPR_NAMES[2])
    dt <- data.frame(Type=c("p-value", "A12"), Subject=subject, value=c(ret$p, ret$A12), pos=c(2,1))
    
    # draw for the statistical information
    {
      g2 <- ggplot(dt) +
          geom_text(aes(x=as.factor(Subject), y=pos, label=sprintf("%.4f",value)), color="blue", size=6)+
          theme_classic()+
          theme(axis.text=element_blank(),
                axis.title=element_blank(),
                axis.line=element_blank(),
                axis.ticks=element_blank(),
                plot.margin = margin(0, 0, 0, 30, "pt"),
                plot.background = element_rect()) +
          geom_text(x=0.6, y=2, hjust=1, size=6, label=TeX("p-value"), color="blue")+
          geom_text(x=0.6, y=1,  hjust=1, size=6, label=TeX("\\hat{A}_{12}"), color="blue")+
          coord_cartesian(xlim=c(1,1), ylim = c(0.5, 2.5), clip = "off")
    }
    
    # output both graphs
    to_print<-grid.arrange(g, g2, nrow=2, heights = c(5, 1))
    outputName <- sprintf("%s/rq1_exptime_%s.pdf", OUTPUT_PATH, subject)
    ggsave(outputName, to_print, width=5, height=6)

    # statistics
    one<-total[total$Approach==APPR_NAMES[1],]
    two<-total[total$Approach==APPR_NAMES[2],]
    cat(sprintf("[%s] Average of %10s (s): %10.4f \t (%.2fh)\n", subject, APPR_NAMES[1], mean(one$AllTime), mean(one$AllTime)/3600.0))
    cat(sprintf("[%s] Average of %10s (s): %10.4f \t (%.2fh)\n", subject, APPR_NAMES[2], mean(two$AllTime), mean(one$AllTime)/3600.0))
    cat(sprintf("[%s] p-value=%.8e, A12=%.8e\n\n", subject, dt[dt$Type=='p-value',]$value, dt[dt$Type=='A12',]$value))
}
