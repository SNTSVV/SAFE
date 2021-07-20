library(ecr)
library(emoa)
library(effsize)
library(progress)
library(ggplot2)
library(scales)  # hue_pal
library(tidyverse)
library(dplyr)
library(latex2exp)
library(grid)


# cbPalette <- c("#000000", "#AAAAAA","#F8766D", "#00BE67", "#C77CFF", "#00A9FF", "#ABA300")  #c("#000000", "#AAAAAA", "#009E73", "#D55E00", "#0072B2", "#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442",   "#CC79A7")#00BFC4
cbPalette <- c("#000000", "#AAAAAA","#F8766D", "#00BE67", "#C77CFF", "#00A9FF")  #c("#000000", "#AAAAAA", "#009E73", "#D55E00", "#0072B2", "#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442",   "#CC79A7")#00BFC4

load_multi_data<-function(basepath, phaseText=NULL, cycleFilter=NULL){
    filelist <- list.dirs(basepath, full.names=FALSE, recursive=FALSE)
    if (length(filelist)==0) stop(sprintf("cannot find files in %s", basepath))
    result <-data.frame()
    for (runName in filelist){
        runID<- as.integer(substr(runName, 4,5))
        if (is.numeric(phaseText)==FALSE){
            datafile <- sprintf("%s/%s/_fitness/fitness_%s.csv", basepath, runName, phaseText)
            data <- read.csv(datafile, header=TRUE, sep = ",", row.names=NULL)
        }else{
            datafile <- sprintf("%s/%s/_fitness/fitness_phase%d.csv", basepath, runName, phaseText)
            data <- read.csv(datafile, header=TRUE, sep = ",", row.names=NULL)
            data$Cycle <- data$Iteration
            data <- data[data$Rank==0,]
        }
        # cat(sprintf("loaded %s..\n",datafile))
        if (is.null(cycleFilter)==FALSE){
            data<-data[data$Cycle==cycleFilter,]
        }
        result<-rbind(result, data.frame(Run=runID, data))
    }
    return (result)
}


generate_box_plot <- function(sample_points, x_col, y_col, type_col, x.title="", y.title="", nBox=20, 
                              title="", ylimit=NULL, colorList=NULL, legend="rb", limY=NULL,
                              legend_direct="vertical", legend_font=15,  trans=NULL, avg=FALSE){
    
    # Draw them for each
    avg_results<- aggregate(sample_points[[y_col]], list(a=sample_points[[x_col]], b=sample_points[[type_col]]), mean)
    colnames(avg_results) <- c(x_col, type_col, y_col)
    
    # change for drawing
    maxX = max(sample_points[[x_col]])
    interval = as.integer(maxX/nBox)
    samples <- sample_points[(sample_points[[x_col]]%%interval==0),]
    avgs <- avg_results[(avg_results[[x_col]]%%interval==0),]
    
    if(is.null(colorList)==TRUE){
        colorList = cbPalette 
    }
    fmt_dcimals <- function(digits=0){
        # return a function responpsible for formatting the 
        # axis labels with a given number of decimals 
        function(x) {
            if (x>10000){
                a <- sprintf("%e", round(x, digits))
            }
            else{
                a <- sprintf(sprintf("%%.%df", digits), round(x,digits))
            }
            return (a)
        }
    }
    g <- ggplot(data=samples, aes(x=as.factor(samples[[x_col]]), y=samples[[y_col]], color=as.factor(samples[[type_col]]))) +  #, linetype=as.factor(Type)
        stat_boxplot(geom = "errorbar", width = 0.7, alpha=1, size=0.7) +
        stat_boxplot(geom = "boxplot", width = 0.7, alpha=1, size=0.7, outlier.shape=1, outlier.size=1) +
        # geom_line(data=avgs, aes(x=as.factor(avgs[[x_col]]), y=avgs[[y_col]], color=as.factor(samples[[type_col]])), size=1, alpha=1)+ #, group=as.factor(samples[[type_col]])
        theme_bw() +
        scale_colour_manual(values=colorList)+
        xlab(x.title) +
        ylab(y.title) +
        # scale_y_continuous()
        # scale_y_continuous(labels = fmt_dcimals(digits=2)) + 
        theme(axis.text=element_text(size=legend_font), axis.title=element_text(size=15))#,face="bold"
    
    if (!is.null(trans)){
        g<- g+ scale_y_continuous(trans=trans)
    }
    
    if (is.null(limY)==FALSE){
        g<- g + ylim(limY[1], limY[2])
    }
    
    if (legend=="rb"){
        g<- g+ theme(legend.justification=c(1,0), legend.position=c(0.999, 0.001), legend.direction = legend_direct, legend.title=element_blank(), legend.text = element_text(size=legend_font), legend.background = element_rect(colour = "black", size=0.2))
    }else if (legend=="rt"){
        g<- g+ theme(legend.justification=c(1,1), legend.position=c(0.999, 0.999), legend.direction = legend_direct, legend.title=element_blank(), legend.text = element_text(size=legend_font), legend.background = element_rect(colour = "black", size=0.2))
    } else if (legend=="lt"){
        g<- g+ theme(legend.justification=c(0,1), legend.position=c(0.001, 0.999), legend.direction = legend_direct, legend.title=element_blank(), legend.text = element_text(size=legend_font), legend.background = element_rect(colour = "black", size=0.2))
    } else if (legend=="lb"){
        g<- g+ theme(legend.justification=c(0,0), legend.position=c(0.001, 0.001), legend.direction = legend_direct, legend.title=element_blank(), legend.text = element_text(size=legend_font), legend.background = element_rect(colour = "black", size=0.2))
    } else{
        g<- g+ theme(legend.position = "none")
    }
    
    if (!is.null(ylimit)){
        g <- g + ylim(ylimit[[1]], ylimit[[2]])
    }    
    if (title!=""){
        g <- g + ggtitle(title)
    }
    return (g)
}



