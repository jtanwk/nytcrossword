# 24 Years of NYTimes Crossword answers

September 2, 2017

[View the notebook here](https://jtanwk.github.io/nytcrossword/)

## Description

Exploratory data analysis of 24 years of New York Times Crossword answers. I use data visualization and computational linguistics concepts to discover trends in the Shortz-era puzzles (1994 - present).

Questions include:
-   What are the most common answers?
-   Are words getting longer? Shorter?
-   How does puzzle letter density vary by day?
-   What words have emerged in the crossword only in the past few years?
-   How lexically diverse are the puzzles?

## Dependencies

-   `tidyverse` for everything
-   `plyr` for data wrangling
-   `here` for OS-agnostic file paths
-   `tidytext` for text analysis methods
-   `stringr` for string-manipulation operations
-   `viridis` for a simple, colorblind-friendly palette

## Data Sources

The original dataset for this project was scraped from XWordInfo.com. Upon their request, however, I have taken down my scraper code and removed the dataset from this repository. [Read the notebook for more details](https://jtanwk.github.io/nytcrossword/).
