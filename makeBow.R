# 1. Define function
library(tm)

goodWords <- c("why", "your","who","what","why","when","does","do","how","where","would","no","do")
stopWords <- stopwords("english")[!(stopwords("english") %in% goodWords)]
makeBow <- function(column, x=all, sparsity=.999) {
    corpus <- Corpus(VectorSource(x[,column]))
    corpus <- tm_map(corpus, tolower)
    corpus <- tm_map(corpus, PlainTextDocument)
    corpus <- tm_map(corpus, removePunctuation)
    corpus <- tm_map(corpus, removeWords, stopWords)
#    corpus <- tm_map(corpus, removeWords, stopwords("english"))
    corpus <- tm_map(corpus, stemDocument)
    dtm <- DocumentTermMatrix(corpus)
    dtm <- removeSparseTerms(dtm, sparsity)
    df <- as.data.frame(as.matrix(dtm), row.names=F)
    colnames(df) <- paste0(substr(column,1,1), colnames(df))
    return(df)
}