draw_scatter_simple<-function(dataset, xlimit=NULL, ylimit=NULL, x_scale=NULL, xPos=1.2, 
                              colorSet=NULL, sizeSet=NULL, alphaLevel=NULL,shapeList=NULL,
                              legend="rt", font_size=15, legend_direct="vertical"
                              ){
    # get range
    if (is.null(xlimit)){
        xMin <- max(dataset$Schedulability)
        xMax <- min(dataset$Schedulability)
    }
    else{
        xMin <- xlimit[[1]]
        xMax <- xlimit[[2]]
    }
    if (is.null(ylimit)){
        yMin <- max(dataset$Satisfaction)
        yMax <- min(dataset$Satisfaction)
    }
    else{
        yMin <- max(ylimit)
        yMax <- min(ylimit)
    }
    colorPalette <- c("black", "red", "blue")
    if (!is.null(colorSet)) colorPalette <- colorSet
    sizeLevel <- c(1,2,3,4)
    if (!is.null(sizeSet)) sizeLevel <- sizeSet
    shapeLevel <- c(4,16,2,5)
    if (!is.null(shapeList)) shapeLevel <- shapeList
    
    
    g <- ggplot()+
        xlab(TeX('Fitness: safety margins ($fs$)')) +
        ylab(TeX('Fitness: constraints ($fc$)')) +
        xlim(xMin, xMax) +
        ylim(yMin, yMax) +
        # ggtitle("Fitness Behavior of Phase 1")+
        theme_bw() +
        theme(axis.text=element_text(size=font_size),#, face="bold"), 
              axis.title=element_text(size=font_size),#, face="bold"), 
              legend.position="none",
              plot.margin=margin(5, 5, 5, 5)) +
        scale_color_manual(values = colorPalette) +  # set deadline miss color palette
        scale_size_manual(values=sizeLevel)+
        scale_shape_manual(values=shapeLevel)

    if (!is.null(alphaLevel)){
        g <- g+ geom_point(dataset, mapping=aes(x=Schedulability, y=Satisfaction, color=Approach, size=Approach, alpha=Approach, shape=Approach))+
                scale_alpha_manual(values=alphaLevel, guide=F)
    }else{
        g <- g+ geom_point(dataset, mapping=aes(x=Schedulability, y=Satisfaction, color=Approach, size=Approach, shape=Approach))
    }
    
    if (is.null(x_scale)==FALSE){
        g<- g + scale_x_continuous(trans = x_scale, limits=c(xMin, xMax), labels=trans_format(x_scale, math_format(10^.x)))
    }
    g <- g + theme(
        legend.key.size = unit(0.5, "cm"),
        legend.key.width = unit(0.5,"cm"),
        legend.direction = legend_direct, 
        legend.title=element_blank(), 
        legend.text = element_text(size=font_size), #, face="bold"), 
        legend.background = element_rect(colour = "black", size=0.2)
    )
    
    if (legend=="rb"){
        g<- g+ theme(legend.margin = margin(0,5,3,3), legend.justification=c(1,0), legend.position=c(0.999, 0.001))
    }else if (legend=="rt"){
        g<- g+ theme(legend.margin = margin(0,5,5,3), legend.justification=c(1,1), legend.position=c(0.999, 0.999))
    } else if (legend=="lt"){
        g<- g+ theme(legend.margin = margin(0,0,0,0), legend.justification=c(0,1), legend.position=c(0.001, 0.999))
    } else if (legend=="lb"){
        g<- g+ theme(legend.margin = margin(0,0,0,0), legend.justification=c(0,0), legend.position=c(0.001, 0.001))
    } else{
        g<- g+ theme(legend.position = "none")
    }
    
    return(g)
}


