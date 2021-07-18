# Title     : TODO
# Objective : TODO
# Created by: jaekwon.lee
# Created on: 4/20/21
suppressMessages(library(effsize))

load_multi_files<-function(basePath, SUBJS,APPRS, fileformat){
	total <- data.frame()
	for(subject in SUBJS){
		for (approach in APPRS){
			item<-read.csv(sprintf(fileformat,basePath, subject, approach), header=TRUE)
			total <- rbind(total, data.frame(Subject=subject, Approach=approach, item))
		}
	}
	return (total)
}

change_factor_names<- function(listitems, from, to){
	listitems<-as.character(listitems)
	for (idx in c(1:length(from))){
		listitems<-ifelse(listitems==from[idx], to[idx], listitems)
	}
	listitems <- factor(listitems, levels = to)
	return (listitems)
}

stats_function<-function(item, col, comp1, comp2, compCol="Approach", reverse=FALSE){
	ga<- item[as.character(item[[compCol]])==comp1,][[col]]
	gb<- item[as.character(item[[compCol]])==comp2,][[col]]
	if (length(ga)!=length(gb)){
		size<-min(length(ga), length(gb))
		ga<-ga[1:size]
		gb<-gb[1:size]
		print(sprintf("Reduced the size of array into : %d", size))
	}
	w <- wilcox.test(ga, y = gb)#, alternative = c("two.sided"))
	if (reverse == TRUE){
		vda<- VD.A(gb,ga)
	}else{
		vda<- VD.A(ga,gb)
	}
	ret <- list()
	ret[["p"]] <- w$p.value
	ret[["A12"]] <- vda$estimate
	ret[["magnitude"]] <- vda$magnitude
	return(ret)
}
