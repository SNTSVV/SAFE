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

  #############################################
  # get bestsize point (multiple runs)
  # nealder-mead algorithm does not give the same value (because of randomness0
  # multiple tries are required
  #############################################
  get_bestsize_point_multi<-function(fun, XRange, taskInfo, xID, yID, try=10)
  {
    bestPoint <- list(X=NULL, Y=NULL, Area=NULL)
    for (t in 1:try){
      value <- get_bestsize_point(fun, XRange, taskInfo, xID, yID)
      if (is.null(bestPoint$Area)==TRUE){
        bestPoint <- value
      }else{
        if(is.null(value$Area)==FALSE && value$Area>bestPoint$Area){
          bestPoint <- value
        }
      }
    }
    return (bestPoint)
  }

  get_bestsize_point_singleD <- function(fx, taskInfo, xID, yID){
    minY <- taskInfo$WCET.MIN[yID]
    maxY <- taskInfo$WCET.MAX[yID]

    y <- fx(taskInfo$WCET.MIN[xID])
    y <- filter_y(y, minY, maxY)
    bestPoint <- list(X=NULL, Y=y, Area=y)
    return (bestPoint)
  }

  filter_y<-function(y, minY, maxY){
    # fintering over y range
    if (length(y)==1 && is.infinite(y)) return (NULL)
    y<- y[y>=minY]
    y<- y[y<=maxY]
    if (length(y)==0) return (NULL)
    return (max(y))
  }

  get_bestsize_point<-function(fun, XRange, taskInfo, xID, yID){
    minX <- taskInfo$WCET.MIN[xID]
    maxX <- taskInfo$WCET.MAX[xID]
    minY <- taskInfo$WCET.MIN[yID]
    maxY <- taskInfo$WCET.MAX[yID]

    area_func <- function(X, y) { return (prod(X-minX) * (y-minY)) }
    area_adj_func <- function(X){
      y <- fun(X)
      #cat(sprintf("x:%f, y:%f", X, y))
      y<-filter_y(y, minY, maxY)
      if (is.null(y)) return (0)
      area <- area_func(X, y)
      #cat(sprintf("==> area: %f", area))
      return (area * -1) # minimize nelder mead
    }

    # nelder-mead
    xmax <- NULL
    tryCatch({
      opt <- optimset(MaxFunEvals=200, tolX=1)
      nm <- fminbnd(area_adj_func, x0=(XRange$min+XRange$max)/2, xmin=XRange$min, xmax=XRange$max, options=opt)
      xmax <- neldermead.get(this=nm, key="xopt")
    },error = function(e) {
      message(sprintf("Failed to find max area during fminbnd()\n"), e)
    }) # try-catch

    # return results
    if (is.null(xmax)==FALSE){
      ymax <- fun(xmax[,1])
      ymax <- filter_y(ymax)
      if (is.null(ymax)){
        area<-NULL
      }else{
        area <- area_func(xmax, ymax)
        ymax <- ymax
      }
      return (list(X=xmax[,1], Y=ymax, Area=area))

    }
    return (list(X=NULL, Y=NULL, Area=NULL))
  }

}
