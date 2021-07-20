# last_updated: 2020-02-09
# authors: Jaekwon Lee
# Visualizing deadline miss
#
PROJECT_PATH = "~/projects/RTA_SAFE"
CODE_PATH <- sprintf("%s/scripts/schedule", PROJECT_PATH)
setwd(CODE_PATH)
source("Exp-common.R")
source("conf.R")
library(MASS)
library(dplyr)
library(MLmetrics)
library(effsize)
library(plotROC)
library(rjson)
setwd(CODE_PATH)

options(warn=0)
########################################################
# Settings
########################################################
subj <- 'HPSS_test2'
runID <- 0
solID <- 0
testNum <- 0
GraphTimeUnit <-200
BASE_PATH <- sprintf('%s/results/%s', PROJECT_PATH, subj)

# load task and settings
settings <- parsingParameters(sprintf("%s/settings.txt",BASE_PATH))
TASK_INFO<- load_taskInfo(sprintf("%s/input.csv",BASE_PATH), settings$TIME_QUANTA)
UNIT <- settings$TIME_QUANTA
GraphTimeUnit <- GraphTimeUnit * (1/settings$TIME_QUANTA)
UNIT<-1

# path settings
PriorityNameFormat <- "%s/sol%d.json"#"%s/priority_%d_num%d.json"
ScheduleNameFormat <- '%s/intermediate_%d.csv'
PRIORITY_PATH <- sprintf('%s/_priorities', BASE_PATH)
INPUT_PATH <- sprintf('%s/draws', BASE_PATH)
OUTPUT_PATH <- sprintf('%s/draws', BASE_PATH)  # RESULT_PATH


