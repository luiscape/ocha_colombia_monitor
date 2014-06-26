#!/usr/bin/Rscript

### Exploring the OCHA Colombia API
library(RCurl)
library(rjson)
library(sqldf)

# reading data into a data.frame
getData <- function(url = 'http://violenciaarmada.colombiassh.org/av/syncToSidih/73400') { 
    url <- 
    json_out <- fromJSON(getURL(url))
    for (i in 1:length(json_out)) { 
        if (i == 1) z <- json_out[[i]]
        else z <- rbind(z, json_out[[i]])
    }
    z <- data.frame(z)
    z
}
raw_data <- suppressWarnings(getData())

# Loading p-codes
pcodes <- read.csv('code/data/pcodes.csv', fileEncoding = 'latin1')
colnames(pcodes)[1] <- 'id_muns'

# class standard
data2 <- data.frame(lapply(data, as.character), stringAsFactors = FALSE)

# counting incidents
incidents_mun <- data.frame(table(data2$id_muns))
names(incidents_mun) <- c('region', 'value')
# incidents_muns2 <- merge(incidents_mun, pcodes, by = 'id_muns')

source('code/write_tables.R')
data <- fetchRawData()

## Preparing for CPS. 
# Creating the value table.
value <- incidents_mun
value$dsID <- 'ocha_colombia_monitor'
value$indID <- 'COL001'
value$period <- '2014'
value$source <- 'http://violenciaarmada.colombiassh.org/av/syncToSidih/'
source('code/is_number.R')
value <- isNumber(value)
source('pcode_to_cps.R')
value <- CPSify(value, 'COL')

# Creating the indicator table.
indID <- 'COL001'  # non-standard name
name <- 'Violence Incidents'
units <- 'Count'
indicator <- data.frame(indID, name, units)


# Creating the dataset table.
dsID <- 'ocha_colombia_monitor'
last_updated <- as.character(summary(as.POSIXct(data2$fecha_evento))[6])
last_scraped <- Sys.time()
name <- 'OCHA Colombia Monitor'
dataset <- data.frame(dsID, last_updated, last_scraped, name)

# incidents_dep <- data.frame(table(incidents_muns2$adm1_pcode))
# names(incidents_dep) <- c('adm1_pcode', 'violence_incidents_dep')
# incidents_dep2 <- merge(incidents_dep, incidents_muns2, by = 'adm1_pcode')

source('code/write_tables.R')
WriteTables()