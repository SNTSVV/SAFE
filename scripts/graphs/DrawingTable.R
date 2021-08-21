# Title     :
# Usage Example:
# Rscript scripts/graphs/DrawingTable.R results/TOSEM/_analysis/EXP1 ADCS,ICS,UAV

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
# ENV$PARAMS<- c("results/TOSEM/_analysis/EXP1", "ADCS,ICS,UAV")
print(sprintf("WORK_PATH : %s", ENV$BASE))
print(sprintf("FILE      : %s", ENV$FILE))
print(sprintf("CODE_BASE : %s", ENV$CODE_BASE))
print(sprintf("PARAMS    : %s", ENV$PARAMS))

setwd(ENV$CODE_BASE)
suppressMessages(library(dplyr))
suppressMessages(library(effsize))
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
# P2 data load  & best size
###############################################
P2<-data.frame()
bestSizes <- data.frame()
{
    for(subject in SUBJECTS){
        for(approach in APPROACHES){
            filename <- sprintf("%s/P2_%s_%s.csv", BASE_PATH, subject, approach)
    
            subset<-read.csv(filename, header=TRUE)
            subset<-data.frame(Subject=subject, Approach=approach, Run=subset$Run,
                               BestSize=subset$BestSize, nTerms=subset$nTerms, ExecTime=subset$ExecutionTime.s.)
            P2<-rbind(P2, subset)
        }
    }
    P2$Approach<-change_factor_names(P2$Approach, APPROACHES, APPR_NAMES)
    P2$Subject<-change_factor_names(P2$Subject, SUBJECTS, SUBJ_NAMES)
    
    # calculate statistical information
    dt <- data.frame()
    for(subjet in SUBJ_NAMES) {
        item <- P2[P2$Subject==subjet,]
        if (nrow(item)==0) next
        
        ret <- stats_function(item, "BestSize", APPR_NAMES[1], APPR_NAMES[2])
        dt <- rbind(dt, data.frame(Type=c("p-value", "A12"), Subject=subjet, value=c(ret$p, ret$A12), pos=c(2,1)))
    }
    
    for(subject in SUBJ_NAMES) {
        for(approach in APPROACHES){
            
            selected<- P2[P2$Subject==subject & P2$Approach==approach,]
            item <- data.frame(Subject=subject, Approach=approach, avgBest=mean(selected$BestSize),
                               pValue=dt[dt$Subject==subject & dt$Type=='p-value',]$value,
                               A12=dt[dt$Subject==subject & dt$Type=='A12',]$value)
            bestSizes <- rbind(bestSizes, item)
        }
    }
}


###############################################
# P1 Load data and execution time
## All Execution time (phase1 + phase2), randomsearch calculates the calculating best size
###############################################
execTimes <- data.frame()
P1 <- data.frame()
{
    P1 <- load_multi_files(BASE_PATH, SUBJECTS, APPROACHES, "%s/P1_%s_%s.csv")
    P1$Approach<-change_factor_names(P1$Approach, APPROACHES, APPR_NAMES)
    P1$Subject<-change_factor_names(P1$Subject, SUBJECTS, SUBJ_NAMES)
    
    for(subject in SUBJ_NAMES)
    {
        if (nrow(P1[P1$Subject==subject,])==0) next
        
        total <- data.frame()
        for(approach in APPR_NAMES){
            for(runID in P1$Run){
                t1 <- P1[P1$Subject==subject & P1$Approach==approach & P1$Run==runID,]
                t2 <- P2[P2$Subject==subject & P2$Approach==approach & P2$Run==runID,]
                ts <- ifelse(nrow(t1)==0 || nrow(t2)==0, 0, t1$Total.s.+t2$ExecTime)
                item <- data.frame(Subject=subject, Approach=approach, Run=runID, AllTime=ts)
                total <- rbind(total, item)
            }
        }
        
        # calculate statistical information
        ret <- stats_function(total, "AllTime", APPR_NAMES[1], APPR_NAMES[2])
        dt <- data.frame(Type=c("p-value", "A12"), Subject=subject, value=c(ret$p, ret$A12), pos=c(2,1))
    
        for (approach in APPR_NAMES){
            selected <- total[total$Approach==approach,]
            item <- data.frame(Subject=subject, Approach=approach,
                               avgSec=mean(selected$AllTime),
                               avgHour=mean(selected$AllTime)/3600.0,
                               pValue=dt[dt$Type=='p-value',]$value,
                               A12=dt[dt$Type=='A12',]$value)
            execTimes <- rbind(execTimes, item)
        }
    }
}

