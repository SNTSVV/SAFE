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
    update_data <- function(data, labels=NULL){
        # change time unit
        names <- colnames(data)
        for (colname in names){
            if (startsWith(colname, "T") == FALSE) next
            data[[colname]] <- data[[colname]]
        }
        #Add label for result
        if (!is.null(labels)){
            data$labels <- factor(data$result, labels=labels)
            data$labels[data$result == 0] <- labels[1]
            data$labels[data$result == 1] <- labels[2]
        }

        return (data)
    }
}