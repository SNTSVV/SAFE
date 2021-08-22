# load library
cat("loading conf.R...\n")

######################################################
# Load libraries
######################################################
suppressMessages(library(ggplot2))
suppressMessages(library(stringr))
suppressMessages(library(tools))
suppressMessages(library(progress))

######################################################
# task functions
######################################################
load_taskInfo <- function(filename, timeQuanta){
    info <- read.csv(file=filename, header = TRUE)
    colnames(info)<- c("ID", "NAME", "TYPE", "PRIORITY", "OFFSET", "WCET.MIN", "WCET.MAX", "PERIOD", "INTER.MIN", "INTER.MAX", "DEADLINE", "DEADLINE.TYPE")#,"RESULT.MIN", "RESULT.MAX")
    info$WCET.MIN   <- as.integer(round(info$WCET.MIN/timeQuanta))
    info$WCET.MAX   <- as.integer(round(info$WCET.MAX/timeQuanta))
    info$PERIOD     <- as.integer(round(info$PERIOD/timeQuanta))
    info$INTER.MIN  <- as.integer(round(info$INTER.MIN/timeQuanta))
    info$INTER.MAX  <- as.integer(round(info$INTER.MAX/timeQuanta))
    info$DEADLINE   <- as.integer(round(info$DEADLINE/timeQuanta))
    return (info)
}

parsingParameters <- function(filepath) {
    params<-list()
    con <- file(filepath, "r")
    while ( TRUE ) {
        line <- readLines(con, n = 1)
        if ( length(line) == 0 ) {
            break
        }
        strs <- strsplit(line, ":")
        result<-strs[[1]]
        if (length(result)<=1){
            next
        }
        name <- str_trim(result[1])
        valueT <- str_trim(str_replace_all(result[2], "\"", ""))
        valueI <- as.integer(valueT)
        valueD <- as.double(valueT)
        if (is.na(valueI)==TRUE && is.na(valueD)==TRUE){
            value <- valueT
            # value <- ifelse(is.na(as.double(valueT))==TRUE, valueT, as.double(valueT))
        } else{
            value <- ifelse(valueI!=valueD, valueD, valueI)
        }
        if (tolower(value)=="false") value <- FALSE
        if (tolower(value)=="true") value <- TRUE
        params[[name]] <- value
    }
    close(con)
    return(params)
}

######################################################
# drawing functions
######################################################

