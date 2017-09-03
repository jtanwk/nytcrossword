# NYT Crossword Analysis
# Using puzzles scraped from https://www.xwordinfo.com/
# Shortz Era: 11/21/1993 - Present 

# File 2 - Full Analysis

# Setup
library(tidyverse)
library(tidytext)
library(stringr)

options(stringsAsFactors = FALSE)

##############################
########## ANALYSIS ##########
##############################

crossword <- read.csv("clean_crosswords.csv") %>%
  as.tbl() %>%
  distinct()

##### What are the most common answers?

crossword %>%
  count(word, sort = TRUE) %>%
  top_n(5) # ERA is the most common answer, followed by AREA, ERE, ONE, and ELI

## Plotting above by year

crossword %>%
  filter(word == "ERA" | word == "AREA" | word == "ERE" | word == "ONE" | word == "ELI") %>%
  count(year, word, sort = TRUE) %>%
  ggplot(aes(x = year, y = n)) +
  geom_point() +
  geom_smooth(method = 'lm') +
  facet_wrap(~word, ncol = 2)

##### Are words getting longer? Shorter?

crossword %>%
  group_by(year) %>%
  summarise(avg = mean(nchar(word)), sort = TRUE) %>%
  ggplot(aes(x = year, y = avg)) +
  geom_point() +
  geom_smooth(method = 'lm')

## Plotting the above by day of the week, ordered:

crossword %>%
  filter(cwday != "NA") %>%
  mutate(cwday = factor(cwday, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
  group_by(year, cwday) %>%
  summarise(avg = mean(nchar(word)), sort = TRUE) %>%
  arrange(desc(avg)) %>%
  ggplot(aes(x = year, y = avg, color = cwday)) +
  geom_point() +
  geom_smooth(method = 'lm') +
  facet_wrap(~cwday, nrow = 1)


##### What are the most year-specific words? 

year_words <- crossword %>%
  count(year, word, sort = TRUE) %>%
  ungroup() %>%
  bind_tf_idf(word, year, n) %>%
  arrange(desc(tf_idf))

year_words

## Plotting above by year:

plot_year_words <- year_words %>%
  mutate(word = factor(word, levels = rev(unique(word))))

plot_year_words %>%
  filter(year >= 2013) %>%
  group_by(year) %>%
  top_n(5) %>%
  ungroup %>%
  ggplot(aes(x = word, y = tf_idf, fill = year)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~year, ncol = 2, scales = "free") +
  coord_flip() +
  labs(x = NULL, y = NULL)

## Plotting above by word-year:

crossword %>%
  filter(word == "BAE" | word == "LGBT" | word == "IDRISELBA" | word == "ABBACY" | word == "ETSY" | word == "NSFW") %>%
  mutate(word = factor(word, levels = c("BAE", "LGBT", "IDRISELBA", "ABBACY", "ETSY", "NSFW"))) %>%
  count(year, word, sort = TRUE) %>%
  ggplot(aes(x = year, y = n, fill = word)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~word, ncol = 2) +
  labs(x = NULL, y = "Word Appearance Frequency")

########## Unanswered questions:

## What first names appear most often? Gender representation?
## What are the most common foreign languages in the puzzle? 
## Do certain authors submit more often on some days?
## What cities appear most often? Are some countries/continents represented unexpectedly frequently?

