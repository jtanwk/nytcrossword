# NYT Crossword Analysis
# Using puzzles scraped from https://www.xwordinfo.com/
# Shortz Era: 11/21/1993 - Present 

# File 2 - Full Analysis

# Setup
library(tidyverse)
library(tidytext)
library(stringr)
library(viridis) # colorblind-friendly palettes for charts

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
  filter(word %in% c("ERA", "AREA", "ERE", "ONE", "ELI")) %>%
  group_by(year) %>%
  count(year, word, sort = TRUE) %>%
  ggplot(aes(x = year, y = n)) +
  geom_point() +
  geom_smooth(method = 'lm',
              fill = NA) +
  facet_wrap(~word) +
  theme_bw() +
  scale_x_continuous(breaks = seq(1996, 2016, 4)) +
  labs(y = "Number of Appearances",
       x = "Year",
       title = "Appearance Frequency of Top 5 NYTimes Crossword Answers", 
       subtitle = "Using puzzles from the Shortz Era (1994-2017)")

ggsave("images/cw_top5_freq.png", width = 8, height = 6)

##### Are words getting longer? Shorter?

crossword %>%
  mutate(cwdate = as.Date(cwdate)) %>%
  group_by(cwdate) %>%
  summarise(avg = mean(nchar(word))) %>%
  ggplot(aes(x = cwdate, y = avg)) +
  geom_point(alpha = 0.1) +
  geom_smooth(method = 'lm',
              color = "red",
              size = 1.2,
              fill = NA) +
  theme_minimal() +
  scale_y_continuous(breaks = seq(4, 8, 0.5)) +
  labs(x = "Date", 
       y = "Average Letter Count",
       title = "Average Length of NYTimes Crossword Answers",
       subtitle = "Using puzzles from the Shortz Era (1994-2017). Each point represents one crossword puzzle.")

ggsave("images/cw_avglength.png", width = 8, height = 6)

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

## Revised version of above with feedback:

crossword %>%
  filter(cwday != "NA") %>%
  mutate(cwday = factor(cwday, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
  mutate(cwdate = as.Date(cwdate)) %>%
  group_by(cwdate, cwday) %>%
  summarise(avg = mean(nchar(word))) %>%
  ggplot(aes(x = cwdate, y = avg)) +
  geom_point(aes(color = cwday),
             show.legend = FALSE,
             alpha = 0.3) +
  scale_color_viridis(discrete = TRUE, option = "viridis") +
  geom_smooth(color = "black",
              size = 1.1,
              method = 'lm', 
              fill = NA) +
  facet_wrap(~cwday, nrow = 1) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 60, hjust = 1)) +
  scale_x_date(date_labels = "%Y",
               date_breaks = "4 years",
               date_minor_breaks = "4 years") +
  scale_y_continuous(breaks = seq(4, 8, 0.5)) +
  labs(x = "Date", 
       y = "Average Letter Count",
       title = "Average Length of NYTimes Crossword Answers by Day",
       subtitle = "Using puzzles from the Shortz Era (1994-2017). Each point represents one crossword puzzle, by day of the week.")

ggsave("images/cw_avglength_byday.png", width = 8, height = 6)

## Histogram of answer length by day

