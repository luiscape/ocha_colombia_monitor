## Very simple script to adapt the p-codes at a national level to 
## CPS-like codes. 
CPSify <- function(df, country = NULL) {
    if (is.null(country) == TRUE) { stop('Please provide a 3 letter ISO3 code.') }
    else df$region <- paste(country, "-", df$region, sep = "")
    df
}