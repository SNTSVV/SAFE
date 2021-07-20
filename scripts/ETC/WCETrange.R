# last_updated: 2020-02-09
# authors: Jaekwon Lee
# Visualizing deadline miss
#
PROJECT_PATH <- "~/projects/RTA_SAFE"
CODE_PATH <- sprintf("%s/scripts", PROJECT_PATH)
setwd(CODE_PATH)
library(ggplot2)
setwd(CODE_PATH)

maxData <- read.csv(sprintf("%s/results/minWCET.csv",PROJECT_PATH), header=TRUE)

cbPalette <- c("#000000", "#AAAAAA", "#F8766D", "#00BE67", "#C77CFF", "#00A9FF")
subs <- c("ICS", "CCS", "UAV", "GAP", "HPSS")
maxData$Subject<-factor(maxData$Subject, levels=subs)

ggplot(maxData, aes(x=Percentage, y=Probability, color=Subject))+
    geom_line()+
    scale_color_manual(values = cbPalette) +
    ylab("Probability of deadline miss")+xlab("Ratio for maximum WCET")+
    theme(axis.text = element_text(size=14),
          axis.title = element_text(face="bold", size=14),
          legend.justification=c(1,0),
          legend.position=c(0.999, 0.001),
          legend.direction = "vertical",
          legend.title=element_blank(),
          legend.text = element_text(size=14),
          legend.background = element_rect(colour = "black", size=0.2))