crossword %>%
  filter(cwday != "NA") %>%
  filter(nchar(word) <= 21) %>%
  mutate(cwday = factor(cwday, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
  ggplot(aes(x = nchar(word))) +
  geom_histogram(binwidth = 1) +
  facet_wrap(~cwday, nrow = 1) +
  theme_minimal() +
  labs(y = "Number of Answers",
       x = "Number of Letters in Answer",
       title = "Histogram of NYTimes Crossword Answers by Number of Letters",
       subtitle = "Using puzzles from the Shortz Era (1994-2017). Histograms are grouped by day of the week.")

ggsave("images/cw_length_hist.png", width = 8, height = 6)

## Above, but represented by boxplots instead

crossword %>%
  filter(cwday != "NA") %>%
  mutate(cwday = factor(cwday, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
  mutate(wordlength = nchar(word)) %>%
  ggplot(aes(x = cwday, y = wordlength)) +
  geom_boxplot() +
  theme_minimal() +
  labs(x = "Day of the Week",
       y = "Number of Letters in Answer",
       title = "Distribution of Answer Lengths by Day of the Week",
       subtitle = "Using puzzles from the Shortz Era (1994-2017). Each point is a single crossword answer.")

ggsave("images/cw_length_box.png", width = 8, height = 6)

## Identifying the crosswords with the longest and shortest average answer length:

crossword %>%
  group_by(cwdate) %>%
  summarise(avg = mean(nchar(word))) %>%
  arrange(-avg)

  # Shortest avg answer length: 2008-12-23
  # Longest avg answer length: 2006-01-21

## Does the number of blocks decrease by day, then? 

puzzles <- crossword %>%
  select(-c(X, dir, word)) %>%
  distinct()

puzzles %>%
  filter(cwday != "NA") %>%
  mutate(cwday = factor(cwday, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
  mutate(cwdate = as.Date(cwdate)) %>%
  select(cwdate, cwday, blockcount, spancount) %>%
  ggplot(aes(x = cwdate, y = blockcount)) +
  geom_point(aes(color = cwday),
             show.legend = FALSE,
             alpha = 0.3) +
  scale_color_viridis(discrete = TRUE, option = "viridis") +
  geom_smooth(color = "black",
              size = 1.1,
              method = 'lm', 
              fill = NA) +
  facet_wrap(~cwday, nrow = 1) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 60, hjust = 1)) +
  scale_x_date(date_labels = "%Y",
               date_breaks = "4 years",
               date_minor_breaks = "4 years") +
  scale_y_continuous(breaks = seq(10, 160, 20)) +
  labs(x = "Day of the Week",
       y = "Number of blocks in puzzle",
       title = "Number of \"Blocks\" (Unused Spaces) by Day of the Week",
       subtitle = "Using puzzles from the Shortz Era (1994-2017). Each point is a single crossword answer.")

## Which puzzles had the least and most blocks?

puzzles %>%
  group_by(cwdate) %>%
  arrange(-blockcount)

  # Fewest blocks: 2012-07-27, 17 blocks
  # Most blocks: 2011-05-29, 141 blocks
  # From this, we can calculate puzzle density = number of letters on grid / total grid space

puzzles %>%
  mutate(density = ((rowcount * colcount) - blockcount) / (rowcount * colcount)) %>%
  filter(cwday != "NA") %>%
  mutate(cwday = factor(cwday, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
  mutate(cwdate = as.Date(cwdate)) %>%
  select(cwdate, cwday, density) %>%
  ggplot(aes(x = cwdate, y = density)) +
  geom_point(aes(color = cwday),
             show.legend = FALSE,
             alpha = 0.3) +
  scale_color_viridis(discrete = TRUE, option = "viridis") +
  geom_smooth(color = "black",
              size = 1.1,
              method = 'lm', 
              fill = NA) +
  facet_wrap(~cwday, nrow = 1) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 60, hjust = 1)) +
  scale_x_date(date_labels = "%Y",
               date_breaks = "4 years",
               date_minor_breaks = "4 years") +
  labs(x = "Day of the Week",
       y = "Letter Density",
       title = "Letter Density (Letters per Grid Space) by Day of the Week",
       subtitle = "Using puzzles from the Shortz Era (1994-2017). Each point is a single crossword answer.")

ggsave("images/cw_density_byday.png", width = 8, height = 6)


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
  ggplot(aes(x = word, y = tf_idf)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~year, ncol = 2, scales = "free") +
  coord_flip() +
  labs(x = NULL, y = NULL) +
  theme_minimal() +
  labs(title = "Most Year-Unique Crossword Answers, 2013-2017",
       subtitle = "As determined by tf-idf scores for single-year corpora.")

ggsave("images/cw_tf_idf.png", width = 8, height = 6)

## Plotting above by word-year:

crossword %>%
  filter(word %in% c("BAE", "LGBT", "IDRISELBA", "ABBACY", "ETSY", "NSFW")) %>%
  mutate(word = factor(word, levels = c("BAE", "LGBT", "IDRISELBA", "ABBACY", "ETSY", "NSFW"))) %>%
  count(year, word, sort = TRUE) %>%
  ggplot(aes(x = year, y = n)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = n), vjust = 1.25, color = "white") +
  facet_wrap(~word, ncol = 2) +
  labs(x = NULL, 
       y = "Number of Appearances",
       title = "Appearance Frequency for 2017's \"Important\" Answers",
       subtitle = "As determined by tf-idf scores for single-year corpora.")

ggsave("images/cw_tf_idf_2017.png", width = 8, height = 6)

## Use below command to find exact dates for clue lookups:

crossword %>%
  filter(word == "SIRI") %>%
  count(year)


########## Unanswered questions:

## What first names appear most often? Gender representation?
## What are the most common foreign languages in the puzzle? 
## Do certain authors submit more often on some days?
## What cities appear most often? Are some countries/continents represented unexpectedly frequently?

