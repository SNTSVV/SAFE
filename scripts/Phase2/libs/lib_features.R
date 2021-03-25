# Library for features
if (!Sys.getenv("DEF_LIB_FEATURES", unset=FALSE)=="TRUE") {
    Sys.setenv("DEF_LIB_FEATURES"=TRUE)
    cat("loading lib_features.R...\n")
    ########################################################
    # load dependencies
    ########################################################
    library(ggplot2)


    ###########
    # generate formula with selected terms (only linear terms)
    ###########
    get_formula_linear<- function(y, terms){
        formula<- ""
        # Add linear terms
        for (term in terms){
            if (formula == "")
              formula <- sprintf("%s ~ %s",y, term)
            else
              formula <- sprintf("%s + %s",formula, term)
        }
        return (formula)
    }


    ###########
    # generate formula with selected terms (including quadratic and interaction)
    ###########
    get_formula_complex<- function(y, terms){
        formula<- ""
        # Add linear terms
        for (term in terms){
            if (formula == "")
              formula <- sprintf("%s ~ %s",y, term)
            else
              formula <- sprintf("%s + %s",formula, term, term)
        }
        # Add quadratic terms
        for (term in terms){formula <- sprintf("%s + I(%s^2)",formula, term)}
        # Add interaction terms
        if (length(terms) > 1){
            for(x1 in 1:(length(terms)-1)){
                for(x2 in (x1+1):length(terms)){
                    formula <- sprintf("%s + %s:%s",formula, terms[x1], terms[x2])
                }
            }
        }
        return (formula)
    }


    ############################################################
    # Checking importance through Random Forest
    #   - removing terms in a priori is not good way, but if we have big dimension of data set, we can apply them
    ############################################################
    # rf<-randomForest(result ~ ., data=training, mtry=floor(sqrt(column_size)), ntree=sqrt(nrow(training)), importance=T)
    # mtry: depth of tree, usually recommended sqrt(column_size)
    # ntree: number of trees, trade off between accuracy and cost, choose one of them
    # 142 is the value of sqrt(nrow(training)),
    # I think the number will be meaningfull I add it.
    get_relative_importance<-function(rf_model, typeNum){
        # Generate relative importance for the rf model
        tnames<-sprintf("T%d", as.integer(substring(rownames(rf_model$importance),2)))
        impor<-rf_model$importance[,typeNum]
        impor<-impor/sum(impor)
        import_df<-data.frame(Task=tnames, Importance=impor)
        return (import_df)
    }

    select_terms<-function(rel_import, threshold){
        # select terms based on threshold_function from the relative_importance(data.frame)
        selected<- as.character(rel_import[rel_import$Importance>threshold,]$Task)

        cat(sprintf("\tselected terms by type2 (%d): %s\n", length(selected), paste(selected)))
        cat(sprintf("\tMean: %.4f", threshold))
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
          ylim(0, 0.8)+
          ggtitle(sprintf("Relative Importance of Terms (nTree=%d, nDepth=%d)",nTree, nDepth))
        return (g)
    }
}