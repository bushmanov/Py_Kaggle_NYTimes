makeQM <- function(column = "Headline", data=all) {
    vec <- sapply(strsplit(data[,column], ","), function(x) {sum((grepl("\\?", x))*1)})
    return(data.frame(questionMark = factor(vec)))
}

#
# df <- makeQM()
# head(df)
