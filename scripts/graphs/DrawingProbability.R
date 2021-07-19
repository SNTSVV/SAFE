# Title     : TODO
# Objective : TODO
# Created by: jaekwon.lee
# Created on: 4/14/21

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

############################################################
# Base settings
############################################################
colorPalette <- c("#000000", "#AAAAAA")
#colorPalette <- c("#5C6777", "#F05628", "#1CA491", "#FFC91B")  #c("#F4D006", "#D9EF93", "#6D99FE", "#6D99FE")
SUBJECTS<-c("ADCS", "ICS", "UAV")
SUBJ_NAMES<-c("ADCS", "ICS", "UAV")
maxHeight <- 0.020

BASE_PATH <- sprintf("%s/%s", ENV$BASE, ENV$PARAMS[1])
if (length(ENV$PARAMS)>1){
    SUBJECTS <- unlist(strsplit(ENV$PARAMS[2], ","))
    SUBJ_NAMES <- unlist(strsplit(ENV$PARAMS[2], ","))
}

OUTPUT_PATH <- sprintf("%s/%s-graphs", ENV$BASE, ENV$PARAMS[1])
if (file.exists(OUTPUT_PATH)==FALSE){ dir.create(OUTPUT_PATH, recursive = TRUE) }

########################################################################
### load RoundTrip results
########################################################################
# load data
{
    # Load data from Phase2
    data <- data.frame()
    for(subject in SUBJECTS) {
        print(sprintf("[%s] Loading P2 data ...", subject))
        filename <- sprintf("%s/P2_%s_SAFE.csv", BASE_PATH, subject)
        item <- read.csv(filename, header=TRUE)
        item <- data.frame(Subject=subject, Run=item$Run, Eval="Model", Probability=item$Probability)
        data <- rbind(data, item)
    }

    # load RT result file
    for (subject in SUBJECTS){
        print(sprintf("[%s] Loading RT data ...", subject))
        ratioFile <- sprintf("%s/RT_%s_SAFE.csv", BASE_PATH, subject)
        item <- read.csv(ratioFile, header=TRUE)
        item <- data.frame(Subject=subject, Run=item$Run, Eval="Empirical", Probability=item$ratioDM)
        data <- rbind(data, item)
    }
    
    # A12, p-value
    dt<-data.frame()
    for (subject in SUBJECTS){
        print(sprintf("[%s] Calculating p-value, A12 ...", subject))
        ds <- data[as.character(data$Subject)==subject,]
        if (nrow(ds)==0)next
        ret <- stats_function(ds, "Probability", "Model", "Empirical", compCol="Eval")
        dt <- rbind(dt, data.frame(Type=c("p-value", "A12"), Subject=subject, value=c(ret$p, ret$A12), pos=c(2,1)))
    }
    
    # change data subject names for paper
    data$Subject<- change_factor_names(data$Subject, SUBJECTS, SUBJ_NAMES)
    dt$Subject <- change_factor_names(dt$Subject, SUBJECTS, SUBJ_NAMES)
}

# Drawing
{
    # make box-plots
    {
        g <- ggplot(data=data, aes(x=as.factor(.data[["Subject"]]), y=.data[["Probability"]], color=.data[["Eval"]])) +  #, linetype=as.factor(Type)
          stat_boxplot(geom = "errorbar", width = 0.7, alpha=1, size=0.7) +
          stat_boxplot(geom = "boxplot", width = 0.7, alpha=1, size=0.7, outlier.shape=1, outlier.size=1) +
          xlab("")+ ylab("The probability of deadline miss")+
          scale_color_manual(values=colorPalette) +
          theme_bw()+
          #ylim(0, 0.)+
          #scale_y_continuous(trans='log10')+ #, labels = "scientific")+
          theme(axis.text = element_text(size=20),
                axis.title = element_blank(),#element_text(face="bold", size=20),
                legend.direction = "vertical",
                legend.title=element_blank(),
                legend.text = element_text(size=20),
                legend.background = element_rect(colour = "black", size=0.2),
                plot.margin = margin(5, 5, 5, 20, "pt"))
        # label
        # g <- g + theme(legend.justification=c(1,1), legend.position=c(0.999, 0.999))
        g <- g + theme(legend.justification=c(0,1), legend.position=c(0, 0.999))
    }

    # make the statistical information
    {
        g2 <- ggplot(dt) +
            geom_text(aes(x=as.factor(Subject), y=pos, label=sprintf("%.4f",value)), color="blue", size=6)+
            theme_classic()+
            theme(axis.text=element_blank(),
                  axis.title=element_blank(),
                  axis.line=element_blank(),
                  axis.ticks=element_blank(),
                  plot.margin = margin(0, 0, 0, 50, "pt"),
                  plot.background = element_rect()) +
            geom_text(x=0.6, y=2, hjust=1, size=6, label=TeX("p-value"), color="blue")+
            geom_text(x=0.6, y=1,  hjust=1, size=6, label=TeX("\\hat{A}_{12}"), color="blue")+
            coord_cartesian(xlim=c(1,length(SUBJ_NAMES)), ylim = c(0.5, 2.5), clip = "off")
    }
    
    # output both graphs
    to_print<-grid.arrange(g, g2, nrow=2, heights = c(4, 1))
    outputName <- sprintf("%s/rq1_probability_compare.pdf", OUTPUT_PATH)
    ggsave(outputName, to_print, width=6, height=5)
}