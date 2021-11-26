
df <- data.frame(Code="c", value=c(1000,10000,10000,1000000,248,1234,588))

# write results
df$value <- format(df$value, scientific = FALSE)
df
write.table(df, file="testfile.csv", append=FALSE, sep=",", dec= ".", row.names = FALSE, col.names = TRUE, quote=FALSE)

options(scipen=999)
write.table(df, file="testfile.csv", append=FALSE, sep=",", dec= ".", row.names = FALSE, col.names = TRUE)
options(scipen=0)