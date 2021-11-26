########################################################
# load dependencies
########################################################
if (Sys.getenv("JAVA_RUN", unset=FALSE)==FALSE) {
    suppressMessages(library(scales))
    suppressMessages(library(ggplot2))
    source("libs/lib_config.R")            # cbPalette
    source("libs/lib_data.R")         # get_task_names
    source("libs/lib_model.R")        # get_intercepts, get_bestsize_point, get_func_points
    source("libs/lib_evaluate.R")     # find_noFPR
    source("libs/lib_sampling.R")
}

########################################################
# Library for drawing
########################################################
if (!Sys.getenv("DEV_LIB_DRAW", unset=FALSE)=="TRUE") {
    Sys.setenv("DEV_LIB_DRAW"=TRUE)
    cat("loading lib_draw.R...\n")
    
    ########################################################
    # drawing functions
    ########################################################
    select_annotate_pos<-function(linePoints, xID, yID, taskInfo)
    {
        if(taskInfo$WCET.MAX[[yID]]>taskInfo$WCET.MAX[[xID]]){
            xpos <- min(linePoints$x)
            ypos <- max(linePoints$y)
        }else{
            xpos <- max(linePoints$x)
            ypos <- min(linePoints$y)
        }
        return (list("x"=xpos, "y"=ypos))
        #if(taskInfo$WCET.MAX[[yID]]>taskInfo$WCET.MAX[[xID]]){
        #    for(i in nrow(linePoints):1){
        #        if (linePoints$x[[i]] <0) break
        #    }
        #    xpos <- 0
        #    ypos <- linePoints$y[[i]]
        #}else{
        #    for(i in 1:nrow(linePoints)){
        #        if (linePoints$y[[i]] <0) break
        #    }
        #    xpos <- linePoints$x[[i]]
        #    ypos <- 0
        #}
        #ret <- list()
        #ret[["x"]] <- xpos
        #ret[["y"]] <- ypos
        #return (ret)
    }
    
    get_WCETspace_plot<- function(
        data, form,
        xID, yID,
        showTraining=TRUE,
        nSamples=0,
        probLines=c(),
        showThreshold=TRUE,
        xlabel=NULL,
        ylabel=NULL,
        title=NULL,
        annotates=c(),
        annotatesLoc=c(),
        showMessage = TRUE,
        showBestPoint = FALSE,
        learnModel=TRUE,
        nNewSamples=0,
        legend="rt",
        reduceRate=1
    )
    {
        
        # Setting basic frame
        if(showMessage) cat(sprintf("Generating WCET space with x(T%d), y(T%d)....\n", xID, yID))
        g <- ggplot() +
            # xlim(0, 20) +
            # ylim(0, 0.9) +
            xlim(0, TASK_INFO$WCET.MAX[[xID]]*UNIT) +
            ylim(0, TASK_INFO$WCET.MAX[[yID]]*UNIT) +
            # xlab(sprintf("%s (T%d)",TASK_INFO$NAME[xID], xID)) +
            # ylab(sprintf("%s (T%d)",TASK_INFO$NAME[yID], yID)) +
            xlab(sprintf("T%d WCET", xID)) +
            ylab(sprintf("T%d WCET", yID)) +
            theme_bw() +
            theme(axis.text=element_text(size=15), axis.title=element_text(size=15))
        
        if(is.null(xlabel)==FALSE) g <- g + xlab(xlabel)
        if(is.null(ylabel)==FALSE) g <- g + ylab(ylabel)
        if (is.null(title)==FALSE) g <- g + ggtitle(title)
        
        if (legend=="rb"){
            g<- g+ theme(legend.justification=c(1,0), legend.position=c(0.999, 0.001),legend.text = element_text(size=15), legend.title=element_blank(), legend.background = element_rect(colour = "black", size=0.2))
        }else if (legend=="rt"){
            g<- g+ theme(legend.justification=c(1,1), legend.position=c(0.999, 0.999), legend.text = element_text(size=15), legend.title=element_blank(), legend.background = element_rect(colour = "black", size=0.2))
        } else if (legend=="lt"){
            g<- g+ theme(legend.justification=c(0,1), legend.position=c(0.001, 0.999), legend.text = element_text(size=15), legend.title=element_blank(), legend.background = element_rect(colour = "black", size=0.2))
        } else if (legend=="lb"){
            g<- g+ theme(legend.justification=c(0,0), legend.position=c(0.001, 0.001), legend.text = element_text(size=15), legend.title=element_blank(), legend.background = element_rect(colour = "black", size=0.2))
        } else{
            g<- g+ theme(legend.position = "none")
        }
        
        uData<-update_data(data, c("No deadline miss", "Deadline miss"))
        if (nNewSamples!=0){
            nCnt <- nrow(uData)
            Pt <- nCnt-nNewSamples + 100
            prev <- uData[1:Pt,]
            newP <- uData[(Pt+1):nCnt,]
            uData <- prev
        }
        
        if (showTraining==TRUE){
            if (reduceRate<1){
                showingData <- sample_n(uData, nrow(uData)*reduceRate)
            }else{
                showingData <- uData
            }
            g <- g +
                geom_point( data=showingData, aes(x=showingData[[sprintf("T%d",xID)]], y=showingData[[sprintf("T%d",yID)]], color=as.factor(labels),shape=as.factor(labels)),  size=1, alpha=1) +
                # scale_colour_manual(values=c(cbPalette[2], cbPalette[1]) )
                scale_colour_manual(values=c("#00A1FF", "#F27200") )+ #c("#00BFC4", "#F8766D") )+
                scale_shape_manual(values = c(1, 25)) # 1, 4
            
        }
        else if (nNewSamples!=0){
            if (showTraining==TRUE){
                g <- g + geom_point( data=prev, aes(x=prev[[sprintf("T%d",xID)]], y=prev[[sprintf("T%d",yID)]]), color='gray', size=1, alpha=0.5)
            }
            g <- g +
                geom_point( data=newP, aes(x=newP[[sprintf("T%d",xID)]], y=newP[[sprintf("T%d",yID)]], color=as.factor(labels)),  size=1, alpha=0.5)+
                scale_colour_manual(values=cbPalette )
        }
        
        if (learnModel==FALSE){
            return (g)
        }
        
        # generate model & find threhold
        if (is.null(form)==FALSE){
            mdx <- glm(formula = form, family = "binomial", data = uData)
            threshold <- find_noFPR(mdx, uData, precise=0.0001)
            # uppper_threshold <- find_noFNR(mdx, uData, precise=0.0001)
        }
        
        # generate sample if user wants
        if (nSamples!=0){
            if(showMessage) cat(sprintf("\tAdding sampling points with %5.2f%% as a threhold ....\n",threshold*100))
            tnames <- get_task_names(uData)
            samples <- sample_based_euclid_distance(tnames, mdx, nSample=nSamples, nCandidate=20, P=threshold)
            g <- g + geom_point( data=samples, aes(x=samples[[sprintf("T%d",xID)]], y=samples[[sprintf("T%d",yID)]]),  size=0.3, alpha=0.5)
        }
        
        # Add probability lines
        if (showThreshold == TRUE) probLines <- c(probLines, threshold)#, uppper_threshold)
        for(prob in probLines){
            if(showMessage) cat(sprintf("\tAdding model line with %5.2f%% ....\n",prob*100))
            
            funcLine <- generate_line_function(mdx, prob, yID, minY=TASK_INFO$WCET.MIN[[yID]]*UNIT, maxY=TASK_INFO$WCET.MAX[[yID]]*UNIT)
            #fx <- get_func_points(funcLine, TASK_INFO$WCET.MIN[[xID]]*UNIT, TASK_INFO$WCET.MAX[[xID]]*UNIT, nPoints=300)
            fx <- get_func_points(funcLine, TASK_INFO, xID, yID, nPoints=300)
            
            lineColor <- ifelse(threshold==prob, "blue", "black")
            
            # add line graph to the g
            if (nrow(fx)!=0){
                pos <- select_annotate_pos(fx, xID, yID, TASK_INFO)
                g<- g +
                    geom_point(data=fx, aes(x=x, y=y), color=lineColor, alpha=0.9, size=1)+
                    annotate("text", x=pos$x, y=pos$y, label = sprintf("P=%.2f%%", prob*100), color=lineColor, size=5, hjust=-0.1, vjust=0.1)
            } else {
                cat(sprintf("\tCannot draw a line with %.2f%% in specified area\n", prob*100))
            }
        }
        
        # Add Annotates
        for (i in 1:length(annotates)){
            xpos <- 0
            ypos <- TASK_INFO$WCET.MAX[yID]*UNIT - (i-1)*0.2
            if (length(annotatesLoc) > i){
                xpos <- annotatesLoc[i][1]
                ypos <- annotatesLoc[i][2]
            }
            g <- g + annotate("text", x = xpos, y = ypos, label = annotates[i], color="blue", size=3, hjust=0, vjust=-1)
        }
        
        if (showBestPoint==TRUE){
            # generate model & find threhold
            mdb <- glm(formula = form, family = "binomial", data = data)
            uncertainIDs <- get_base_names(names(mdb$coefficients), isNum=TRUE)
            bestPoint <- get_bestsize_point(mdb, threshold, targetIDs=uncertainIDs, isGeneral=TRUE)
            bestPoint$X <- bestPoint$X*UNIT
            bestPoint$Y <- bestPoint$Y*UNIT
            bestPoint$Area <- bestPoint$Area*UNIT
            print(bestPoint)
            if (uncertainIDs[1] == yID){
                temp <- bestPoint$X
                bestPoint$X <- bestPoint$Y
                bestPoint$Y <- temp
            }
            
            bestBorder1 <- data.frame(X=c(0, bestPoint$X), Y=c(bestPoint$Y, bestPoint$Y))
            bestBorder2 <- data.frame(X=c(bestPoint$X, bestPoint$X), Y=c(bestPoint$Y, 0))
            bestPoint <- as.data.frame(bestPoint)
            g <- g+
                geom_rect( data=bestPoint, xmin=0, xmax=bestPoint$X, ymin=0, ymax=bestPoint$Y,
                           fill="green", alpha=0.15, inherit.aes = FALSE)+
                geom_line( data=bestBorder1, aes(x=X, y=Y),
                           color="black", alpha=0.7, size=1, inherit.aes = FALSE, linetype="dotted")+
                geom_line( data=bestBorder2, aes(x=X, y=Y),
                           color="black", alpha=0.7, size=1,  inherit.aes = FALSE, linetype="dotted")+
                geom_point( mapping=aes(x=X, y=Y), data=bestPoint, color="black", alpha=0.8, size=2)+
                geom_text( mapping=aes(x=X, y=Y, label="Best-size"),
                           data=bestPoint, color="black", alpha=0.8, size=6, hjust=-0.1,vjust=-0.2)+
                geom_text( mapping=aes(x=0, y=Y, label=sprintf("%.3fs",bestPoint$Y)),
                           data=bestPoint, color="black", alpha=0.8, size=5, hjust=-0.1,vjust=1.3)+
                geom_text( mapping=aes(x=X, y=0, label=sprintf("%.3fs",bestPoint$X)),
                           data=bestPoint, color="black", alpha=0.8, size=5, hjust=1.1,vjust=-0.3)
        }
        
        if(showMessage) cat("Generated graph.\n")
        return (g)
    }
    
    ..add_legend<-function(g, location="none", text_size=15){
        if (location=="rb"){
            g<- g+ theme(legend.justification=c(1,0), legend.position=c(0.999, 0.001),legend.text = element_text(size=text_size), legend.title=element_blank(), legend.background = element_rect(colour = "black", size=0.2))
        }else if (location=="rt"){
            g<- g+ theme(legend.justification=c(1,1), legend.position=c(0.999, 0.999), legend.text = element_text(size=text_size), legend.title=element_blank(), legend.background = element_rect(colour = "black", size=0.2))
        } else if (location=="lt"){
            g<- g+ theme(legend.justification=c(0,1), legend.position=c(0.001, 0.999), legend.text = element_text(size=text_size), legend.title=element_blank(), legend.background = element_rect(colour = "black", size=0.2))
        } else if (location=="lb"){
            g<- g+ theme(legend.justification=c(0,0), legend.position=c(0.001, 0.001), legend.text = element_text(size=text_size), legend.title=element_blank(), legend.background = element_rect(colour = "black", size=0.2))
        } else{
            g<- g+ theme(legend.position = "none")
        }
        return(g)
    }
    
    generate_WCET_scatter <- function(data, taskInfo, xID, yID, labelCol=NULL, legendLoc="none", model.func=NULL,
                                      probability=NULL,
                                      xlabel=NULL, ylabel=NULL, title=NULL, labelColor=NULL, labelShape=NULL){
        
        #drawing
        g <- ggplot()+
            xlim(taskInfo$WCET.MIN[[xID]], taskInfo$WCET.MAX[[xID]]) +
            ylim(taskInfo$WCET.MIN[[yID]], taskInfo$WCET.MAX[[yID]]) +
            xlab(sprintf("T%d WCET", xID)) +
            ylab(sprintf("T%d WCET", yID)) +
            theme_bw() +
            theme(axis.text=element_text(size=15), axis.title=element_text(size=15))
        
        g <- ..add_legend(g, legendLoc, text_size=18)
        if(is.null(xlabel)==FALSE) g <- g + xlab(xlabel)
        if(is.null(ylabel)==FALSE) g <- g + ylab(ylabel)
        if (is.null(title)==FALSE) g <- g + ggtitle(title)
        
        if (is.null(labelCol)){
            g <- g + geom_point(data=data, aes(x=data[[sprintf("T%d", xID)]], y=data[[sprintf("T%d", yID)]]), size=1, alpha=0.7)
        }else{
            g <- g + geom_point(data=data, aes(color=as.factor(data[[labelCol]]),
                                               shape=as.factor(data[[labelCol]]),
                                               x=data[[sprintf("T%d", xID)]],
                                               y=data[[sprintf("T%d", yID)]]), size=1, alpha=1)
        }
        if (is.null(labelColor)==FALSE){ g <- g+ scale_colour_manual(values=labelColor) }
        if (is.null(labelShape)==FALSE){ g <- g+ scale_shape_manual(values=labelShape) }
        
        # add function line
        if (is.null(model.func)==FALSE){
            model.line.color <- "#000000" #"#017100"
            mline <- get_func_points(model.func, taskInfo, xID, yID, nPoints=300) # taskInfo$WCET.MIN[[xID]], taskInfo$WCET.MAX[[xID]],
            if (is.null(mline)==FALSE){
                g <- g + geom_point(data=mline, aes(x=x, y=y), color=model.line.color, alpha=1, size=0.1)
                if (is.null(probability)==FALSE){
                    pos <- select_annotate_pos(mline, xID, yID, taskInfo)
                    g<- g + annotate("text", x=pos$x, y=pos$y, label = sprintf("P=%.2f%%", probability*100), color=model.line.color, size=5, hjust=-0.1, vjust=0.1)
                }
            }
        }
        return (g)
    }
    
    draw_model <- function(data, model, taskInfo, taskIDs, filename, probability=NULL){
        if (!(length(taskIDs)==2 || length(taskIDs)==1)) return(invisible(NULL))
        if (length(taskIDs)==2){
            yID <- taskIDs[length(taskIDs)]
            xID <- taskIDs[-length(taskIDs)]
        } else{
            yID <- taskIDs[length(taskIDs)]
            allIDs <- get_task_names(data, isNum=TRUE)
            allIDs <- allIDs[-yID]
            xID    <- ifelse(length(allIDs)==0, yID, allIDs[1])
        }
        uData<-update_data(data, c("No deadline miss", "Deadline miss"))
        if (is.null(probability)){
            probability <- find_noFPR(model, uData, precise=0.0001)
        }
        fx<-generate_line_function(model, probability, yID, taskInfo$WCET.MIN[yID], taskInfo$WCET.MAX[yID])
        if (is.na(probability) == TRUE){
            g<-generate_WCET_scatter(uData, TASK_INFO, xID, yID, labelCol = "labels", legendLoc="rt",
                                     model.func=NULL, probability = NULL,
                                     labelColor=c("#3ECCFF", "#F2A082"), labelShape=c(1, 25))  #  c("#00A1FF", "#F27200"),  c("#00BFC4", "#F8766D")  // green, red
        }else{
            g<-generate_WCET_scatter(uData, TASK_INFO, xID, yID, labelCol = "labels", legendLoc="rt",
                                     model.func=fx, probability = probability,
                                     labelColor=c("#3ECCFF", "#F2A082"), labelShape=c(1, 25))  #  c("#00A1FF", "#F27200"),  c("#00BFC4", "#F8766D")  // green, red
        }
        if (is.null(filename)==TRUE){
            print(g)
        }else{
            ggsave(filename, g,  width=7, height=5)
        }
        return(invisible(NULL))
    }
}