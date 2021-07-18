# Title     : TODO
# Objective : TODO
# Created by: jaekwon.lee
# Created on: 5/25/21
if (Sys.getenv("JAVA_RUN", unset=FALSE)==FALSE) {
	suppressMessages(library(scales))
	suppressMessages(library(ggplot2))
	source("lib_data.R")
}

if (!Sys.getenv("DEV_LIB_DRAW", unset=FALSE)=="TRUE") {
	Sys.setenv("DEV_LIB_DRAW"=TRUE)
	cat("loading lib_draw.R...\n")
	
	
	generate_box_plot <- function(sample_points, x_col, y_col, type_col, x.title, y.title, nBox=20,
								  title="", ylimit=NULL, colorList=NULL, legend="rb",
								  legend_direct="vertical", legend_font=15, trans=NULL){
		
		# Draw them for each
		avg_results<- aggregate(sample_points[[y_col]], list(Iter=sample_points[[x_col]], Type=sample_points[[type_col]]), mean)
		colnames(avg_results) <- c(x_col, "Type", y_col)
		
		# change for drawing
		maxX <- max(sample_points[[x_col]])
		interval <- as.integer(maxX/nBox)
		samples <- sample_points[(sample_points[[x_col]]%%interval==0),]
		avgs <- avg_results[(avg_results[[x_col]]%%interval==0),]
		
		if(is.null(colorList)==TRUE){
			colorList <- cbPalette
		}
		fmt_dcimals <- function(digits=0){
			# return a function responpsible for formatting the
			# axis labels with a given number of decimals
			function(x) sprintf("%.4f", round(x,digits))
		}
		g <- ggplot(data=samples, aes(x=as.factor(samples[[x_col]]), y=samples[[y_col]], color=as.factor(samples[[type_col]]))) +  #, linetype=as.factor(samples[[type_col]])
			stat_boxplot(geom = "errorbar", width = 0.7, alpha=1, size=0.7) +
			stat_boxplot(geom = "boxplot", width = 0.7, alpha=1, size=0.7, outlier.shape=1, outlier.size=1) +
			geom_line( data=avgs, aes(x=as.factor(avgs[[x_col]]), y=avgs[[y_col]], color=as.factor(Type), group=as.factor(Type)), size=1, alpha=1)+
			theme_bw() +
			scale_colour_manual(values=colorList)+
			xlab(x.title) +
			ylab(y.title) +
			scale_y_continuous(labels = fmt_dcimals(digits=4)) +
			theme(axis.text=element_text(size=legend_font), axis.title=element_text(size=15))#,face="bold"
		
		if (legend=="rb"){
			g<- g+ theme(legend.justification=c(1,0), legend.position=c(0.999, 0.001), legend.direction = legend_direct, legend.title=element_blank(), legend.text = element_text(size=legend_font), legend.background = element_rect(colour = "black", size=0.2))
		}else if (legend=="rt"){
			g<- g+ theme(legend.justification=c(1,1), legend.position=c(0.999, 0.999), legend.direction = legend_direct, legend.title=element_blank(), legend.text = element_text(size=legend_font), legend.background = element_rect(colour = "black", size=0.2))
		} else if (legend=="lt"){
			g<- g+ theme(legend.justification=c(0,1), legend.position=c(0.001, 0.999), legend.direction = legend_direct, legend.title=element_blank(), legend.text = element_text(size=legend_font), legend.background = element_rect(colour = "black", size=0.2))
		} else if (legend=="lb"){
			g<- g+ theme(legend.justification=c(0,0), legend.position=c(0.001, 0.001), legend.direction = legend_direct, legend.title=element_blank(), legend.text = element_text(size=legend_font), legend.background = element_rect(colour = "black", size=0.2))
		} else{
			g<- g+ theme(legend.position = "none")
		}
		
		if (!is.null(trans)){
			g<- g+ scale_y_continuous(trans=trans)
		}
		
		if (!is.null(ylimit)){
			# g <- g + ylim(ylimit[[1]], ylimit[[2]])
			g <- g + coord_cartesian(ylim = c(ylimit[[1]], ylimit[[2]]))
		}
		if (title!=""){
			g <- g + ggtitle(title)
		}
		return (g)
	}


	generate_box_plot_part <- function(sample_points, x_col, y_col, type_col, x.title, y.title, nBox=20,
									   title="", ylimit=NULL, colorList=NULL, legend="rb",
									   legend_direct="vertical", legend_font=15, trans=NULL, part=NULL, part_breaks=NULL, y_precision=4){
		fmt_dcimals <- function(digits=0){
			# return a function responpsible for formatting the
			# axis labels with a given number of decimals
			function(x) sprintf("%.4f", round(x,digits))
		}

		# Draw them for each
		avg_results<- aggregate(sample_points[[y_col]], list(Iter=sample_points[[x_col]], Type=sample_points[[type_col]]), mean)
		colnames(avg_results) <- c(x_col, "Type", y_col)

		# change for drawing
		maxX <- max(sample_points[[x_col]])
		interval <- as.integer(maxX/nBox)
		samples <- sample_points[(sample_points[[x_col]]%%interval==0),]
		avgs <- avg_results[(avg_results[[x_col]]%%interval==0),]

		if(is.null(colorList)==TRUE) colorList <- cbPalette

		g <- ggplot(data=samples, aes(x=as.factor(samples[[x_col]]), y=samples[[y_col]], color=as.factor(samples[[type_col]]))) +
			stat_boxplot(geom = "errorbar", width = 0.7, alpha=1, size=0.7) +
			stat_boxplot(geom = "boxplot", width = 0.7, alpha=1, size=0.7, outlier.shape=1, outlier.size=1) +
			geom_line( data=avgs, aes(x=as.factor(avgs[[x_col]]), y=avgs[[y_col]], color=as.factor(Type), group=as.factor(Type)), size=1, alpha=1)+
			theme_bw() +
			scale_colour_manual(values=colorList)+
			xlab(x.title) +
			ylab(y.title) +
			theme(axis.text=element_text(size=legend_font), axis.title=element_text(size=15))#,face="bold"

		# control y scale
		if (!is.null(trans)){
			g<- g+ scale_y_continuous(trans=trans)
		}

		if (!is.null(ylimit)){
			g <- g + coord_cartesian(ylim = ylimit) # coord_cartesian limits range after drawing data
		}


		if(!is.null(part_breaks)){
			g <- g + scale_y_continuous(labels = fmt_dcimals(digits=y_precision), breaks=part_breaks)
		}else{
			g <- g + scale_y_continuous(labels = fmt_dcimals(digits=y_precision))
		}


		# put legend
		{
			if (legend=="rb"){
				g<- g+ theme(legend.justification=c(1,0), legend.position=c(0.999, 0.001), legend.direction = legend_direct, legend.title=element_blank(), legend.text = element_text(size=legend_font), legend.background = element_rect(colour = "black", size=0.2))
			}else if (legend=="rt"){
				g<- g+ theme(legend.justification=c(1,1), legend.position=c(0.999, 0.999), legend.direction = legend_direct, legend.title=element_blank(), legend.text = element_text(size=legend_font), legend.background = element_rect(colour = "black", size=0.2))
			} else if (legend=="lt"){
				g<- g+ theme(legend.justification=c(0,1), legend.position=c(0.001, 0.999), legend.direction = legend_direct, legend.title=element_blank(), legend.text = element_text(size=legend_font), legend.background = element_rect(colour = "black", size=0.2))
			} else if (legend=="lb"){
				g<- g+ theme(legend.justification=c(0,0), legend.position=c(0.001, 0.001), legend.direction = legend_direct, legend.title=element_blank(), legend.text = element_text(size=legend_font), legend.background = element_rect(colour = "black", size=0.2))
			} else{
				g<- g+ theme(legend.position = "none")
			}
		}

		if (is.null(y.title) || y.title==""){
			g<-g+theme(axis.title.y = element_blank())
		}
		# setting for part of graph
		tab_color<-"gray"
		tab_type<-4 # dot-dashed
		tab_size<-0.75
		if (is.null(part)==FALSE){
			g <- g+ theme(panel.border = element_blank())+
				annotate(geom = 'segment', x= Inf, xend = Inf, y = -Inf, yend = Inf, size=tab_size)+ # right
				annotate(geom = 'segment', x= -Inf, xend = -Inf, y = -Inf, yend = Inf, size=tab_size) # left

			if (part=="top"){
				g <- g+ theme(axis.text.x=element_blank(), axis.ticks.x=element_blank(), axis.title.x=element_blank())+
					annotate(geom = 'segment', x= -Inf, xend = Inf, y = Inf, yend = Inf, size=tab_size) + # top
					annotate(geom = 'segment', x= -Inf, xend = Inf, y = -Inf, yend = -Inf, size=tab_size, color=tab_color, linetype=tab_type) # bottom
			}else if (part=="middle"){
				g <- g+ theme(axis.text.x=element_blank(), axis.ticks.x=element_blank(), axis.title.x=element_blank())+
					annotate(geom = 'segment', x= -Inf, xend = Inf, y = Inf, yend = Inf, color=tab_color, size=tab_size, linetype=tab_type)+ # top
					annotate(geom = 'segment', x= -Inf, xend = Inf, y = -Inf, yend = -Inf, color=tab_color, size=tab_size, linetype=tab_type) # bottom
			}else{
				g <- g+ annotate(geom = 'segment', x= -Inf, xend = Inf, y = Inf, yend = Inf, color=tab_color, size=tab_size, linetype=tab_type)+ # top
					annotate(geom = 'segment', x= -Inf, xend = Inf, y = -Inf, yend = -Inf, size=tab_size) # bottom
			}
		}

		if (title!=""){
			g <- g + ggtitle(title)
		}
		return (g)
	}
	
	generate_box_plot_single <- function(sample_points, x_col, y_col, x.title, y.title, nBox=20,
										 title="", ylimit=NULL, colorList=NULL, axis_font=15, start=0){
		
		# Draw them for each
		#avg_results<- aggregate(sample_points[[y_col]], list(Iter=sample_points[[x_col]]), mean)
		maxX <- max(sample_points[[x_col]])
		avg_results<-data.frame()
		for(iter in c(start:maxX)){
			sub <- sample_points[sample_points[[x_col]]==iter & is.nan(sample_points[[y_col]])==FALSE,]
			avg_results<-rbind(avg_results, data.frame(x=iter, y=mean(sub[[y_col]])))
		}
		colnames(avg_results) <- c(x_col, y_col)
		
		# subsetting for drawing
		#maxX <- max(sample_points[[x_col]])
		interval <- as.integer(maxX/nBox)
		samples <- sample_points[(sample_points[[x_col]]%%interval==0),]
		avgs <- avg_results[(avg_results[[x_col]]%%interval==0),]
		
		# fcorder <- as.integer(unique(samples[[x_col]]))
		# fcorder <- fcorder[order(fcorder)]
		# samples[[x_col]] <- factor(samples[[x_col]], levels=fcorder)
		# avgs[[x_col]] <- factor(avgs[[x_col]], levels=fcorder)
		# print(samples)
		# print(avgs)
		
		if(is.null(colorList)==TRUE){
			colorList <- cbPalette
		}
		fmt_dcimals <- function(digits=0){
			# return a function responpsible for formatting the
			# axis labels with a given number of decimals
			function(x) sprintf("%.4f", round(x,digits))
		}
		g <- ggplot(data=samples, aes(x=as.factor(samples[[x_col]]), y=samples[[y_col]]) ) +
			stat_boxplot(geom = "errorbar", width = 0.7, alpha=1, size=0.7) +
			stat_boxplot(geom = "boxplot", width = 0.7, alpha=1, size=0.7, outlier.shape=1, outlier.size=1) +
			geom_line( data=avgs, aes(x=as.factor(avgs[[x_col]]), y=avgs[[y_col]], group=1), size=1, alpha=1)+
			theme_bw() +
			scale_colour_manual(values=colorList)+
			xlab(x.title) +
			ylab(y.title) +
			scale_y_continuous(labels = fmt_dcimals(digits=4)) +
			theme(axis.text=element_text(size=axis_font), axis.title=element_text(size=15))#,face="bold"
		
		if (!is.null(ylimit)){
			g <- g + ylim(ylimit[[1]], ylimit[[2]])
			# g <- g + coord_cartesian(ylim = c(ylimit[[1]], ylimit[[2]]))
		}
		if (title!=""){
			g <- g + ggtitle(title)
		}
		return (g)
	}
	
	compare_RQ2_results<- function(samples, x_col, y_col, type_col, types){
		# compare significant
		minIter <- min(samples[[x_col]])
		maxIter <- max(samples[[x_col]])
		# significantIter<-0
		comp_results<-data.frame()
		for(iter in c(minIter:maxIter)){
			sub <- samples[samples[[x_col]]==iter,]
			ret<-stats_function(sub, y_col, types[1], types[2], compCol=type_col)
			# if(ret$p>THRESHOLD_P)
			# 	significantIter <- iter +1   # assume next model will be significant if not, it increases
			comp_results<-rbind(comp_results, data.frame(nUpdate=iter, p=ret$p, magnitude=ret$magnitude, A12=ret$A12))
		}
		return (comp_results)
	}
	
	generate_significant_plot <- function(results, THRESHOLD_P=0.05,
										  x_title="", y_title="", font_size=15)
	{
		# compare significant
		g<- ggplot(results, aes(x=nUpdate, y=p)) + geom_line() +
			xlab(x_title)+
			ylab(y_title)+
			theme_bw()+
			theme(axis.text=element_text(size=font_size),#, face="bold"),
				  axis.title=element_text(size=font_size),#, face="bold"),
				  legend.position="none",
				  plot.margin=margin(5, 5, 5, 5))
		
		significantIter<-min(results[results$p<=THRESHOLD_P,]$nUpdate)
		maxIter <- max(results$nUpdate)
		xPoint <- (maxIter + min(results$nUpdate)) / 2
		if (significantIter>0 & significantIter<maxIter){
			g<- g+geom_text(x=xPoint, y=0.5, label=sprintf("Significant after %d model refinements",significantIter),
					  color="black", hjust=0.5,
					  size=5 , angle=0)
		}
		return(g)
	}
	
}