meanfilter<-function(x){
    t=data.frame(x)
    x<-c(t[is.nan(t$x)==FALSE,])
    if (length(x)==0) return (NaN)
    return (mean(x))
}

# generate_calculated_data <- function(subject, approaches, item_func, isFORCE=FALSE, testCycle=NULL, RUNS=50, phase=0){
#     cals <-data.frame()
#     output <- sprintf('%s/%s.csv', WORKGROUP, subject)
#     if (file.exists(output)==TRUE && isFORCE==FALSE){
#         cals <- read.csv(output, header=TRUE, sep = ",", row.names=NULL)
#         return (cals)
#     }
#     
#     refPoint <- NULL
#     for (appr in approaches){
#         
#         BASE_PATH <- sprintf('%s/%s_%s_C1000_Adaptive10', WORKGROUP, subject, appr)
#         data <- load_multi_data(BASE_PATH, phase, ifelse(phase==0, "external", NULL))
#         runs <- unique(data$Run)
#         if (length(runs)!=RUNS){
#             cat(sprintf("[%s] %s does not have all results of runs: ", subject, appr))
#             for(rID in c(1:RUNS)){
#                 if (rID %in% runs) next
#                 cat (sprintf(",%d", rID))
#             }
#             cat("\n")
#         }
#         
#         if (is.null(refPoint)){
#             cat(sprintf("[%s] %s, SET a new refPoint\n", subject, appr))
#             refX <- min(data$Schedulability)
#             refY <- max(data$Satisfaction)
#             refPoint <- matrix(c(refX, refY))
#         }
#         
#         maxCycle <- ifelse(is.null(testCycle)==TRUE, max(data$Cycle), testCycle)
#         maxRun<-max(data$Run)
#         
#         pb <- progress_bar$new(format = sprintf("[%s] Calculating distances for %s [:bar] :percent Elapsed: :elapsed", subj, appr),
#                                total = maxRun * (maxCycle+1), clear = FALSE)
#         for (cycle in c(0:maxCycle)){
#             
#             for (runID in c(1:maxRun)){
#                 dd<-data[(data$Cycle==cycle & data$Run==runID),]
#                 item <- item_func(cycle, runID, appr, dd, refPoint)
#                 cals<- rbind(cals, item)
#                 pb$tick()
#             }
#         }
#         # pb$terminate()
#     } # for APPROACHES
#     write.table(cals, output, sep=",", row.names=FALSE)
#     return (cals)
# }
# create_data_item <- function(cycle, runID, appr, item, refPoint){
#     matX <- t(matrix(item$Schedulability))
#     matY <- t(matrix(item$Satisfaction))
#     mat <- rbind(matX, matY)
#     
#     gd <- computeGenerationalDistance(mat, refPoint)
#     hv <- computeHV(mat, refPoint)
#     return (data.frame(Approach=appr, Cycle=cycle, Run=runID, GD=gd, HV=hv))
# }

##############################################################################
##############################################################################
##############################################################################
# For comparing the execution time and memory
draw_descrete_box_plot <- function(xdata, ydata, xTitle, yTitle, breaksList=NULL, drawLine=FALSE, font_size=14){
    D <- data.frame(X=xdata, Y=ydata)
    g<-ggplot(D, aes(x=X, y=Y, group=X)) + 
        geom_boxplot()+
        theme_bw()+
        xlab(xTitle)+ylab(yTitle)+
        theme(axis.text=element_text(size=font_size),#, face="bold"), 
              axis.title=element_text(size=font_size),#, face="bold"), 
              legend.position="none",
              plot.margin=margin(5, 5, 5, 5))
    if (is.null(breaksList)==FALSE){
        g <- g+ scale_x_continuous(breaks=breaksList)
    }
    
    if(drawLine == TRUE){
        P <- lm(Y~X, D)
        fx <- function(x){
            return (P$coefficients[2]*x + P$coefficients[1])   
        }
        g <- g + stat_function(fun = fx, color="#AA0000")
    }
    return (g)
}
