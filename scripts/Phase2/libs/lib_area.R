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
  get_bestsize_point<-function(taskInfo, model, P, targetIDs){
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
      opt <- optimset(MaxFunEvals=400)
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

}
