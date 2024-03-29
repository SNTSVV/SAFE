########################################################
# load dependencies
########################################################
if (Sys.getenv("JAVA_RUN", unset=FALSE)==FALSE) {
    library(nloptr)    # neldermead algorithm
    source("libs/lib_model.R")
}

########################################################
# Library for sampling from the LR model or random
#   - required to define TASK_INFO(data.frame)
########################################################
if (!Sys.getenv("DEV_LIB_SAMPLING", unset=FALSE)=="TRUE") {
    Sys.setenv("DEV_LIB_SAMPLING"=TRUE)
    cat("loading lib_sampling.R...\n")

    ########################################################
    #### get test data to give to predict function
    ########################################################
    sample_by_random <- function(nSample, taskInfo){
        # This function generates random sample points within range of each tasks
        # dependency:
        #   - WCET.MIN and WCET.MAX in TASK_INFO(data.frame)
        # Input:
        #   - tasknames(array): task names
        #   - nSample (int): the number of sample points
        # Output: sampled points(data.frame)
        tasknames <- c()
        for(x in 1:nrow(taskInfo)){
            tasknames<- c(tasknames, sprintf("T%d", x))
        }

        # for each task,
        sample_ds <- data.frame()
        for(taskID in 1:nrow(taskInfo)){
            if (taskInfo$WCET.MIN[[taskID]]==taskInfo$WCET.MAX[[taskID]]){
                x <- taskInfo$WCET.MIN[[taskID]]
            }else{
                x <- sample(taskInfo$WCET.MIN[[taskID]]:taskInfo$WCET.MAX[[taskID]], nSample, replace=TRUE)
            }

            if (nrow(sample_ds)==0){
                sample_ds <-data.frame(x)
            }else{
                sample_ds<- cbind(sample_ds, x)
            }
        }
        colnames(sample_ds) <- tasknames
        return (sample_ds*UNIT)
    }

    # ************************************************
    # generate examples from the model within some distance
    #   - this function is to make estimated model line
    sample_regression_points <- function(tasknames, model, nPoints, P, min_dist){
        # This function generates sample points within range of each tasks filtered by distance
        # dependency:
        #   - WCET.MIN and WCET.MAX in TASK_INFO(data.frame)
        # Input:
        #   - data(data.frame): To get how many dimension we use
        #   - nSample (int): the number of sample points
        # Output: sampled points(data.frame)

        # get task names
        samples <- data.frame()
        while(nrow(samples)<nPoints){
            candidates <- sample_by_random(nPoints)
            sample <- ..select_within_distance(candidates, model, P, min_dist)
            samples <- rbind(samples, sample)
        }
        return (samples[1:nPoints,])
    }

    ..select_within_distance<-function(candidates, model, P, min_dist){

        # calculate denominator (I don't calculate denominator because every points have same denominator)
        deno = 0
        b <- model$coefficients
        for(i in 2:length(b)){deno = deno + b[[i]]^2}
        deno = sqrt(deno)

        # get predicted values
        predict_values <- predict(model, newdata=candidates, type="link")

        # find minimum index
        accepted=data.frame()
        for(x in 1:nrow(candidates)){
            nu <- abs( predict_values[x] - log(P/(1-P)) )
            dist <- nu/deno
            if (dist<=min_dist){
                accepted <- rbind(accepted, candidates[x,])
            }
        }

        # return one sample of data.frame
        return (accepted)
    }

    # ************************************************
    # generate examples from the model in some ranges
    sample_based_model_prob_inrange <- function(tasknames, model, nSample, Ps, Prange){
        # This function generates sample points within range of each tasks filtered by distance
        # dependency:
        #   - WCET.MIN and WCET.MAX in TASK_INFO(data.frame)
        # Input:
        #   - data(data.frame): To get how many dimension we use
        #   - nSample (int): the number of sample points
        # Output: sampled points(data.frame)

        # get task names
        samples <- data.frame()
        while(nrow(samples)<nSample){
            candidates <- sample_by_random(20)
            sample <- ..select_range_distance(candidates, model, Ps-Prange, Ps+Prange, 0)
            samples <- rbind(samples, sample)
        }
        return (samples[1:nSample,])
    }

    ..select_range_distance<-function(candidates, model, Pmin, Pmax, overBound){

        # calculate denominator (I don't calculate denominator because every points have same denominator)
        deno = 0
        b <- model$coefficients
        for(i in 2:length(b)){deno = deno + b[[i]]^2}
        deno = sqrt(deno)

        # get predicted values
        predict_values <- predict(model, newdata=candidates, type="link")

        # find minimum index
        accepted=data.frame()
        for(x in 1:nrow(candidates)){
            nu_min <- predict_values[x] - log(Pmin/(1-Pmin))
            nu_max <- predict_values[x] - log(Pmax/(1-Pmax))
            accept = FALSE
            if (nu_min >= 0 && nu_max<=0){
                accept=TRUE
            }
            else{
                dist_min <- abs(nu_min)/deno
                dist_max <- abs(nu_max)/deno
                if (dist_min<=overBound || dist_max<=overBound){
                    accept=TRUE
                }
            }
            if (accept){
                accepted <- rbind(accepted, candidates[x,])
            }
        }

        # return one sample of data.frame
        return (accepted)
    }



    ######################################################################
    # generate WCET examples around model line (with threshold P)
    #  - generate n candidates and select one the shortest distance from the model
    sample_based_prob_distance <- function(tasknames, model, nSample=1000, nCandidate=20, P=threshold){
        # get task names
        samples <- data.frame()
        for(x in 1:nSample){
            candidates <- sample_by_random(nCandidate)
            sample <- ..select_based_prob_distance(candidates, model, P)
            samples <- rbind(samples, sample)
        }
        return (samples)
    }

    # ************************************************
    # select one example among candidates
    #  - select based a distance from the model line (with threshold P)
    ..select_based_prob_distance<-function(candidates, model, P){
        # get predicted values
        predict_values <- predict(model, newdata=candidates, type="response")

        # find minimum index
        min_index = -1
        min_diff = 2^.Machine$double.digits
        for (x in 1:length(predict_values)){
            # if (predict_values[x] < P) next
            diff <- abs(predict_values[x] - P)
            if (diff < min_diff){
                min_index <- x
                min_diff <- diff
            }
        }
        return (candidates[min_index,])
    }


    ########################################################
    # generate WCET examples around model line (with threshold P)
    #  - generate n candidates and select one the shortest distance from the model
    #  - this function uses euclidian distance
    sample_based_euclid_distance <- function(model, nSample, nCandidate, P, isGeneral=TRUE){
        maxTry <- nSample*10
        # get task names
        targetIDs <- get_base_names(names(model$coefficients), isNum=TRUE)
        samples <- data.frame()

        count <-0
        dpoint <- nSample %/% 50
        if (dpoint!=0) cat(sprintf("%d points sampling", nSample))
        for(x in 1:maxTry){
            #cat(sprintf("Try %d ...", x))
            if(count >= nSample) break
            if (dpoint!=0 && count%%dpoint==0){
                cat( ifelse(count%%(dpoint*5)==0, "|", "") )
            }
            candidates <- sample_by_random(nCandidate)
            sample <- ..select_based_euclid_distance(candidates, model, P, targetIDs, isGeneral)
            if (is.null(sample)) next;
            samples <- rbind(samples, sample)
            count <- count+1
        }
        if (count < nSample){
            cat(sprintf("No candidates are available to find min distance (tried %d times)\n", maxTry))
            return (samples)
        }

        if (dpoint!=0) cat("finished\n")
        return (samples)
    }

    # ************************************************
    # select one example among candidates
    # generate a model line function
    generate_samples_by_distance<-function(taskInfo, model.fx, yID, XID, nSamples, nCandidates){
        samples <- data.frame()
        for (cnt in c(1:nSamples)) {
            candidates <- sample_by_random(nCandidates, taskInfo)
            sample <- ..select_based_euclid_distance_multi(candidates, model.fx, yID, XID, taskInfo)
            if (is.null(sample)){
                select <- round(runif(1,1,nCandidates))
                sample <- candidates[select,]
            }
            samples <- rbind(samples, sample)
        }
        return (samples)
    }



    # ************************************************
    # find available X range of a function
    # this is only available a two-dimensional function (X1, X2)
    find_available_x_range<-function(fun, minX, maxX, stepRate=0.02, density=0.001){
        ret <- list()
        ret[["min"]]<-find_available_x_min(fun, minX, maxX, stepRate, density)
        ret[["max"]]<-find_available_x_max(fun, minX, maxX, stepRate, density)
        return (ret)
    }
    find_available_x_min <- function(fun, minX, maxX, stepRate=0.02, density=0.001){
        L <- minX
        R <- maxX
        x <- L
        step <- (R-L)*stepRate
        if(step<density) return (R)
        while(x<=R){  # check current density
            v<-fun(x)
            if (!(length(v)==1 && is.infinite(v))){ # if it finds non-infinite value
                x <- find_available_x_min(fun, x-step, x, stepRate, density)
                break
            }
            x <- x + step
        }
        if (x<minX) return(minX)
        return (x)
    }
    find_available_x_max <- function(fun, minX, maxX, stepRate=0.02, density=0.001){
        L <- minX
        R <- maxX
        x <- R
        step <- (R-L)*stepRate
        if(step<density) return (L)
        while(x>=L){  # check current density
            v<-fun(x)
            if (!(length(v)==1 && is.infinite(v))){ # if it finds non-infinite value
                x <- find_available_x_max(fun, x, x+step, stepRate, density)
                break
            }
            x <- x-step
        }
        if (x>maxX) return(maxX)
        return (x)
    }

    # ************************************************
    # find available X range of a function for multi-dimensional
    find_x_range<-function(taskInfo, fun, Xlist, trainingData, extendRate=0.01)
    {
        # select related data to Xlist
        targetData <- NULL
        nameList<-c()
        if(is.null(Xlist)){
            # Range return
            ranges <-list()
            ranges[["min"]] <- 0
            ranges[["max"]] <- 0
            return (ranges)
        }

        for( tID in Xlist){
            tname <- sprintf("T%d", tID)
            targetData<- cbind(targetData, trainingData[[tname]])
            nameList<-c(nameList, tname)
        }
        colnames(targetData) <- nameList

        # find Max Range for each axis
        maxX <- rep(0, length(Xlist))
        for (xIdx in 1:nrow(targetData)){
            #cat(sprintf("%d,",value))
            X<-targetData[xIdx,]
            y<-fun(X)
            if (length(y)==1 && is.infinite(y)==TRUE) next
            for (idx in 1:length(maxX)){
                if (X[idx]>maxX[idx]){
                    maxX[idx] <- X[idx]
                }
            }
        }
        # Range return
        ranges <-list()
        ranges[["min"]] <- taskInfo$WCET.MIN[Xlist]
        ranges[["max"]] <- as.integer(maxX * (1+extendRate))
        return (ranges)
    }

    # ************************************************
    # select one example among candidates (single dimension)
    #  - generate n candidates and select one the shortest distance from the model
    #  - this function uses euclidian distance
    #  - targetIDs : selected features in the formula (the last one is one that used to function result)
    ..select_based_euclid_distance<-function(candidates, model, P, targetIDs, isGeneral=TRUE){

        # generate IDs
        answerID <- targetIDs[length(targetIDs)]
        pointsIDs <- targetIDs[1:(length(targetIDs)-1)]

        # generate points
        answers <- candidates[[sprintf("T%d", answerID)]]
        points <- NULL
        for ( x in pointsIDs){ points<- cbind(points, candidates[[sprintf("T%d", x)]]) }
        points<- as.data.frame(points)
        colnames(points) <- sprintf("T%d", pointsIDs)

        # generate a model line function
        if (isGeneral==TRUE){
            fx<-generate_line_function(model, P, answerID, TASK_INFO$WCET.MIN[answerID]*UNIT, TASK_INFO$WCET.MAX[answerID]*UNIT)
        } else{
            fx<-get_model_func_quadratic(model, P, TASK_INFO$WCET.MIN[answerID]*UNIT, TASK_INFO$WCET.MAX[answerID]*UNIT)
        }
        xID <-pointsIDs[1]
        # xRange <- find_available_x_range(fx, TASK_INFO$WCET.MIN[[xID]]*UNIT, TASK_INFO$WCET.MAX[[xID]]*UNIT)

        # find minimum index
        min_Index <- 0
        min_Value <- 2^.Machine$double.digits
        for(px in 1:nrow(points)){
            # create distance function
            pointX <- as.vector(points[px,])
            pointY <- answers[px]
            dist_func<-function(X){
                #cat(sprintf("X:%s, ",..to_string(X)))
                retY <- fx(X)
                #cat(sprintf("Y:%f, ",retY))
                if (length(retY)==1 && is.infinite(retY)) {
                    return (-2^.Machine$double.digits) # largest value
                }
                dx <- norm(X-pointX, type="2")  # norm(c(2,3), type="2") == sqrt(2^2 + 3^2)
                #dx <- Norm(X - pointX)  # calculates sqrt((X[1]-pointX[1])^2 + ... + (X[n]-pointX[n])^2)
                dy <- min(abs(retY - pointY)) # to proceed multi valued return of fx, we select the minimum distance from pointY
                dist<- sqrt(dx^2 + dy^2)
                #cat(sprintf("dist:%f\n",dist))
                return (dist)
            }

            # find minimum distance in range (WCET.MIN, WCET.MAX) of the first points
            fminDist <- NULL
            tryCatch({
                # use function optimization: https://rdrr.io/cran/nloptr/man/neldermead.html
                # nm <- neldermead(x0=as.numeric(xRange$min), fn=dist_func)
                nm <- neldermead(x0=as.numeric(TASK_INFO$WCET.MIN[[xID]]*UNIT), fn=dist_func)
                fminDist <- nm$value
            },error = function(e) {
                message(sprintf("Failed to find minDistance candidate %d\n during fminbnd() in sampling",px), e)
            }) # try-catch

            if (!is.null(fminDist) && min_Value > fminDist){
                min_Index <- px
                min_Value <- fminDist
            }
        }

        if (min_Index == 0){
            #cat("No candidates are available to find min distance\n")
            return (NULL)
        }
        return (candidates[min_Index,])
    }


    # ************************************************
    # select one example among candidates
    #  - generate n candidates and select one the shortest distance from the model
    #  - this function uses euclidian distance
    #  - targetIDs : selected features in the formula (the last one is one that used to function result)
    ..select_based_euclid_distance_multi<-function(candidates, model.fun, yID, XID, taskInfo){
        # extract function coordinates
        answers <- candidates[[sprintf("T%d", yID)]]
        points <- NULL
        for ( x in XID){ points<- cbind(points, candidates[[sprintf("T%d", x)]]) }
        points<- as.data.frame(points)
        colnames(points) <- sprintf("T%d", XID)

        # find minimum index
        min_Index <- 0
        min_Value <- 2^.Machine$double.digits
        for(px in 1:nrow(candidates)){  # It should be done as many as the number of candidates
            # create distance function
            pointX <- as.vector(points[px,])
            pointY <- answers[px]
            dist_func<-function(X){
                #cat(sprintf("X:%s, ",..to_string(X)))
                retY <- model.fun(X)
                if (is.null(XID)){
                    dist<- min(abs(retY - pointY))
                }else{
                    #cat(sprintf("Y:%f, ",retY))
                    if (length(retY)==1 && is.infinite(retY)) {
                        return (-2^.Machine$double.digits) # largest value
                    }

                    dx <- norm(X-pointX, type="2")  # norm(c(2,3), type="2") == sqrt(2^2 + 3^2)
                    dy <- min(abs(retY - pointY)) # to proceed multi valued return of fx, we select the minimum distance from pointY
                    dist<- sqrt(dx^2 + dy^2)
                }
                #cat(sprintf("dist:%f\n",dist))
                return (dist)
            }

            # find minimum distance in range (WCET.MIN, WCET.MAX) of the first points
            fminDist <- NULL
            tryCatch({
                # use function optimization: https://rdrr.io/cran/nloptr/man/neldermead.html
                nm <- neldermead(x0=as.numeric(taskInfo$WCET.MIN[XID]), fn=dist_func)
                fminDist <- nm$value
            },error = function(e) {
                message(sprintf("Failed to find minDistance candidate %d\n during fminbnd() in sampling",px), e)
            }) # try-catch

            if (!is.null(fminDist) && min_Value > fminDist){
                min_Index <- px
                min_Value <- fminDist
            }
        }

        if (min_Index == 0){
            return (NULL)
        }
        return (candidates[min_Index,])
    }
}