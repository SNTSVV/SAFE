# Title     : TODO
# Usage Example:
# Rscript scripts/graphs/DrawingRoundTrip.R results/TOSEM/_analysis/EXP1 ADCS,ICS,UAV

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
# ENV$PARAMS<- c("results/TOSEM/_analysis/EXP1", "ADCS,ICS,UAV")
print(sprintf("WORK_PATH : %s", ENV$BASE))
print(sprintf("FILE      : %s", ENV$FILE))
print(sprintf("CODE_BASE : %s", ENV$CODE_BASE))
print(sprintf("PARAMS    : %s", ENV$PARAMS))

setwd(ENV$CODE_BASE)
suppressMessages(library(ggplot2))
suppressMessages(library(dplyr))
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

########################################################################
### draw graph results
########################################################################
# load data
{
    data <- load_multi_files(BASE_PATH, SUBJECTS, APPROACHES, "%s/RT_%s_%s.csv")
    
    # dt: create A12, p-value data for each subject
    dt<-data.frame()
    for (subject in SUBJECTS){
        print(sprintf("[%s]Calculating p-value, A12...", subject))
        ds <- data[as.character(data$Subject)==subject,]
        if (nrow(ds)==0)next
        ret <- stats_function(ds, "countDM", APPROACHES[1], APPROACHES[2])
        dt <- rbind(dt, data.frame(Subject=subject, p=ret$p, A12=ret$A12))
    }
    dt <- rbind(data.frame(Type="p-value", Subject=dt$Subject, value=dt$p, pos=2),
                data.frame(Type="A12", Subject=dt$Subject, value=dt$A12, pos=1))
    
    data$Subject<-change_factor_names(data$Subject, SUBJECTS, SUBJ_NAMES)
    data$Approach<-change_factor_names(data$Approach, APPROACHES, APPR_NAMES)
    dt$Subject <- change_factor_names(dt$Subject, SUBJECTS, SUBJ_NAMES)
}
# Draw graph
{
    {
        g <- ggplot(data=data, aes(x=as.factor(.data[["Subject"]]), y=.data[["countDM"]], color=as.factor(.data[["Approach"]]))) +  #, linetype=as.factor(Type)
            stat_boxplot(geom = "errorbar", width = 0.7, alpha=1, size=0.7) +
            stat_boxplot(geom = "boxplot", width = 0.7, alpha=1, size=0.7, outlier.shape=1, outlier.size=1) +
            xlab("")+ ylab("The ratio of deadline misses")+
            scale_color_manual(values=colorPalette)+
            theme_bw()+
            # coord_cartesian(ylim=c(0, 0.010))+
            # scale_y_continuous(trans =  "sqrt")+
            theme(axis.text = element_text(size=20),
                  axis.title.x = element_blank(),
                  axis.title.y = element_blank(), # element_text(face="bold", size=20),
                  legend.direction = "vertical",
                  legend.title=element_blank(),
                  legend.text = element_text(size=20),
                  legend.background = element_rect(colour = "black", size=0.2))
        #g<- g+ theme(legend.justification=c(1,1), legend.position=c(0.999, 0.999))
        g<- g+ theme(legend.justification=c(0,1), legend.position=c(0.001, 0.999))
        # add number of points
        #st1<-data %>% count(Subject,Approach)
        #g <- g+ geom_text(data=st1[as.character(st1$Approach)=="SAFE",], aes(x=as.integer(Subject)-0.15, y=0.01, label=sprintf("%d",n)), hjust=0.5, size=7)
        #g <- g+ geom_text(data=st1[as.character(st1$Approach)=="Baseline",], aes(x=as.integer(Subject)+0.15, y=0.01, label=sprintf("%d",n)), hjust=0.5, size=7)
    }
    # draw for the statistical information
    {
        g2 <- ggplot(dt) +
              geom_text(aes(x=as.factor(Subject), y=pos, label=sprintf("%.4f",value)),
                        color="blue", size=6)+
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
    to_print<-grid.arrange(g, g2, nrow=2, heights = c(5, 1))
    outputName <- sprintf("%s/rq1_roundtrip.pdf", OUTPUT_PATH)
    ggsave(outputName, to_print, width=7, height=6)

    # statistics
    for (subj in SUBJ_NAMES){
      avgCountDM1 <- mean(data[data$Approach==APPR_NAMES[1] & data$Subject==subj,]$countDM)
      avgCountALL1 <- mean(data[data$Approach==APPR_NAMES[1] & data$Subject==subj,]$numSol)
      avgCountDM2 <- mean(data[data$Approach==APPR_NAMES[2] & data$Subject==subj,]$countDM)
      avgCountALL2 <- mean(data[data$Approach==APPR_NAMES[2] & data$Subject==subj,]$numSol)
      cat(sprintf("[%5s] Average of %-15s: %10.2f   (all: %10.2f)\n", subj, APPR_NAMES[1], avgCountDM1, avgCountALL1))
      cat(sprintf("[%5s] Average of %-15s: %10.2f   (all: %10.2f)\n", subj, APPR_NAMES[2], avgCountDM2, avgCountALL2))
    }
    print(dt)
}
# Draw histogram of number of deadline missed simulations for each subject
{
  histbar <- data.frame()
  for(subject in SUBJ_NAMES){
    subs<- data[data$Subject==subject,]
    for (appr in APPR_NAMES){
      for (num in unique(subs$countDM)){
        cnt <- nrow(subs[subs$countDM==num & subs$Approach==appr,])
        histbar <- rbind(histbar, data.frame(Subject=subject, Approach=appr, DeadlineMiss=num, Cnt=cnt))
      }
    }
  }
  for(subject in SUBJ_NAMES){
    subs <- histbar[histbar$Subject==subject,]
    g <- ggplot(data=subs,  aes(x=as.factor(.data[["DeadlineMiss"]]), y=.data[["Cnt"]], group=.data[["Approach"]], fill=.data[["Approach"]])) +
      geom_bar(stat='identity', position = 'dodge')+
      xlab("The number of missed deadline")+
      ylab("Count")+
      scale_color_manual(values=colorPalette)+
      theme_bw()+
      scale_y_continuous(limits=c(0, 50))+
      theme(axis.text = element_text(size=15),
            axis.title= element_text(size=15),
            legend.direction = "vertical",
            legend.title=element_blank(),
            legend.text = element_text(size=15),
            legend.background = element_rect(colour = "black", size=0.2))
    g<- g+ theme(legend.justification=c(1,1), legend.position=c(0.999, 0.999))
    print(g)
    outputName <- sprintf("%s/rq1_roundtrip_%s.pdf", OUTPUT_PATH, subject)
    ggsave(outputName, g, width=12, height=4)
  }
}

########################################################################
### draw graph results (nTasks)
########################################################################
# load data
{
    data <- load_multi_files(BASE_PATH, SUBJECTS, APPROACHES, "%s/RT_%s_%s.numTask.csv")
    data$Subject<-change_factor_names(data$Subject, SUBJECTS, SUBJ_NAMES)
    data$Approach<-change_factor_names(data$Approach, APPROACHES, APPR_NAMES)
}
# draw graph
{
    maxHeight <- 5
  
    # Draw graph
    g <- ggplot(data=data, aes(x=as.factor(.data[["Subject"]]), y=.data[["numTasks"]], color=as.factor(.data[["Approach"]]))) +  #, linetype=as.factor(Type)
      stat_boxplot(geom = "errorbar", width = 0.7, alpha=1, size=0.7) +
      stat_boxplot(geom = "boxplot", width = 0.7, alpha=1, size=0.7, outlier.shape=1, outlier.size=1) +
      xlab("")+ ylab("# of tasks that missed deadline")+
      scale_color_manual(values=colorPalette)+
      ylim(0,maxHeight)+
      theme_bw()+
      theme(axis.text = element_text(size=20, face="bold"),
            axis.title = element_text(face="bold", size=20),
            legend.justification=c(1,1),
            legend.position=c(0.999, 0.999),
            legend.direction = "vertical",
            legend.title=element_blank(),
            legend.text = element_text(size=20),
            legend.background = element_rect(colour = "black", size=0.2))

    # add number of points
    st1<-data %>% count(Subject,Approach)
    g <- g+ geom_text(data=st1[as.character(st1$Approach)=="SAFE",], aes(x=as.integer(Subject)-0.15, y=0, label=sprintf("%d",n)), hjust=0.5, size=7)
    g <- g+ geom_text(data=st1[as.character(st1$Approach)=="Baseline",], aes(x=as.integer(Subject)+0.15, y=0, label=sprintf("%d",n)), hjust=0.5, size=7)
    print(g)
    outputName <- sprintf("%s/RoundTrip_nMissed_tasks.pdf", OUTPUT_PATH)
    ggsave(outputName, g, width=7, height=7)
}


########################################################################
### draw graph results (nExecs)
########################################################################
{
    data <- load_multi_files(BASE_PATH, SUBJECTS, APPROACHES, "%s/RT_%s_%s.numExecs.csv")
    data$Subject<-change_factor_names(data$Subject, SUBJECTS, SUBJ_NAMES)
    data$Approach<-change_factor_names(data$Approach, APPROACHES, APPR_NAMES)
}
{
    maxHeight <- 5

    # Draw graph
    g <- ggplot(data=data, aes(x=as.factor(.data[["Subject"]]), y=.data[["numExecs"]], color=as.factor(.data[["Approach"]]))) +  #, linetype=as.factor(Type)
      stat_boxplot(geom = "errorbar", width = 0.7, alpha=1, size=0.7) +
      stat_boxplot(geom = "boxplot", width = 0.7, alpha=1, size=0.7, outlier.shape=1, outlier.size=1) +
      xlab("")+ ylab("# of executions that missed deadline")+
      scale_color_manual(values=colorPalette)+
      ylim(0, maxHeight)+
      theme_bw()+
      theme(axis.text = element_text(size=20, face="bold"),
            axis.title = element_text(face="bold", size=20),
            legend.justification=c(1,1),
            legend.position=c(0.999, 0.999),
            legend.direction = "vertical",
            legend.title=element_blank(),
            legend.text = element_text(size=20),
            legend.background = element_rect(colour = "black", size=0.2))

    # add number of points
    st1<-data %>% count(Subject,Approach)
    g <- g+ geom_text(data=st1[as.character(st1$Approach)=="SAFE",], aes(x=as.integer(Subject)-0.15, y=0, label=sprintf("%d",n)), hjust=0.5, size=7)
    g <- g+ geom_text(data=st1[as.character(st1$Approach)=="Baseline",], aes(x=as.integer(Subject)+0.15, y=0, label=sprintf("%d",n)), hjust=0.5, size=7)
    print(g)
    outputName <- sprintf("%s/RoundTrip_nMissed_execution.pdf", OUTPUT_PATH)
    ggsave(outputName, g, width=7, height=7)
}

########################################################################
### draw graph results (sum of deadline miss)
########################################################################
{
    data <- load_multi_files(BASE_PATH, SUBJECTS, APPROACHES, "%s/RT_%s_%s.sumSizeDM.csv")
    data$Subject<-change_factor_names(data$Subject, SUBJECTS, SUBJ_NAMES)
    data$Approach<-change_factor_names(data$Approach, APPROACHES, APPR_NAMES)
}
{
    yLoc<-20000

    # Draw graph
    g <- ggplot(data=data, aes(x=as.factor(.data[["Subject"]]), y=.data[["sumSizeDM"]], color=as.factor(.data[["Approach"]]))) +  #, linetype=as.factor(Type)
        stat_boxplot(geom = "errorbar", width = 0.7, alpha=1, size=0.7) +
        stat_boxplot(geom = "boxplot", width = 0.7, alpha=1, size=0.7, outlier.shape=1, outlier.size=1) +
        xlab("")+ ylab("Sum of the size of deadline misses")+
        scale_color_manual(values=colorPalette)+
        theme_bw()+
        theme(axis.text = element_text(size=20, face="bold"),
              axis.title = element_text(face="bold", size=20),
              legend.justification=c(1,1),
              legend.position=c(0.999, 0.999),
              legend.direction = "vertical",
              legend.title=element_blank(),
              legend.text = element_text(size=20),
              legend.background = element_rect(colour = "black", size=0.2))

    # add number of points
    st1<-data %>% count(Subject,Approach)
    g <- g+ geom_text(data=st1[as.character(st1$Approach)=="SAFE",], aes(x=as.integer(Subject)-0.15, y=yLoc, label=sprintf("%d",n)), hjust=0.5, size=7)
    g <- g+ geom_text(data=st1[as.character(st1$Approach)=="Baseline",], aes(x=as.integer(Subject)+0.15, y=yLoc, label=sprintf("%d",n)), hjust=0.5, size=7)
    print(g)
    outputName <- sprintf("%s/RoundTrip_sizeMissed.pdf", OUTPUT_PATH)
    ggsave(outputName, g, width=7, height=7)
}
