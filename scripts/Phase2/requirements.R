# Before install packages, please set a user library directory(R_LIBS_USER) in the "~/.Renviron" file.
#   - add "R_LIBS_USER=${user_libs_directory}"  for example, "R_LIBS_USER=~/R/3.6/"
# After that, execute this script:
#   $ RScript requirements.R

# libraries for executing SAFE
install.packages("MASS", repos="https://cloud.r-project.org/")
install.packages("dplyr", repos="https://cloud.r-project.org/")
install.packages("ggplot2", repos="https://cloud.r-project.org/")
install.packages("MLmetrics", repos="https://cloud.r-project.org/")
install.packages("randomForest", repos="https://cloud.r-project.org/")
install.packages("neldermead", repos="https://cloud.r-project.org/")
install.packages("stringr", repos="https://cloud.r-project.org/")
install.packages("magrittr", repos="https://cloud.r-project.org/")   # dependency of stringr
install.packages("cubature", repos="https://cloud.r-project.org/")


# for testing
install.packages("scales", repos="https://cloud.r-project.org/")
install.packages("effsize", repos="https://cloud.r-project.org/")
install.packages("progress", repos="https://cloud.r-project.org/")
install.packages("boot", repos="https://cloud.r-project.org/")
