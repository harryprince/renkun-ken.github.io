---
layout: post
title: "What are the most popular keywords of CRAN packages?"
categories: blog
highlight: [ r ]
---



A large proportion of R's power should be attributed to the enormous amount of extension packages. Most of the packages are hosted on [CRAN](http://cran.r-project.org).

These packages cover a wide range of fields. In this post, I'll show you how to use R to scrap the titles of all CRAN packages from the [web page](http://cran.r-project.org/web/packages/available_packages_by_date.html) and find out which keywords are the most popular.

To minimize the efforts, we try best to avoid reinventing the wheels and get some answer as quickly as possible. We only use existing packages to do all the work.

Here is our toolbox that is useful in this task:

- [`httr`](https://github.com/hadley/httr): Download and parse web pages
- [`rvest`](https://github.com/hadley/rvest): Scrape from the web page by selector
- [`rlist`](http://renkun.me/rlist): Quickly perform mapping and filtering in functional style
- [`pipeR`](http://renkun.me/pipeR): Pipe all operations at high performance

First, we equip our R environment with these tools.


```r
library(httr)
library(rvest)
library(rlist)
library(pipeR)
```

Then we download and parse the web page.


```r
url <- "http://cran.r-project.org/web/packages/available_packages_by_date.html"
html <- content(GET(url),"parsed")
```

Now `html` is a parsed HTML document object that is well structured and is ready to query. Note that we need to get the texts in the third column of the table. Here we use [XPath](https://en.wikipedia.org/wiki/XPath) to locate the information we want. Or you can use [CSS](http://www.w3.org/TR/CSS2/selector.html) selector to do the same work.

The following code are written in fluent style with pipeline.


```r
words <- html[xpath("//tr//td[3]//text()")] %>>%   # select the 3rd column
  list.map( # map each node to ...
    # 1. get the trimmed text in the XML node
    XML::xmlValue(.,trim = TRUE) %>>% 
      # 2. split the text by non-word-letters
      strsplit("[^a-zA-Z]") %>>% 
      # 3. put everything together in vector
      unlist(use.names = FALSE) %>>% 
      # 4. lower all words
      tolower %>>% 
      # 5. filter words with more than 3 letters to be meaningful
      list.filter(nchar(.) > 3L)) %>>% 
  # put everything in a large character vector
  unlist %>>%
  # create a table of word count
  table %>>%
  # sort the table descending
  list.sort(desc(.)) %>>%
  # take out the first 100 elements
  list.take(100) %>>%
  # print out the results
  print
```

```

          data       analysis         models           with      functions 
           864            718            484            404            371 
       package     regression     estimation          model          based 
           336            308            273            249            238 
         using          tools           from       bayesian         linear 
           235            225            194            173            169 
       methods           time      interface   multivariate    statistical 
           169            168            160            133            124 
          test    generalized     clustering          tests         series 
           114            112            105            105            104 
     inference     statistics         random   distribution      selection 
           101            101            100             97             96 
      modeling        spatial      algorithm       multiple     simulation 
            89             89             87             87             82 
         mixed         method     likelihood  distributions      modelling 
            81             78             77             76             73 
       network           sets classification        mixture       sampling 
            72             70             68             67             64 
       effects         robust         sparse       survival       variable 
            63             63             60             60             60 
          high        fitting           gene       function   optimization 
            58             57             57             56             56 
     graphical        testing       networks          files  nonparametric 
            55             55             54             52             52 
         plots         sample    dimensional        genetic          multi 
            52             52             51             51             51 
     utilities  visualization implementation        density         matrix 
            51             51             50             49             49 
  hierarchical          lasso       learning         markov    correlation 
            48             48             48             48             47 
       dynamic           plot     prediction       censored           meta 
            47             47             47             46             46 
      datasets       gaussian       response       adaptive    association 
            45             45             45             44             44 
        binary         design          least         normal         system 
            44             44             43             43             43 
          fast     functional          point       analyses     confidence 
            42             42             42             41             41 
   experiments       graphics        objects     population        process 
            41             41             41             41             41 
```

The work is done, in 12 lines, in only a little more than 2 seconds!

If you want to know more about these packages, please visit their project pages. Hope you can do more amazing things in your work.
