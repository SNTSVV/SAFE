########################################################
# load dependencies
########################################################
if (Sys.getenv("JAVA_RUN", unset=FALSE)==FALSE) {
  suppressMessages(library(stringr))
}

########################################################
# Library for config
########################################################
if (!Sys.getenv("DEF_LIB_CONFIG", unset=FALSE)=="TRUE") {
  Sys.setenv("DEF_LIB_CONFIG"=TRUE)
  cat("loading lib_config.R...\n")

  ########################################################
  # configrations
  ########################################################
  # The palette with grey:
  # cbPalette <- c( "#00BFC4", "#F8766D", "#009E73", "#D55E00", "#0072B2", "#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442",   "#CC79A7")
  cbPalette <- c( "#000000", "#AAAAAA", "#009E73", "#D55E00", "#0072B2", "#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442",   "#CC79A7")
  #c("#3ECCFF", "#F2A082"), c("#00A1FF", "#F27200")
  UNIT <- 1
  UNIT_STR<-"(s)"


  ######################################################
  # loading task info
  ######################################################
  load_taskInfo <- function(filename, timeQuanta){
    info <- read.csv(file=filename, header = TRUE)
    # info <- data.frame(
    #   ID = c(1:nrow(info)),
    #   info
    # )
    colnames(info) <- c("ID", "NAME", "TYPE", "PRIORITY", "OFFSET", "WCET.MIN", "WCET.MAX", "PERIOD", "INTER.MIN", "INTER.MAX", "DEADLINE", "DEADLINE.TYPE", "DEPENDENCY","TRIGGER")
    info$OFFSET    <- as.integer(round(info$OFFSET/timeQuanta))
    info$WCET.MIN  <- as.integer(round(info$WCET.MIN/timeQuanta))
    info$WCET.MAX  <- as.integer(round(info$WCET.MAX/timeQuanta))
    info$PERIOD    <- as.integer(round(info$PERIOD/timeQuanta))
    info$INTER.MIN <- as.integer(round(info$INTER.MIN/timeQuanta))
    info$INTER.MAX <- as.integer(round(info$INTER.MAX/timeQuanta))
    info$DEADLINE  <- as.integer(round(info$DEADLINE/timeQuanta))
    return (info)
  }

  ######################################################
  # parsing parameters from settings of SAFE search
  ######################################################
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
  # get a list of uncertain tasks
  ######################################################
  #get_uncertain_tasks<-function(tasks){
  #    diffWCET <- tasks$WCET.MAX - tasks$WCET.MIN
  #    tasks <- c()
  #    for(x in 1:length(diffWCET)){
  #       if (diffWCET[x] <= 0) next
  #       tasks <- c(tasks, sprintf("T%d",as.integer(x)))
  #    }
  #    return(tasks)
  #}

  namedDoubleArrayToStr<-function(item){
    str<-"["
    nn<-names(item)
    for(colID in 1:length(item)){
      str<- sprintf("%s%s: %.8f, ",str,nn[[colID]], item[[colID]])
    }
    str <- sprintf("%s]",str)
    return (str)
  }
  
  ###################################
  #
  ###################################
  getAbsolutePath <- function(path, workingDir){
    if(startsWith(path, "/") || startsWith(path, "~"))
        return (path)
    return (sprintf("%s/%s", workingDir, path))
  }
}