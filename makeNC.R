makeNC <- function(columns = c("Headline", "Abstract"), data = all) {
    head <- data[,columns[1]]
    abstr <- data[, columns[2]]
    hchars <- sapply(head, nchar)
    abchars <- sapply(abstr, nchar)
    return(data.frame(headlineNChars = hchars, abstractNChars = abchars))
}
#
# df <- makeNC()
# hist(log(.001 + df$abstractNChars))
# t.test(df[train$Popular ==1,1], df[train$Popular ==0, 1])
# t.test(df[train$Popular ==1,2], df[train$Popular ==0, 2])