##########################################
# define functions
##########################################
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
draw_timeline<- function(outputfile, schedules, priorities,
                         taskInfo, timeUNIT=1,
                         Step=2000, thickBar=1, thickEnd=0.05, thickTime=0.15, thickWait=0.3,
                         middleText=TRUE, addTaskNum=TRUE,
                         startTime=NULL, maxTime=NULL, MaxGraphs=100){
    # for showing all tasks on the timeline
    if (addTaskNum == TRUE){
        taskNames <- sprintf("T%02d: %s", c(1:nrow(taskInfo)), taskInfo$NAME)
    } else {
        taskNames <- as.character(taskInfo$NAME)
    }
    idNames <- sprintf("%d",priorities)
    names(taskNames) <- idNames
    
    # Set dummy data for drawing
    fixed_data <- data.frame(
        Task=taskNames,
        TaskID=c(1:nrow(taskInfo)),
        ExecutionID=rep(-1, nrow(taskInfo)),
        Type=rep('Arrival', nrow(taskInfo)),
        Started=rep(-1, nrow(taskInfo)),
        Finished=rep(-1, nrow(taskInfo)),
        Priority=priorities
    )
    execs_fixed <- data.frame(TaskID=0, ExecutionID=-1, Type='Execution', Started=-1000, Finished=-1000, Priority=1, CPU=c(-1, unique(schedules$CPU)))
    
    # SET FILENAME
    ext <- file_ext(outputfile)
    if (str_length(ext)!=0){
        idx <- str_length(outputfile) - (str_length(ext)+1)
        prefix <- str_sub(outputfile, 0, idx)
    }else{
        prefix <- outputfile
        ext <- "pdf"
    }
    
    # setting start, max timeline, and number of graphs
    Start<-ifelse(is.null(startTime)==TRUE, 0, startTime)
    MaxSchedules <- ifelse(is.null(maxTime), max(schedules$Finished), maxTime)
    cntGraphs <- ceiling((MaxSchedules - Start)/ Step)
    
    # make graph ========================================================================
    OUTPUT_IDX<-1
    cnt <- 0
    pdf(sprintf("%s_part%d.%s",prefix, OUTPUT_IDX, ext), width=14, height=7)
    pb <- progress_bar$new(total = cntGraphs)
    while(Start<MaxSchedules){
        # control saving file (if the number of graphs is over MaxGraphs per file, change OUTPUT_IDX)
        cnt <- cnt + 1
        if (cnt > MaxGraphs){
            dev.off()
            OUTPUT_IDX <- OUTPUT_IDX + 1
            cnt <- 0
            pdf(sprintf("%s_part%d.%s",prefix, OUTPUT_IDX, ext), width=14, height=7)
        }
        
        # draw each graph
        End <- Start + Step
        subsets <- get_inrange_data(schedules, Start, End, Addition=0)
        # if (addTaskNum == TRUE){
        #     subsets <- data.frame(Task=as.factor(sprintf("T%02d: %s",subsets$TaskID, taskInfo$NAME[subsets$TaskID])), subsets)
        # } else {
        #     subsets <- data.frame(Task=taskInfo$NAME[subsets$TaskID], subsets)
        # }
        # subsets <- rbind(subsets, fixed_data)
        subsets$Started <- subsets$Started*timeUNIT
        subsets$Finished <- subsets$Finished*timeUNIT
        missedArrivals <- subsets[subsets$Type=="MissedArrival",]
        arrivals <- subsets[subsets$Type=="Arrival",]
        execs <- subsets[subsets$Type=="Execution",]
        misses <- subsets[subsets$Type=="Missed",]
        ends <- subsets[subsets$Type=="Ended",]
        
        execs <- rbind(execs, execs_fixed)
        
        # draw basic graph
    {
        suppressWarnings(
            g<-ggplot()+
                ylab("")+
                xlab("Timeline (ms)") +
                scale_x_continuous(breaks = seq(Start*timeUNIT, End*timeUNIT, by = as.integer((End-Start)/10*timeUNIT)),
                                   limits = c(Start*timeUNIT,  End*timeUNIT)) +
                geom_point(fixed_data, mapping=aes(x=Started, y=as.factor(Priority)), size=0)+
                scale_y_discrete(drop=FALSE, labels=taskNames) + #, limits =rev(levels(taskNames)))+
                # ggtitle(sprintf("Scheduler executes [%d:%d] (ms)", Start*timeUNIT, End*timeUNIT))+
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
                          xmin=arrivals$Started, xmax=arrivals$Started+(1*timeUNIT)*thickBar,
                          ymin=arrivals$Priority-thickWait, ymax=arrivals$Priority+thickWait,
                          fill="blue", alpha=1, inherit.aes = FALSE) +
                
                geom_rect(arrivals, mapping=aes(x=Started, y=Priority),
                          xmin=arrivals$Finished-(1*timeUNIT)*thickBar, xmax=arrivals$Finished,
                          ymin=arrivals$Priority-thickWait, ymax=arrivals$Priority+thickWait,
                          fill="red", alpha=1, inherit.aes = FALSE)+
                
                geom_rect(missedArrivals, mapping=aes(x=Started, y=Priority),
                          xmin=missedArrivals$Started, xmax=missedArrivals$Started+(1*timeUNIT)*thickBar,
                          ymin=missedArrivals$Priority-thickWait, ymax=missedArrivals$Priority+thickWait,
                          fill="blue", alpha=1, inherit.aes = FALSE) +
                geom_rect(missedArrivals, mapping=aes(x=Started, y=Priority),
                          xmin=missedArrivals$Finished-(1*timeUNIT)*thickBar, xmax=missedArrivals$Finished,
                          ymin=missedArrivals$Priority-thickWait, ymax=missedArrivals$Priority+thickWait,
                          fill="red", alpha=1, inherit.aes = FALSE) +
                
                geom_rect(ends, mapping=aes(x=Started, y=Priority),
                          xmin=ends$Finished-(3*timeUNIT)*thickBar, xmax=ends$Finished,
                          ymin=ends$Priority-thickEnd, ymax=ends$Priority+thickEnd,
                          fill="black", alpha=1, inherit.aes = FALSE)
        )
    }
        for (x in 1:length(taskNames)){
            item <- fixed_data[x,]
            text <- ifelse(addTaskNum==TRUE, sprintf("T%02d",x), taskNames[x])
            if (middleText==TRUE)
                g <- g + annotate("text", x = (Start + Step/2)*timeUNIT, y = item$Priority , label = text, color="#222222",size=3, hjust=-0.5, vjust=0.5)
            g <- g + annotate("text", x = (Start + Step)*timeUNIT, y = item$Priority , label = text, color="#222222",size=3, hjust=-0.5, vjust=0.5)
        }
        
        # output to file
        plot(g)
        Start <- End    # move start time to the current end time
        pb$tick()
    }
    dev.off()
}

