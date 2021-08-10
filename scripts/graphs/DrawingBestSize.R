# Title     : TODO
# Objective : TODO
# Created by: jaekwon.lee
# Created on: 4/14/21
############################################################
# Load libraries
############################################################
options(warn=-1)
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
subjID <- 1
data<-list()
for(subjID in c(1:length(SUBJECTS)))
{
    subject<- SUBJECTS[subjID]
    subjData<-data.frame()
    for(appr in c(1:length(APPROACHES))){
        approach <- APPROACHES[appr]
        filename <- sprintf("%s/P2_%s_%s.csv", BASE_PATH, subject, approach)

        subset<-read.csv(filename, header=TRUE)
        subset<-data.frame(Subject=subject, Approach=approach, Run=subset$Run,
                           BestSize=subset$BestSize, nTerms=subset$nTerms, ExecTime=subset$ExecutionTime.s.)
        data<-rbind(data, subset)
    }
}

#################################################
# Distribution - number of terms - execution time of Phase 2
{
    item<-data[as.character(data$Approach)=="SAFE" & as.character(data$Subject)=="ICS", ]
    g <- ggplot(data=item, aes(x=as.factor(.data[["nTerms"]]), y=.data[["ExecTime"]])) +  #, linetype=as.factor(Type)
        stat_boxplot(geom = "errorbar", width = 0.7, alpha=1, size=0.7) +
        stat_boxplot(geom = "boxplot", width = 0.7, alpha=1, size=0.7, outlier.shape=1, outlier.size=1) +
        xlab("")+ ylab("Execution time of Phase 2")+
        scale_color_manual(values=colorPalette) +
        theme_bw()+
        theme(axis.text = element_text(size=20),
              axis.title = element_text(face="bold", size=20))
    print(g)
    outputName <- sprintf("%s/rq1_NumTerms.pdf", OUTPUT_PATH)
    ggsave(outputName, g, width=7, height=5)
}

# Convert data values for the paper
data$Approach<-change_factor_names(data$Approach, APPROACHES, APPR_NAMES)
data$Subject<-change_factor_names(data$Subject, SUBJECTS, SUBJ_NAMES)

#################################################
# Draw best size (box-plot)
subjID<-3
bestSizes <- data.frame()
for(subjID in c(1:length(SUBJ_NAMES)))
{
    item <- data[data$Subject==SUBJ_NAMES[subjID],]
    if (nrow(item)==0) next

    # calculate statistical information
    ret <- stats_function(item, "BestSize", APPR_NAMES[1], APPR_NAMES[2])
    dt <- data.frame(Type=c("p-value", "A12"), Subject=SUBJ_NAMES[subjID], value=c(ret$p, ret$A12), pos=c(2,1))

    # make basic graph
    {
        g <- ggplot(data=item, aes(x=as.factor(.data[["Subject"]]), y=.data[["BestSize"]], color=.data[["Approach"]])) +  #, linetype=as.factor(Type)
            stat_boxplot(geom = "errorbar", width = 0.7, alpha=1, size=0.7) +
            stat_boxplot(geom = "boxplot", width = 0.7, alpha=1, size=0.7, outlier.shape=1, outlier.size=1) +
            xlab("")+ ylab("The volume of the best size")+
            scale_color_manual(values=colorPalette) +
            theme_bw()+
            scale_y_continuous(trans='log10')+ #, labels = "scientific")+
            theme(axis.text = element_text(size=20, face="bold"),
                axis.title = element_blank(),#element_text(face="bold", size=20),
                legend.direction = "vertical",
                legend.title=element_blank(),
                legend.text = element_text(size=20),
                legend.background = element_rect(colour = "black", size=0.2))
        if (subjID==2){
            g <- g + theme(legend.justification=c(1,0), legend.position=c(0.999, 0))
        }else{
            g <- g + theme(legend.justification=c(1,1), legend.position=c(0.999, 0.999))
        }
        # add number of points
        # mid <- (max(item$BestSize) - min(item$BestSize))/2
        # st1<-item %>% count(Approach)
        # g <- g+ geom_text(data=st1[1,], aes(x=1-0.18, y=mid, label=sprintf("%d",n)), hjust=0.5, size=8)
        # g <- g+ geom_text(data=st1[2,], aes(x=1+0.18, y=mid, label=sprintf("%d",n)), hjust=0.5, size=8)

        # g <- g+ geom_text(data=st1[1,], aes(x=1-0.22, y=mid, label=sprintf("%d",n)), hjust=0.5, size=8)
        # g <- g+ geom_text(data=st1[2,], aes(x=1, y=mid, label=sprintf("%d",n)), hjust=0.5, size=8)
        # g <- g+ geom_text(data=st1[3,], aes(x=1+0.22, y=mid, label=sprintf("%d",n)), hjust=0.5, size=8)
        # pos1delta<-c(  6e-2, 3.3e-5, 9e+7)
        # pos2delta<-c(4.5e-2, 2.1e-5, 2.5e+7)
    }

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
    head(dt)
    # output both graphs
    to_print<-grid.arrange(g, g2, nrow=2, heights = c(5, 1))
    outputName <- sprintf("%s/rq1_bestsize_%s.pdf", OUTPUT_PATH, SUBJ_NAMES[subjID])
    ggsave(outputName, to_print, width=5, height=6)

    one<-item[item$Approach==APPR_NAMES[1],]
    two<-item[item$Approach==APPR_NAMES[2],]
    cat(sprintf("[%s] Average of %s: %.8e\n", SUBJ_NAMES[subjID], APPR_NAMES[1], mean(one$BestSize)))
    cat(sprintf("[%s] Average of %s: %.8e\n", SUBJ_NAMES[subjID], APPR_NAMES[2], mean(two$BestSize)))
    cat(sprintf("[%s] p-value=%.8e, A12=%.8e\n", SUBJ_NAMES[subjID], dt[dt$Type=='p-value',]$value, dt[dt$Type=='A12',]$value))
}