load_intermediate_data <- function(immediatefile, schedulefile, priorities, FORCE=FALSE){
    if (FORCE == TRUE | file.exists(immediatefile)==FALSE){
        cat(sprintf("converting schedule data from", schedulefile))
        data <- convert_data(fromJSON(file=schedulefile), priorities)
        if (file.exists(INPUT_PATH)==FALSE){
            dir.create(INPUT_PATH)
        }
        write.table(data, immediatefile, append = FALSE, sep = ",", dec = ".",row.names = FALSE, col.names = TRUE)
    } else {
        cat(sprintf("loading from %s....",immediatefile))
        data <- read.csv(immediatefile, header=TRUE)
    }
    cat("Done!\n")
    return (data)
}
get_higher_data <- function(baseData, item){
    df <- baseData[(baseData$TaskID<item$TaskID),]
    subdata <- df[(item$Started<df$Finished & df$Finished<=item$Finished),]
    subdata <- rbind(subdata, df[(item$Started<=df$Started & df$Started<item$Finished & df$Finished>item$Finished),])
    subdata <- rbind(subdata, df[(df$Started<item$Started & item$Finished<df$Finished),])
    subdata <- subdata[order(subdata$Started),]    
    return (subdata)    
}
get_inrange_data <- function(df, Started, Ended, orderColumn=NULL, Addition=TRUE){
    # if(Addition==TRUE){
    #     gap <- as.integer((Ended-Started))
    #     if(Started!=0) Started <- Started - gap
    #     Ended <- Ended + gap
    # }
    
    subdata <- df[(Started<df$Finished & df$Finished<=Ended),]
    subdata <- rbind(subdata, df[(Started<=df$Started & df$Started<Ended & df$Finished>Ended),])
    subdata <- rbind(subdata, df[(df$Started<Started & Ended<df$Finished),])
    if (is.null(orderColumn)==FALSE)
        subdata <- subdata[order(subdata[[orderColumn]]),]    
    return (subdata)    
}
draw_timeline<- function(outputfile, schedules, priorities, Step=2000, thickBar=1, thickEnd=0.05, thickTime=0.15, thickWait=0.3, middleText=TRUE, addTaskNum=TRUE, startTime=NULL, maxTime=NULL, MaxGraphs=100){
    # for showing all tasks on the timeline
    if (addTaskNum == TRUE){
        taskNames <- sprintf("T%02d: %s", c(1:nrow(TASK_INFO)), TASK_INFO$NAME)
    } else {
        taskNames <- as.character(TASK_INFO$NAME)
    }
    idNames <- sprintf("%d",priorities)
    names(taskNames) <- idNames
    
    fixed_data <- data.frame(
        Task=taskNames,
        TaskID=c(1:nrow(TASK_INFO)),
        ExecutionID=rep(-1, nrow(TASK_INFO)),
        Type=rep('Arrival', nrow(TASK_INFO)),
        Started=rep(-1, nrow(TASK_INFO)),
        Finished=rep(-1, nrow(TASK_INFO)),
        Priority=priorities
    )
    execs_fixed <- data.frame(TaskID=0, ExecutionID=-1, Type='Execution', Started=-1000, Finished=-1000, Priority=1, CPU=c(-1, unique(schedules$CPU)))

    OUTPUT_IDX<-1
    pdf(sprintf("%s_%d.pdf",outputfile,OUTPUT_IDX), width=14, height=7)
    cnt=0
    # drawing
    Start<-ifelse(is.null(startTime)==TRUE, 0, startTime)
    MaxSchedules <- max(schedules$Finished)
    if (!is.null(maxTime)) MaxSchedules = maxTime
    while(Start<MaxSchedules){
        # showing progress
        dot <- (Start/Step)%%10
        if(dot==0){
            val = (Start/Step)%/%10
            if (val%%100==0){
                cat(sprintf("\n%d:",Start))
            }
            else if (val%%10==0){ cat("|") }
            else if(val%%5==0){ cat(",") }
            else{ cat(".") }
        }
        # control saving file
        cnt <- cnt + 1
        if (cnt>MaxGraphs){
            dev.off()
            OUTPUT_IDX <- OUTPUT_IDX+1
            cnt <- 0
            pdf(sprintf("%s_%d.pdf",outputfile, OUTPUT_IDX), width=14, height=7)
        }
        
        End <- Start + Step

        subsets <- get_inrange_data(schedules, Start, End, Addition=0)
        # if (addTaskNum == TRUE){
        #     subsets <- data.frame(Task=as.factor(sprintf("T%02d: %s",subsets$TaskID, TASK_INFO$NAME[subsets$TaskID])), subsets)
        # } else {
        #     subsets <- data.frame(Task=TASK_INFO$NAME[subsets$TaskID], subsets)
        # }
        # subsets <- rbind(subsets, fixed_data)
        subsets$Started <- subsets$Started*UNIT
        subsets$Finished <- subsets$Finished*UNIT
        missedArrivals <- subsets[subsets$Type=="MissedArrival",]
        arrivals <- subsets[subsets$Type=="Arrival",]
        execs <- subsets[subsets$Type=="Execution",]
        misses <- subsets[subsets$Type=="Missed",]
        ends <- subsets[subsets$Type=="Ended",]
        
        execs <- rbind(execs, execs_fixed)
        
        # draw basic graph
        suppressWarnings(
            g<-ggplot()+
                ylab("")+
                xlab("Timeline (ms)") +
                scale_x_continuous(breaks = seq(Start*UNIT, End*UNIT, by = as.integer((End-Start)/10)), 
                                   limits = c(Start*UNIT,  End*UNIT)) +
                geom_point(fixed_data, mapping=aes(x=Started, y=as.factor(Priority)), size=0)+
                scale_y_discrete(drop=FALSE, labels=taskNames) + #, limits =rev(levels(taskNames)))+
                # ggtitle(sprintf("Scheduler executes [%d:%d] (ms)", Start*UNIT, End*UNIT))+
                # theme(legend.justification=c(1,0), legend.position=c(1, 0), legend.title=element_blank(), plot.title=element_text(hjust = 0.5))+
                theme(legend.position="none")+
                geom_rect(arrivals, mapping=aes(x=Started, y=Priority), 
                          xmin=arrivals$Started, xmax=arrivals$Finished, 
                          ymin=arrivals$Priority-thickWait, ymax=arrivals$Priority+thickWait, 
                          fill="black", alpha=0.15, inherit.aes = FALSE) +
                
                geom_rect(missedArrivals, mapping=aes(x=Started, y=Priority), 
                          xmin=missedArrivals$Started, xmax=missedArrivals$Finished, 
                          ymin=missedArrivals$Priority-thickWait, ymax=missedArrivals$Priority+thickWait, 
                          fill="red", alpha=0.15, inherit.aes = FALSE) +
                geom_rect(execs, mapping=aes(x=Started, y=Priority, fill=as.factor(CPU)),
                          xmin=execs$Started, xmax=execs$Finished,
                          ymin=execs$Priority-thickTime, ymax=execs$Priority+thickTime,
                          alpha=0.8, inherit.aes = FALSE)+  #fill="green", alpha=0.8, 
                scale_fill_manual(values = c("#555555", "royalblue", "green", "orange", "blue", "violet", "wheat")) + 
                geom_rect(misses, mapping=aes(x=Started, y=Priority),
                          xmin=misses$Started, xmax=misses$Finished,
                          ymin=misses$Priority-thickWait, ymax=misses$Priority+thickWait,
                          # color="red", size=2, alpha=1, inherit.aes = FALSE)+
                          fill="red", alpha=0.5, inherit.aes = FALSE)+
                geom_rect(misses, mapping=aes(x=Started, y=Priority, fill=as.factor(CPU)),
                          xmin=misses$Started, xmax=misses$Finished,
                          ymin=misses$Priority-thickTime, ymax=misses$Priority+thickTime,
                          alpha=0.8, inherit.aes = FALSE)+  #fill="green", alpha=0.8, 
                
                geom_rect(arrivals, mapping=aes(x=Started, y=Priority),
                          xmin=arrivals$Started, xmax=arrivals$Started+(1*UNIT)*thickBar,
                          ymin=arrivals$Priority-thickWait, ymax=arrivals$Priority+thickWait,
                          fill="blue", alpha=1, inherit.aes = FALSE) +
                
                geom_rect(arrivals, mapping=aes(x=Started, y=Priority),
                          xmin=arrivals$Finished-(1*UNIT)*thickBar, xmax=arrivals$Finished,
                          ymin=arrivals$Priority-thickWait, ymax=arrivals$Priority+thickWait,
                          fill="red", alpha=1, inherit.aes = FALSE)+
                
                geom_rect(missedArrivals, mapping=aes(x=Started, y=Priority), 
                          xmin=missedArrivals$Started, xmax=missedArrivals$Started+(1*UNIT)*thickBar,
                          ymin=missedArrivals$Priority-thickWait, ymax=missedArrivals$Priority+thickWait, 
                          fill="blue", alpha=1, inherit.aes = FALSE) +
                geom_rect(missedArrivals, mapping=aes(x=Started, y=Priority), 
                          xmin=missedArrivals$Finished-(1*UNIT)*thickBar, xmax=missedArrivals$Finished, 
                          ymin=missedArrivals$Priority-thickWait, ymax=missedArrivals$Priority+thickWait, 
                          fill="red", alpha=1, inherit.aes = FALSE) +
                
                geom_rect(ends, mapping=aes(x=Started, y=Priority),
                          xmin=ends$Finished-(3*UNIT)*thickBar, xmax=ends$Finished,
                          ymin=ends$Priority-thickEnd, ymax=ends$Priority+thickEnd,
                          fill="black", alpha=1, inherit.aes = FALSE)
        )
        for (x in 1:length(taskNames)){
            item <- fixed_data[x,]
            text <- ifelse(addTaskNum==TRUE, sprintf("T%02d",x), taskNames[x])
            if (middleText==TRUE)
                g <- g + annotate("text", x = (Start + Step/2)*UNIT, y = item$Priority , label = text, color="#222222",size=3, hjust=-0.5, vjust=0.5)
            g <- g + annotate("text", x = (Start + Step)*UNIT, y = item$Priority , label = text, color="#222222",size=3, hjust=-0.5, vjust=0.5)
        }
        plot(g)
        # result[[length(result)+1]] <- g
        Start <- End
    }
    dev.off()
}

{   
    # load priorities
    sourcefile <- sprintf(PriorityNameFormat, PRIORITY_PATH, solID)
    priorities <- fromJSON(file=sourcefile) + 1  # make priority level to start from 1
    
    # schedule intermideate file load
    sourcefile <- sprintf(ScheduleNameFormat, INPUT_PATH, solID, testNum)
    data <- data <- read.csv(sourcefile, header=TRUE)

    cat(sprintf("[Solution%d_Num%d] generating graph", solID, testNum))
    outputfile <- sprintf('%s/timeline_%s_%s_%d_num%d', OUTPUT_PATH, subj, runID, solID, testNum)
    # glist<-draw_timeline(data, priorities, Step=GraphTimeUnit, thickBar=0.1, addTaskNum = FALSE, maxTime=3000)
    draw_timeline(outputfile, data, priorities, Step=GraphTimeUnit, thickBar=0.1, addTaskNum = TRUE, MaxGraphs=50)
    cat("Done\n")
}

