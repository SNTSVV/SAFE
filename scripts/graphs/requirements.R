# Before install packages, please set a user library directory(R_LIBS_USER) in the "~/.Renviron" file.
#   - add "R_LIBS_USER=${user_libs_directory}"  for example, "R_LIBS_USER=~/R/3.6/"
# After that, execute this script:
#   $ RScript requirements.R

# libraries for executing SAFE
install.packages("MASS", repos="https://cloud.r-project.org/")
install.packages("dplyr", repos="https://cloud.r-project.org/")
install.packages("ggplot2", repos="https://cloud.r-project.org/")
install.packages("MLmetrics", repos="https://cloud.r-project.org/")
install.packages("stringr", repos="https://cloud.r-project.org/")
install.packages("randomForest", repos="https://cloud.r-project.org/")
install.packages("nloptr", repos="https://cloud.r-project.org/")    # neldermead
install.packages("scales", repos="https://cloud.r-project.org/")

# for graphs
install.packages("gridExtra", repos="https://cloud.r-project.org/") # for grid.arrange
install.packages("effsize", repos="https://cloud.r-project.org/")
install.packages("latex2exp", repos="https://cloud.r-project.org/")
