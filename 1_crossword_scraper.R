# NYT Crossword Analysis
# Using puzzles scraped from https://www.xwordinfo.com/
# Shortz Era: 11/21/1993 - Present 

# File 1 - Scraper

# Setup
library(tidyverse)
library(tidytext)
library(stringr)
library(rvest)

options(stringsAsFactors = FALSE)

##############################
########## SCRAPING ##########
##############################

## initialize data frame
cw <- data.frame(title = character(),
                 subtitle = character(),
                 year = numeric(),
                 month = numeric(),
                 day = numeric(),
                 author = character(),
                 rowcolcount = character(),
                 wordcount = numeric(),
                 spancount = numeric(),
                 blockcount = numeric(),
                 missing = character(),
                 dir = character(),
                 word = character())

## looping over pages

for (year in 1994:2017) {
  for (month in 1:12) {
    for (day in 1:31) {
      cwurl <- read_html(paste("https://www.xwordinfo.com/Crossword?date=", month, "/", day, "/", year, sep = ""))
      print(paste(year, month, day, sep = "-"))
      
      author <- cwurl %>%
        html_nodes("#CPHContent_aetable tr:nth-child(1) td:nth-child(2)") %>%
        html_text()
      if (is_empty(author)) {
        author <- ""
      }
      
      rowcolcount <- cwurl %>%
        html_nodes(".entity:nth-child(1)") %>%
        html_text()
      if (is_empty(rowcolcount)) {
        rowcolcount <- ""
      }
      
      wordcount <- cwurl %>%
        html_nodes("#CPHContent_StatsData :nth-child(2) :nth-child(1)") %>%
        html_text() %>%
        str_replace_all("Words: ", "") %>%
        as.numeric()
      if (is_empty(rowcolcount)) {
        rowcolcount <- ""
      }
      
      spancount <- cwurl %>%
        html_nodes("#CPHContent_StatsData :nth-child(4) .nobreak") %>%
        html_text() %>%
        str_replace_all("Spans: ", "") %>%
        as.numeric()
      if (is_empty(spancount)) {
        spancount <- ""
      }
      
      blockcount <- cwurl %>%
        html_nodes(".nobreak:nth-child(2)") %>%
        html_text() %>%
        str_replace_all("Blocks: ", "") %>%
        as.numeric()
      if (is_empty(blockcount)) {
        blockcount <- ""
      }
      
      missing <- cwurl %>%
        html_nodes("#CPHContent_StatsData :nth-child(3) span") %>%
        html_text()
      if (is_empty(missing)) {
        missing <- ""
      }
      
      across <- cwurl %>%
        html_nodes("#CPHContent_tdAcrossClues a") %>%
        html_text()
      if (is_empty(across)) {
        across <- ""
      }
      
      down <- cwurl %>%
        html_nodes("#CPHContent_tdDownClues a") %>%
        html_text()
      if (is_empty(down)) {
        down <- ""
      }
      
      for (i in 1:length(across)) {
        dir <- "Across"
        word <- across[i]
        
        cw <- rbind(cw, 
                    data.frame(year, month, day, author, rowcolcount, wordcount, spancount, blockcount, missing, dir, word))
      }
      
      for (i in 1:length(down)) {
        dir <- "Down"
        word <- down[i]
        
        cw <- rbind(cw, 
                    data.frame(year, month, day, author, rowcolcount, wordcount, spancount, blockcount, missing, dir, word))
      }
    }
  }
  
  # saves one year of data
  write.csv(cw, file = paste("crosswords_", year, ".csV", sep = ""))
  
  # resets the data frame
  cw <- data.frame(title = character(),
                   subtitle = character(),
                   year = numeric(),
                   month = numeric(),
                   day = numeric(),
                   author = character(),
                   rowcolcount = character(),
                   wordcount = numeric(),
                   spancount = numeric(),
                   blockcount = numeric(),
                   missing = character(),
                   dir = character(),
                   word = character())
}

##############################
########## MERGING ###########
##############################

## Annual data needs to be merged into one set

crossword <- read.csv("crosswords_1994.csv")

for (i in 1995:2017) {
  nextyear <- read.csv(paste("crosswords_", i, ".csV", sep = ""))
  crossword <- rbind(crossword, nextyear)
  print(i)
}

write.csv(crossword, file = "full_crosswords.csv")


##############################
########## CLEANING ##########
##############################

## Drop row numbers that got transformed into variables
crossword$X <- NULL

## Split row and column count variables
crossword <- crossword %>%
  bind_cols(reshape2::colsplit(crossword$rowcolcount, ",", c("rowcount", "colcount")))
crossword$rowcount <- crossword$rowcount %>%
  str_replace_all("Rows: ", "") %>%
  as.numeric()
crossword$colcount <- crossword$colcount %>%
  str_replace_all("Columns: ", "") %>%
  as.numeric()
crossword$rowcolcount <- NULL

## Replace NAs in spancount with 0s
crossword$spancount[is.na(crossword$spancount)] <- 0

## convert YMD to date and get day of week
crossword$cwdate <- as.Date(paste(crossword$year, crossword$month, crossword$day, sep = "-"), format = "%Y-%m-%d")
crossword$cwday <- weekdays(crossword$cwdate)

write.csv(crossword, file = "clean_crosswords.csv")