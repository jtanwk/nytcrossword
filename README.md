24 Years of NYTimes Crossword Answers
================
September 2, 2017

-   [Getting The Data](#getting-the-data)
-   [Some Questions](#some-questions)
    -   [What are the most common answers?](#what-are-the-most-common-answers)
    -   [Are words getting longer? Shorter?](#are-words-getting-longer-shorter)
    -   [What words have emerged recently?](#what-words-have-emerged-recently)
-   [Summary](#summary)
-   [Further Steps](#further-steps)

I do the New York Times crossword pretty much every day. 90% of the time, I'll tackle it before the day actually arrives (they launch at 11pm the night before, except Sunday's, which launches at 6pm on Saturday). It's the closest thing I have to an evening ritual.

Other people have already done pretty cool explorations of crossword text data. They've looked at at comparisons to the [Oxford English Dictionary](http://blog.nycdatascience.com/student-works/web-scraping/nyt-crossword-puzzle-approximately-cool-oed/) and the [Google Books](https://noahveltman.com/crossword/about.html) corpuses (corpi?) respectively. My favorite: last year, the NYTimes themselves published an interactive piece exploring [the changing meanings of clues over the years](https://www.nytimes.com/interactive/2016/02/07/opinion/what-74-years-of-times-crosswords-say-about-the-words-we-use.html?mcubz=3).

Meanwhile, my goal here (aside from indulging my inner crossword geek) is to try out a few new packages: website scraping with `rvest` and wrangling text data with `tidytext`.

Getting The Data
----------------

I didn't scrape NYTimes.com itself. Why? Because crosswords tend to arrive blank, and I wanted answers. Instead, I used the `rvest` package and [Selector Gadget](http://selectorgadget.com/) to gather historical puzzle data from the amazing resource that is [XWord Info](https://www.xwordinfo.com/).

Although the NYTimes crossword has been around since far earlier than 1994, I chose to only look at puzzles from the Will Shortz era (late 1993 - present). The scraper code is available as part of this repository.

Some Questions
--------------

### What are the most common answers?

Starting off with something easy. What words pop up most frequently?

    ## # A tibble: 5 × 2
    ##    word     n
    ##   <chr> <int>
    ## 1   ERA   514
    ## 2  AREA   458
    ## 3   ERE   428
    ## 4   ONE   425
    ## 5   ELI   411

It's unsurprising that these are all short, vowel-heavy words. They're likely used as short fillers between the longer, more inflexible feature words.

What about their frequency of use over time?

![](https://raw.githubusercontent.com/jtanwk/nytcrossword/master/images/cw_top5_freq.png?raw=true)

Nothing really convincing yet.

### Are words getting longer? Shorter?

Calculating the average length of each word, then plotting by year:

![](https://raw.githubusercontent.com/jtanwk/nytcrossword/master/images/cw_avglength.png?raw=true)

A weak yes, but this doesn't tell us much. Monday puzzles are designed to be far easier than Saturday puzzles. What does average word length look like for each day?

![](https://raw.githubusercontent.com/jtanwk/nytcrossword/master/images/cw_avglength_byday.png?raw=true)

A few observations:

-   The intended puzzle complexity is reflected in the average word length for each day.
-   Friday and Saturday words seem to be growing longer much faster the other days'.
-   Sunday words, while pitched as comparable to Wednesdays or Thursdays, are probably a little longer on average to account for the larger grid.

### What words have emerged recently?

When different words enter the lexicon, it's only a matter of time before they're referenced in popular media like the crossword. I wanted to find the words that only became popular in recent years.

To do this, I'm leveraging the concept of *term frequency-inverse document frequency* (td-idf). From Julia Silge's amazing resource, [Text Mining with R](http://tidytextmining.com/tfidf.html):

> The statistic **tf-idf** is intended to measure how important a word is to a document in a collection (or corpus) of documents, for example, to one novel in a collection of novels or to one website in a collection of websites.

If we treat each year as separate "documents", we should be able to figure out what words are most important to each year.

    ## # A tibble: 412,230 × 6
    ##     year            word     n           tf      idf       tf_idf
    ##    <int>           <chr> <int>        <dbl>    <dbl>        <dbl>
    ## 1   2017             BAE     4 0.0002075765 3.178054 0.0006596894
    ## 2   2015          BLANKS     8 0.0002590170 2.484907 0.0006436331
    ## 3   2000            TTTT     8 0.0002568548 2.484907 0.0006382602
    ## 4   2017            LGBT     5 0.0002594707 2.079442 0.0005395541
    ## 5   2017       IDRISELBA     3 0.0001556824 3.178054 0.0004947671
    ## 6   2016 LAIDITONTHELINE     4 0.0001296849 3.178054 0.0004121455
    ## 7   2016          ROMCOM     4 0.0001296849 3.178054 0.0004121455
    ## 8   2017          ABBACY     3 0.0001556824 2.484907 0.0003868563
    ## 9   2017            ETSY     4 0.0002075765 1.791759 0.0003719272
    ## 10  2017            NSFW     4 0.0002075765 1.791759 0.0003719272
    ## # ... with 412,220 more rows

Some curious results already, but we'll have to dig deeper to get anything particularly interesting.

Plotting the words most important to the last 5 years:

    ## Selecting by tf_idf

![](https://raw.githubusercontent.com/jtanwk/nytcrossword/master/images/cw_tf_idf.png?raw=true)

There you have it. 2017 is \#BAE. In fact, it's been used as an answer this year four whole times, and not once before (see below).

Plotting the appearance frequency of 2017's top 5 words by year:

![](https://raw.githubusercontent.com/jtanwk/nytcrossword/master/images/cw_tf_idf_2017.png?raw=true)

Other observations:

-   A manual look at the clues for IDRISELBA cited his roles in *The Wire* (2002-2004) once and *Mandela: Long Walk to Freedom* (2013) twice. Interestingly enough, no mention of the four films he's been in this year ( *Thor: Ragnarok* , *The Mountain Between Us*, *The Dark Tower* and *Molly's Game* ).
-   Mentions of LGBT and NSFW are steadily increasing. Read into that however you wish.

Summary
-------

-   The most common words in the NYTimes crossword are short and vowel-heavy.
-   Words have gotten longer since 1994, but most significantly so on Fridays and Saturdays.
-   BAE, LGBT and IDRISELBA are the most 2017-specific words to appear,

Further Steps
-------------

There were lots of ideas that I played around with that were either less compelling, difficult to execute or outside the scope of what I wanted to do here today. Here are some of them:

-   What first names appear most often? Do male and female names appear with the same frequency?
-   As above, but with cities and continental representation.
-   What languages are represented the most? Many loanwords or straight-up foreign language words exist in the crossword but are very difficult to detect computationally out of the context of a sentence.
-   Who are the most prolific crossword submitters, and do they have distinct lexical differences between them?
-   Any analysis involving the text of the crossword *clues* and not just the answers.
