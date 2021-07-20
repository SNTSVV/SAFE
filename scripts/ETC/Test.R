# Title     : TODO
# Objective : TODO
# Created by: jaekwon.lee
# Created on: 4/8/21

# last_updated: 2020-02-09
# authors: Jaekwon Lee
# Visualizing deadline miss
#
PROJECT_PATH = "~/projects/RTA_SAFE"
CODE_PATH <- sprintf("%s/scripts", PROJECT_PATH)
setwd(CODE_PATH)
library(ggplot2)
setwd(CODE_PATH)

old <- read.csv("~/projects/SAFE_pub/results/ESAIL/Run05/test_result.txt", header = TRUE)
new <- read.csv("~/projects/RTA_SAFE/results/TOSEM_20a/ESAIL/Run05/test_result.txt", header = FALSE)
dsize<-min(nrow(old), nrow(new))
old <- old[1:dsize,]
new <- new[1:dsize,]
colnames(old)<- c("wID", "solutionID", "result")
colnames(new)<- c("wID", "solutionID", "result")

for (x in 1:nrow(old)){
  if (old[x,]$wID==new[x,]$wID && old[x,]$solutionID==new[x,]$solutionID &&
    old[x,]$result==new[x,]$result) next
  cat(sprintf("old(%d, %d, %d) == new(%d, %d, %d) :: %s\n",
          old[x,]$wID, old[x,]$solutionID, old[x,]$result,
              new[x,]$wID, new[x,]$solutionID, new[x,]$result,))
}



cbPalette <- c("#000000", "#AAAAAA","#F8766D", "#00BE67", "#C77CFF", "#00A9FF")
subs <- c("ICS", "CCS", "UAV", "GAP", "HPSS")
minData$Percentage <- minData$Percentage * -1
minData$Subject<-factor(minData$Subject, levels=subs)
maxData$Subject<-factor(maxData$Subject, levels=subs)

ggplot(minData, aes(x=Percentage, y=Probability, color=Subject))+
  geom_line()+
  scale_color_manual(values = cbPalette) +
  ylab("Probability of deadline miss")+xlab("Ratio for minimum WCET")+
  theme(axis.text = element_text(size=14),
        axis.title = element_text(face="bold", size=14),
        legend.justification=c(0,1),
        legend.position=c(0.001, 0.999),
        legend.direction = "vertical",
        legend.title=element_blank(),
        legend.text = element_text(size=14),
        legend.background = element_rect(colour = "black", size=0.2))


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

ggplot(minData, aes(x=Percentage, y=Probability, color=Subject))+
  geom_line()+
  scale_color_manual(values = cbPalette) +
  ylab("Probability of deadline miss")+xlab("Ratio for minimum WCET")+
  ylim(0.0, 0.01)+
  theme(axis.text = element_text(size=14),
        axis.title = element_text(face="bold", size=14),
        legend.justification=c(0,1),
        legend.position=c(0.001, 0.999),
        legend.direction = "vertical",
        legend.title=element_blank(),
        legend.text = element_text(size=14),
        legend.background = element_rect(colour = "black", size=0.2))

