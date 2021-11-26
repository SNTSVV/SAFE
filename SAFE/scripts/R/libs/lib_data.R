########################################################
# Library for data
########################################################
if (!Sys.getenv("DEF_LIB_DATA", unset=FALSE)=="TRUE") {
    Sys.setenv("DEF_LIB_DATA"=TRUE)
    cat("loading lib_data.R...\n")

    ########################################################
    # get task names
    # return column names from the dataset, which is task names
    ########################################################
    get_task_names<-function(data, isNum=FALSE){

        names <- colnames(data)
        terms <-c()
        for (colname in names){
            if (startsWith(colname, "T") == FALSE) next
            if (isNum == TRUE){
                terms<-c(terms, as.integer(substring(colname, 2)))
            }else{
                terms<-c(terms, colname)
            }
        }
        return (terms)
    }


    ########################################################
    # return column names from the dataset, which is task names
    ########################################################
    #get_uncertain_tasks<-function(){
    #    diffWCET <- TASK_INFO$WCET.MAX - TASK_INFO$WCET.MIN
    #    tasks <- c()
    #    for(x in 1:length(diffWCET)){
    #        if (diffWCET[x] <= 0) next
    #        tasks <- c(tasks, sprintf("T%d",as.integer(x)))
    #    }
    #    return(tasks)
    #}


    ########################################################
    #### load data and update UNIT and append labels
    ########################################################
    update_data <- function(data, labels=NULL, timeUnit=1){
        # change time unit
        names <- colnames(data)
        for (colname in names){
            if (startsWith(colname, "T") == FALSE) next
            data[[colname]] <- data[[colname]]*timeUnit
        }
        #Add label for result
        if (!is.null(labels)){
            all <- nrow(data)
            positive<-nrow(data[data$result==0,])
            if (positive==all || positive==0){
                pItem <- data.frame(result=as.integer(0), t(rep(-1, ncol(data)-1)))
                nItem <- data.frame(result=as.integer(1), t(rep(-1, ncol(data)-1)))
                pItem <- rbind(pItem, nItem)
                colnames(pItem) <- colnames(data)
                data <- rbind(data, pItem)
            }
            data$labels <- factor(data$result, levels=c(0,1), labels=labels)
        }

        return (data)
    }
}