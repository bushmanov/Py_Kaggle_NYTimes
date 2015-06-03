library(stringi)

makeNW<- function(columns = c("Headline", "Abstract"), data=all) {
    headNW <- sapply(all[,columns[1]], function(x) {stri_stats_latex(x)[[4]]})
    abNW   <- sapply(all[,columns[2]], function(x) {stri_stats_latex(x)[[4]]})
    return(data.frame(headlineNW = headNW, abstractNW = abNW))
}

# df <- makeNW()
# hist(df$abstractNW)
# head(df)
# t.test(df[train$Popular ==1,1], df[train$Popular ==0, 1])
# t.test(df[train$Popular ==1,2], df[train$Popular ==0, 2])
