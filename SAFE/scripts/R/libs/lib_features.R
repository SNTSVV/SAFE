########################################################
# load dependencies
########################################################
if (Sys.getenv("JAVA_RUN", unset=FALSE)==FALSE) {
    suppressMessages(library(ggplot2))
}

########################################################
# Library for features
########################################################
if (!Sys.getenv("DEF_LIB_FEATURES", unset=FALSE)=="TRUE") {
    Sys.setenv("DEF_LIB_FEATURES"=TRUE)
    cat("loading lib_features.R...\n")

    ############################################################
    # Checking importance through Random Forest
    #   - removing terms in a priori is not good way, but if we have big dimension of data set, we can apply them
    ############################################################
    # rf<-randomForest(result ~ ., data=training, mtry=floor(sqrt(column_size)), ntree=sqrt(nrow(training)), importance=T)
    # mtry: depth of tree, usually recommended sqrt(column_size)
    # ntree: number of trees, trade off between accuracy and cost, choose one of them
    # 142 is the value of sqrt(nrow(training)),
    # I think the number will be meaningfull I add it.
    get_relative_importance<-function(rf_model, type){
        # Generate relative importance for the rf model
        tnames<-sprintf("T%d", as.integer(substring(rownames(rf_model$importance),2)))
        impor<-rf_model$importance[,type]
        impor<-impor/sum(impor)
        import_df<-data.frame(Task=tnames, Importance=impor)
        return (import_df)
    }

    # select target terms among

    select_terms<-function(rel_import, threshold, limits=NULL){
        # select terms based on threshold_function from the relative_importance(data.frame)
        if (is.null(limits)==TRUE) {
            selected <- as.character(rel_import[rel_import$Importance>=threshold,]$Task)
        }else{
            ordered_df <-import_df[order(-import_df$Importance),]
            tasks <- ordered_df$Task
            if(length(tasks)>limits){
                selected<-as.character(tasks[1:limits])
            }else{
                selected<-as.character(tasks)
            }
        }

        cat(sprintf("\tselected terms by type2 (%d): %s\n", length(selected), paste(selected)))
        cat(sprintf("\tMean: %.4f\n", threshold))
        return (selected)
    }

    ############################################################
    # Making bar chart
    ############################################################
    make_bar_chart<-function(data, nTree, nDepth){
        g<-ggplot(data=data, aes(x=reorder(Task, Importance), y=Importance))+
          geom_bar(stat="identity")+
          geom_text(aes(label=round(Importance,4)), hjust=-0.1, vjust=0.5, color="red", size=3)+
          coord_flip()+
          theme(legend.justification=c(1,0), legend.position=c(1, 0), legend.title=element_blank(), plot.title=element_text(hjust = 0.5))+
          xlab("Task") +
          ylab("Relative importance")+
          ylim(0, 1)+
          ggtitle(sprintf("Relative Importance of Terms (nTree=%d, nDepth=%d)",nTree, nDepth))
        return (g)
    }
}