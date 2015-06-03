BigramTokenizer <- function(x){NGramTokenizer(x, Weka_control(min = 2, max = 2))}
# column = "Headline"
# x= all
# sparsity =.999
goodWords <- c("why", "your","who","what","why","when","does","do","how","where","would","no","do")
stopWords <- stopwords("english")[!(stopwords("english") %in% goodWords)]
makeBigram <- function(column, x=all, sparsity=.999) {
    corpus <- Corpus(VectorSource(x[,column]))
    corpus <- tm_map(corpus, tolower)
    corpus <- tm_map(corpus, PlainTextDocument)
    corpus <- tm_map(corpus, removePunctuation)
    corpus <- tm_map(corpus, removeWords, stopWords)
    corpus <- tm_map(corpus, stemDocument)
    dtm <- DocumentTermMatrix(corpus, control = list(tokenize = BigramTokenizer))
    dtm <- removeSparseTerms(dtm, sparsity)
    df <- as.data.frame(as.matrix(dtm), row.names=F)
    colnames(df) <- paste0(substr(column,1,1), gsub("[[:space:]]", "", colnames(df)))
    return(df)
}

# bigram <- makeBigram("Headline")
# dim(bigram)
# # [1] 8402  134
#
# bigramA <- makeBigram("Abstract")
# dim(bigramA)
# # [1] 8402  477
#
# sum(names(bigram) %in% names(bigramA))
# # [1] 45
# sum(names(bigramA) %in% names(bigram))
# # [1] 45