########################################################################
### draw graph results
########################################################################
# load data
RT <- data.frame()
deadlines <- data.frame()
{
    RT <- load_multi_files(BASE_PATH, SUBJECTS, APPROACHES, "%s/RT_%s_%s.csv")
    
    # dt: create A12, p-value data for each subject
    dt<-data.frame()
    for (subject in SUBJECTS){
        # print(sprintf("[%s]Calculating p-value, A12...", subject))
        ds <- RT[as.character(RT$Subject)==subject,]
        if (nrow(ds)==0)next
        ret <- stats_function(ds, "countDM", APPROACHES[1], APPROACHES[2])
        dt <- rbind(dt, data.frame(Subject=subject, p=ret$p, A12=ret$A12))
    }
    dt <- rbind(data.frame(Type="p-value", Subject=dt$Subject, value=dt$p, pos=2),
                data.frame(Type="A12", Subject=dt$Subject, value=dt$A12, pos=1))
    
    RT$Subject<-change_factor_names(RT$Subject, SUBJECTS, SUBJ_NAMES)
    RT$Approach<-change_factor_names(RT$Approach, APPROACHES, APPR_NAMES)
    dt$Subject <- change_factor_names(dt$Subject, SUBJECTS, SUBJ_NAMES)
    
    # organize
    for (subject in SUBJ_NAMES){
        for (approach in APPR_NAMES){
            selected <- RT[RT$Approach==approach & RT$Subject==subject,]
            item <- data.frame(Subject=subject, Approach=approach,
                               avgDM=mean(selected$countDM),
                               avgSol=mean(selected$numSol),
                               pValue=dt[dt$Subject==subject & dt$Type=='p-value',]$value,
                               A12=dt[dt$Subject==subject & dt$Type=='A12',]$value)
            deadlines <- rbind(deadlines, item)
        }
    }
}

# print bestSize
{
    cat("\t SAFE\t\t\t Baseline\t\t\t p-value\t\t\t A12\t\t \n")
    cat("\t ADCS\t ICS\t UAV\t ADCS\t ICS\t UAV\t ADCS\t ICS\t UAV\t ADCS\t ICS\t UAV\n")
    {
        line <- "Best-size volumes"
        for(approach in APPR_NAMES){
            for(subject in SUBJ_NAMES){
                best <- bestSizes[bestSizes$Subject==subject & bestSizes$Approach==approach,]$avgBest
                line <- sprintf("%s\t %.2e",line, best)
            }
        }
        for(subject in SUBJ_NAMES){
            best <- bestSizes[bestSizes$Subject==subject & bestSizes$Approach==approach,]$pValue
            line <- sprintf("%s\t %.4f",line, best)
        }
        for(subject in SUBJ_NAMES){
            best <- bestSizes[bestSizes$Subject==subject & bestSizes$Approach==approach,]$A12
            line <- sprintf("%s\t %.4f",line, best)
        }
        cat(line)
    
    }
        cat('\n')
    {
        line <- "Deadline misses"
        for(approach in APPR_NAMES){
            for(subject in SUBJ_NAMES){
                value <- deadlines[deadlines$Subject==subject & deadlines$Approach==approach,]$avgDM
                line <- sprintf("%s\t %.2f",line, value)
            }
        }
        for(subject in SUBJ_NAMES){
            value <- deadlines[deadlines$Subject==subject & deadlines$Approach==approach,]$pValue
            line <- sprintf("%s\t %.4f",line, value)
        }
        for(subject in SUBJ_NAMES){
            value <- deadlines[deadlines$Subject==subject & deadlines$Approach==approach,]$A12
            line <- sprintf("%s\t %.4f",line, value)
        }
        cat(line)
    }
        cat('\n')
    {
        line <- "Execution times"
        for(approach in APPR_NAMES){
            for(subject in SUBJ_NAMES){
                value <- execTimes[execTimes$Subject==subject & execTimes$Approach==approach,]$avgHour
                line <- sprintf("%s\t %.2f",line, value)
            }
        }
        for(subject in SUBJ_NAMES){
            value <- execTimes[execTimes$Subject==subject & execTimes$Approach==approach,]$pValue
            line <- sprintf("%s\t %.4f",line, value)
        }
        for(subject in SUBJ_NAMES){
            value <- execTimes[execTimes$Subject==subject & execTimes$Approach==approach,]$A12
            line <- sprintf("%s\t %.4f",line, value)
        }
        cat(line)
    }
        cat('\n')
}
# print(bestSizes)
# print(deadlines)
# print(execTimes)
