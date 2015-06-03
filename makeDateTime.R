library(timeDate)
makeDateTime <- function(x=all) {
    s <- x$PubDate
    t <- strptime(s, "%Y-%m-%d %H:%M:%S")
    bz <- isBizday(as.timeDate(t)) * 1
    wkd <- weekdays(t)
    hour <- t$hour
    df <- data.frame(
        weekday = factor(wkd),
        hourBin = cut(hour, 6),
#        hour = factor(hour),
        bizdate = factor(bz)
        )
    return(df)
}
