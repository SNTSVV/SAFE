########################################################
# load dependencies
########################################################
if (Sys.getenv("JAVA_RUN", unset=FALSE)==FALSE) {
    source("libs/lib_formula.R")  # get_raw_names, get_base_name does not need lib_data.R
}

########################################################
# Library for logistic regression that includes
#   - generate model function
#   - generate points on the model
########################################################
if (!Sys.getenv("DEV_LIB_MODEL", unset=FALSE)=="TRUE") {
    Sys.setenv("DEV_LIB_MODEL"=TRUE)
    cat("loading lib_model.R...\n")

    #############################################
    # calculate line function
    #############################################
    # ************************************************
    # find index if the base is in tasks (task ID list)
    ..find_task_index<- function(base, tasks){
        ret <- 0
        if (length(tasks)==0) return (0)
        for (i in 1:length(tasks)){
            if (tasks[[i]]==base) {
                ret <- i
            }
        }
        return (ret)
    }

    # ************************************************
    # generate single term info
    #   - return poly and base of the term
    #   - if term is interection term, we will return a list of two vectors
    ..get_term_info <- function(term){
        base <- c()
        exponent <- c()
        tnames <- strsplit(term, ":")[[1]]
        for(tname in tnames){
            if (startsWith(tname, "I(") == TRUE) {
                base <- c(base, as.integer(substring(tname, 4, nchar(tname)-3)) )
                exponent <- c(exponent, as.integer(substring(tname, nchar(tname)-1, nchar(tname)-1)) )
            } else if (startsWith(tname, "T") == TRUE) {
                base <- c(base, as.integer(substring(tname, 2)) )
                exponent <- c(exponent, 1)
            } else{
                base<- c(base, 0)
                exponent<- c(exponent, 0)
            }
        }
        return (list("base"=base, "exponent"=exponent))
    }

    # ************************************************
    # generate multiple terms info
    #   - poly, index, target (poly for target task)
    #   -
    ..parsing_coef <- function(coef, TaskIDs, targetID){
        # group variables
        exponent<- c()  # exponent for the non-target tasks (0, 1, 2)
        index<-c()  # taskIDs Mapped index
        target<-c()  # exponent for target task (0, 1, 2)

        # grouping for each polynomial
        terms<-names(coef)
        for(idx in 1:length(coef)){
            # idx<-3
            term <- terms[idx]
            info <-..get_term_info(term)
            # info
            if (length(info$exponent)==2) {
                # interaction
                tIdx <- ifelse(info$base[[1]]==targetID, 1, 2)
                oIdx <- ifelse(info$base[[1]]==targetID, 2, 1)

                target <- c(target, info$exponent[[tIdx]])
                index <- c(index, ..find_task_index(info$base[[oIdx]], TaskIDs))
                exponent <- c(exponent, info$exponent[[oIdx]])
            }else {
                # single
                if(info$base==targetID){  # if target task...
                    target <- c(target, info$exponent)
                    index <- c(index, 0)
                    exponent <- c(exponent, 0)
                } else {
                    target <- c(target, 0)
                    index <- c(index, ..find_task_index(info$base, TaskIDs))
                    exponent <- c(exponent, info$exponent)
                }
            }
        }
        # data.frame("name"=names(coef)[1:length(poly)],"coef"=as.double(coef)[1:length(poly)], "poly"=poly,"index"=index,"target"=target)
        info <- data.frame(
            "coef"=as.double(coef),
            "exponent"=exponent,
            "index"=index,
            "target"=target
        )
        rownames(info) <- names(coef)
        return (info)
    }

    # ************************************************
    # to convert vector to string:: c(x,x,x)
    # util function to show vector
    ..to_string <- function(marray){
        t <- sprintf("c(%s",marray[1])
        if(length(marray)>1){
            for (i in 2:length(marray)){
                t<-sprintf("%s,%s", t, marray[i])
            }
        }
        t<-sprintf("%s)", t)
        return (t)
    }

    # ************************************************
    # calculate with X and selected term info (coef, poly, x_index, target)
    # Not used currently, because the performance
    ..term_calculator<-function(tinfo, X){
        value = 0
        for(i in 1:nrow(tinfo)){
            base <- ifelse(tinfo$index[i]!=0, X[tinfo$index[i]], 1)
            value <- value + (tinfo$coef[i]*base^tinfo$poly[i])
        }
        return(value)
    }

    ..check_including_quadratic<-function(terminfo){
        return (2 %in% terminfo$target)
    }

    # ************************************************
    # To generate model line function
    #   - model with probability threshold
    #   - related tasks
    #   - target task ID, and range(minY, maxY) of target task
    generate_line_function<-function(model, P, targetY, minY, maxY){

        # get tasks from the formula and remove target task
        TaskIDs <- get_base_names(names(model$coefficients), isNum=TRUE)
        idx<-..find_task_index(targetY, TaskIDs)
        if(idx==0){
            cat("target task does not exists in the model formula!!")
            return (NULL)
        }
        TaskIDs <- TaskIDs[-idx]
        info <- ..parsing_coef(model$coefficients, TaskIDs, targetY)
        # print(info)

        if (..check_including_quadratic(info)==FALSE) {
            # 1st order
            func<-function(X){
                b<-0
                c<-0
                for(i in 1:nrow(info)){
                    base <- ifelse(info$index[i]!=0, X[info$index[i]], 1)
                    value <- (info$coef[i]*base^info$exponent[i])
                    if (info$target[i]==1) b <- b + value
                    if (info$target[i]==0) c <- c + value
                }
                c <- c - log(P/(1-P))
                ret<-(c/-b)
                return (ret)
                #if (minY <= ret && ret<=maxY){
                #}
                #return (Inf)
            }
        }else{
            # 2nd order (use sqrt )
            func<-function(X){
                a <- 0
                b <- 0
                c <- 0

                # Separate each term by terms (quadratic, linear, constant)
                for(i in 1:nrow(info)){
                    base <- ifelse(info$index[i]!=0, X[info$index[i]], 1)
                    value <- (info$coef[i]*base^info$exponent[i])

                    if (info$target[i]==2) a <- a + value
                    if (info$target[i]==1) b <- b + value
                    if (info$target[i]==0) c <- c + value
                }
                c <- c - log(P/(1-P))

                # Solve quadratic formula (x = (-b \pm sqrt(b^2 - 4ac)) /2a)
                inV <- (b^2)-(4*a*c)
                if (inV<0){
                    # print(sprintf("return Inf because inV:%.6f", inV))
                    return (Inf)
                }
                s1 <- (-b + sqrt(inV)) / (2*a)
                s2 <- (-b - sqrt(inV)) / (2*a)

                # return values
                answers <- c()
                if (is.nan(s1)==FALSE && is.infinite(s1)==FALSE){
                    answers <- c(answers, s1)
                }
                if (is.nan(s2)==FALSE && is.infinite(s2)==FALSE){
                    answers <- c(answers, s2)
                }

                #answers <- c()
                #if (minY<=s1 && s1 <=maxY){
                #    answers <- c(answers, s1)
                #}
                #if (minY<=s2 && s2<=maxY){
                #    answers <- c(answers, s2)
                #}
                if (length(answers)==0){
                    # no answers in the range [minY, maxY]
                    return (Inf)
                }
                return ( answers )
            }
        }
        return(func)
    } # line function

    #************************************************
    # get points by line function (we use this points as a function line instead of the actual function)
    #   - actual function does not working properly in ggplot
    #   - fun: a function to get points
    #   - minX, maxY: range of X
    #   - nPoints: number of points
    get_func_points<-function(fun, taskInfo, xID, yID, nPoints){
        minX <- taskInfo$WCET.MIN[[xID]]
        maxX <- taskInfo$WCET.MAX[[xID]]
        minY <- taskInfo$WCET.MIN[[yID]]
        maxY <- taskInfo$WCET.MAX[[yID]]
        # find x-axis based points
        ..gen_points<-function(by){
            df <- data.frame()
            x <- minX
            while(x< maxX){
                v <- fun(x)     # calculate
                if (!(length(v)==1 && is.infinite(v))){
                    df <- rbind(df, data.frame(x=x, y=v))
                }
                x <- x + by
            }
            v <- fun(maxX)    # calculate
            if (!(length(v)==1 && is.infinite(v))){
                df <- rbind(df, data.frame(x=x, y=v))
            }
            df<-df[df$y>=minY & df$y<=maxY & df$x>=minX & df$x<=maxX,]
            return(df)
        }
        ..find_rough_point<-function(df){
            maxDiff <-0
            maxDiffIdx <- 0
            for ( idx in 2:nrow(df)){
                diff <- df$y[idx] - df$y[idx-1]
                if (diff>maxDiff){
                    maxDiff <- diff
                    maxDiffIdx <- idx
                }
            }
            ret <- list()
            ret[["idx"]] <- maxDiffIdx
            ret[["diff"]] <- maxDiff
            return (ret)
        }

        by <- (maxX - minX) / nPoints   # delta between points
        points <- ..gen_points(by)
        if (nrow(points)==0){
            cat(sprintf("Cannot generate model value within the range [%d, %d]\n", minX, maxX))
            return (NULL)
        }
        points <- points[order(points$y),]   # sort by y
        rough <- ..find_rough_point(points)
        if (rough$diff*0.8 > by){
            maxrange <- max(points$y) - min(points$y)
            if (rough$diff> maxrange * 0.05){  # If the greatest diff is over 5% of maxrange, add more points
                minX <- points[rough$idx,]$x - by*10
                maxX <- points[rough$idx,]$x + by*10
                by <- (maxX - minX) / nPoints # new delta between points
                points2 <- ..gen_points(by)
                points <- rbind(points, points2)
            }
        }

        return (points)
    }

    #############################################
    # related get intercept
    #############################################
    # dimension=0 : interaction
    ..find_idx <- function(cof, targetID, dimension){
        cnames <- names(cof)
        targetX <- 0

        for (x in 1:length(cnames)){
            term <- cnames[x]

            if (dimension==2){
                if (startsWith(term, "I(") == FALSE){next}
                tID <- as.integer(substring(term, 4, nchar(term)-3))
                if (tID == targetID){
                    targetX <- x
                    break
                }
            }
            if (dimension==1){
                if (startsWith(term, "T") == FALSE){next}
                tID<- as.integer(substring(term, 2))
                if (tID == targetID){
                    targetX <- x
                    break
                }
            }
        }
        return(targetX)
    }

    #************************************************
    #
    ..delta<-function(a,b,c){
        b^2-4*a*c
    }

    #************************************************
    #
    ..qSolver <- function(w1,w2,c){
        dt<- ..delta(w1,w2,c)
        if(dt > 0){ # first case D>0
            x_1 <- (-w2+sqrt(dt))/(2*w1)
            x_2 <- (-w2-sqrt(dt))/(2*w1)
            result <- c(x_1,x_2)
        }
        else if(dt == 0){ # second case D=0
            result <- -w2/(2*w1)
        }
        else {NaN} # third case D<0  "There are no real roots."
        #     result = -w2/(2*w1)
        # }
    }

    #************************************************
    # get intercepts from the model with P
    get_intercepts<- function(model, Plist, IDs, taskInfo){
        intercepts <- data.frame()
        for (P in Plist){
            items<- c()
            for(idx in 1:length(IDs)){
                yID <- IDs[idx]
                XID <- IDs[-idx]
                fx <- generate_line_function(model, P, yID, taskInfo$WCET.MIN[yID], taskInfo$WCET.MAX[yID])
                if (length(XID)==0){
                    value <- fx(0)
                }else{
                    value <- fx(taskInfo$WCET.MIN[XID])
                }
                # compliment the value
                value <- value[value <= taskInfo$WCET.MAX[yID]]
                value <- value[value >= taskInfo$WCET.MIN[yID]]
                value <- min(value)
                if (length(value)==0 || is.infinite(value)==TRUE){
                    value <- taskInfo$WCET.MAX[yID]
                }
                items <- c(items, ceiling(value))
            }
            intercepts<-rbind(intercepts, t(items))
        }
        colnames(intercepts)<- sprintf("T%d",IDs)
        rownames(intercepts)<- Plist
        return (intercepts)
    }

    #************************************************
    # complement intercepts: if there is nan or over the initial bound, we set initial bound
    complement_intercepts <- function(intercepts, taskIDs, task_info){
        for(tID in taskIDs){
            tname <- sprintf("T%d",tID)
            if (is.nan(intercepts[1,tname])==TRUE){
                intercepts[tname] <- task_info$WCET.MAX[[tID]]
            } else{
                intercepts[tname] <- min(ceiling(intercepts[[tname]]), task_info$WCET.MAX[[tID]])
            }
        }
        return (intercepts)
    }


    #############################################
    # calculate line function (for test)
    # This functions for the specific formula
    #############################################
    get_model_func_linear <- function(model, P){
        w <- as.double(model$coefficients)
        inter <- log(P/(1-P))
        f <- function(x){
            return (-1*((w[1] + w[3]*x + w[4]*x^2-inter)/(w[2] + w[5]*x)))
        }
        return(f)
    }

    get_model_func_quadratic <- function(model, P, minY, maxY){
        w <- as.double(model$coefficients)
        inter <- log(P/(1-P))
        f <- function(fX_value){
            a = w[4]
            b = w[3] + w[5]*fX_value
            c = w[1] + w[2]*fX_value - inter
            inV = (b^2)-(4*a*c)
            if (inV<0){
                return (Inf)
            }
            s1 = (-b + sqrt(inV)) / (2*a)
            s2 = (-b - sqrt(inV)) / (2*a)
            if (s1>=minY && s1 <=maxY){
                return (s1)
            } else if (s2>=minY && s2 <=maxY){
                return (s2)
            } else {
                return (0)
            }
        }
        return(f)
    }
}
