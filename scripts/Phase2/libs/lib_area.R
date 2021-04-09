########################################################
# load dependencies
########################################################
if (Sys.getenv("JAVA_RUN", unset=FALSE)==FALSE) {
  suppressMessages(library(neldermead))
  source("libs/lib_model.R")  # generate_line_function
  source("libs/lib_formula.R")  # get_raw_names, get_base_name does not need lib_data.R
}

########################################################
# Library for logistic regression that includes
#   - generate model function
#   - generate points on the model
########################################################
if (!Sys.getenv("DEV_LIB_AREA", unset=FALSE)=="TRUE") {
  Sys.setenv("DEV_LIB_AREA"=TRUE)
  cat("loading lib_model.R...\n")

  #############################################
  # find maximum area by a point on the model function
  # This functions for the specific formula
  #############################################
  get_bestsize_point_old<-function(taskInfo, model, P, targetIDs){
    # generate IDs
    yID <- targetIDs[length(targetIDs)]
    XID <- targetIDs[1:(length(targetIDs)-1)]

    # nelder-mead
    intercepts<-get_intercepts(model, P, targetIDs, taskInfo)
    # when exists intercepts...calcuate area
    if (is.null(intercepts)==FALSE && all(as.double(intercepts[1,])!=Inf)==TRUE){
      # find minimum index
      fx<-generate_line_function(model, P, yID, taskInfo$WCET.MIN[yID], taskInfo$WCET.MAX[yID])
      area_func <- function(X){return (prod(X) * fx(X) * -1)}

      opt <- optimset(MaxFunEvals=200)
      #nm <- fminbnd(area_func, x0=XRange$min, xmin=XRange$min, xmax=XRange$max, options=opt)
      nm <- fminbnd(area_func, x0=taskInfo$WCET.MIN[XID], xmin=taskInfo$WCET.MIN[XID], xmax=intercepts[[sprintf("T%d",XID)]], options=opt)

      # return results
      xmax <- neldermead.get(this=nm, key="xopt")
      ymax <- fx(xmax)
      area <- area_func(xmax)*-1
      #cat(sprintf("(%.4f, %.4f), ==>  area=%.4f\n",xmax, ymax, area))

      return (list(X=xmax, Y=ymax, Area=area))
    }
    return (list(X=NULL, Y=NULL, Area=NULL))
  }

  get_bestsize_point<-function(fun, XRange, taskInfo, xID, yID){
    minX <- taskInfo$WCET.MIN[xID]
    maxX <- taskInfo$WCET.MAX[xID]
    minY <- taskInfo$WCET.MIN[yID]
    maxY <- taskInfo$WCET.MAX[yID]
    area_func <- function(X, y) {return (prod(X-minX) * (y-minY))}
    area_adj_func <- function(X){
      y <- fun(X)
      #cat(sprintf("x:%f, y:%f", X, y))
      if (length(y)==1 && is.infinite(y)){
        return (0)
      }
      # filtering over y range
      y<- y[y>=minY]
      y<- y[y<=maxY]
      if (length(y)==0) return (0)
      area <- area_func(X, y)
      area <- max(area)
      #cat(sprintf("==> area: %f", area))
      return (area * -1) # minimize nelder mead
    }

    # nelder-mead
    xmax <- NULL
    tryCatch({
      opt <- optimset(MaxFunEvals=200)
      nm <- fminbnd(area_adj_func, x0=(XRange$min+XRange$max)/2, xmin=XRange$min, xmax=XRange$max, options=opt)
      xmax <- neldermead.get(this=nm, key="xopt")
    },error = function(e) {
      message(sprintf("Failed to find max area during fminbnd()\n"), e)
    }) # try-catch

    # return results
    if (is.null(xmax)==FALSE){
      ymax <- fun(xmax)
      ymax<- ymax[ymax>=minY]
      ymax<- ymax[ymax<=maxY]
      if(length(ymax)==0){
        ymax<-NULL
        area<-NULL
      }
      else{
        area <- area_func(xmax, ymax) # area_func(xmax)*-1
      }
      return (list(X=xmax[,1], Y=ymax, Area=area))
    }
    return (list(X=NULL, Y=NULL, Area=NULL))
  }

}
