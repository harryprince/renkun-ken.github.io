---
layout: post
title: Scraping information of CRAN packages
categories: blog
tags: [ r, scraping, CRAN, pipeline ]
highlight: [ r ]
---



In my previous [post](http://renkun.me/blog/2014/07/25/what-are-the-most-popular-keywords-of-cran-packages.html), I demonstrated how we can scrape online data using existing packages. 

In this post, I will take it a bit further: I will scrape more information of [CRAN packages](http://cran.r-project.org/web/packages/available_packages_by_date.html) since each of them also has a web page like [this](http://cran.r-project.org/web/packages/rlist/). More specifically, I want to build my own database that includes the date, name, title, version, and imports of the packages.

Before we start, we should take a look at those web pages we are going to deal with. Modern web browsers have built-in web developer toolkit, which allows us to inspect the elements and structures of a web page. That is exactly how I locate the resources I want to scrape from a page.

For example, if you are a Firefox user, you can press F12 to show the developer tools. The same shortcut key also applies to Google Chrome and Internet Explorer. An alternative way is to click *Inspect the element* in the context menu of the data cell, which directly locates the element. Fortunately, CRAN pages are quite easy to handle with using XPath, as we previously played with. 

Now we can get started scraping the pages. First, load the packages we need.


```r
library(httr)
library(rvest)
library(rlist)
library(pipeR)
```

Then we scrape and parse the [web page of the long table](http://cran.r-project.org/web/packages/available_packages_by_date.html), and for each row that corresponds with a package, we need to visit its link and scrape the package page too.

The following code shows how I do it with pipeline.


```r
# first, scrape the table
url <- "http://cran.r-project.org/web/packages/available_packages_by_date.html"
pkgurl <- "http://cran.r-project.org/web/packages/%s/index.html"
html <- content(GET(url),"parsed")

# for easier value extraction, give it an alias
val <- XML::xmlValue

# set a start time so that we know how long it takes later
start <- Sys.time()

# start scraping!
data <- html[xpath("//tr")] %>>%
  list.skip(1) %>>%
  list.map(row ->
      # xpath tip: use "|" to select multiple nodes at the same time
      row[xpath("td[1]//text() | td[2]//a//text() | td[3]//text()")] %>>%
      lapply(val, trim = TRUE) %>>%
      setNames(c("date","package","title"))) %>>%
  
  # the table is ready, do some cleaning work
  list.update(date=as.Date(date)) %>>%
  
  # we only get the packages updated after July 28, 2014.
  list.filter(date >= as.Date("2014-07-28")) %>>%
  
  # scrape the individual page for each package
  list.update(html = {
    cat("[",format(Sys.time() - start,format="%s"),"]", .i,
      format(date,format = "%y-%m-%d"), package ,"\n", sep="\t")
    sprintf(pkgurl, package) %:>%
      content(GET(.),"parsed")
  }) %>>%
  
  # for each list member, html is the parsed document from which
  # we can extract detailed information
  # make good use of XPath: it can filter and select at the same time
  list.update(version = {
    html["//tr[td[1]='Version:']//td[2]//text()"] %>>%
      vapply(val, character(1L))
  }, imports = {
    html["//tr[td[1]='Imports:']//td[2]//a//text()"] %>>%
      vapply(val, character(1L))
  }, suggests = {
    html["//tr[td[1]='Suggests:']//td[2]//a//text()"] %>>%
      vapply(val, character(1L))
  }) %>>%
  
  # remove html field
  list.update(html = NULL)
```

```
[	6.247 secs	]	1	14-07-28	care	
[	6.654 secs	]	2	14-07-28	cplexAPI	
[	7.062 secs	]	3	14-07-28	cvxclustr	
[	7.472 secs	]	4	14-07-28	discreteRV	
[	7.877 secs	]	5	14-07-28	drfit	
[	8.284 secs	]	6	14-07-28	GeneNet	
[	8.69 secs	]	7	14-07-28	Gmisc	
[	9.097 secs	]	8	14-07-28	HDPenReg	
[	9.501 secs	]	9	14-07-28	HTSCluster	
[	10.35 secs	]	10	14-07-28	HTSDiff	
[	10.76 secs	]	11	14-07-28	httr	
[	11.16 secs	]	12	14-07-28	jaatha	
[	11.57 secs	]	13	14-07-28	LowRankQP	
[	11.98 secs	]	14	14-07-28	ltbayes	
[	12.38 secs	]	15	14-07-28	peptider	
[	12.79 secs	]	16	14-07-28	RJSONIO	
[	13.2 secs	]	17	14-07-28	Rtsne	
[	13.6 secs	]	18	14-07-28	rYoutheria	
[	14.01 secs	]	19	14-07-28	sda	
```

Note that *Imports* and *Suggests* are both vector-valued, which makes the data non-tabular. Therefore, I use `list` to store the data directly. With the assistance of `rlist` package, the data processing with lists is much easier and cleaner.

Let's take a look at the structure of the data we get.


```r
str(head(data))
```

```
List of 6
 $ :List of 6
  ..$ date    : Date[1:1], format: "2014-07-28"
  ..$ package : chr "care"
  ..$ title   : chr "High-Dimensional Regression and CAR Score Variable Selection"
  ..$ version : chr "1.1.5"
  ..$ imports : chr(0) 
  ..$ suggests: chr "crossval"
 $ :List of 6
  ..$ date    : Date[1:1], format: "2014-07-28"
  ..$ package : chr "cplexAPI"
  ..$ title   : chr "R Interface to C API of IBM ILOG CPLEX"
  ..$ version : chr "1.2.11"
  ..$ imports : chr(0) 
  ..$ suggests: chr(0) 
 $ :List of 6
  ..$ date    : Date[1:1], format: "2014-07-28"
  ..$ package : chr "cvxclustr"
  ..$ title   : chr "Splitting methods for convex clustering"
  ..$ version : chr "1.1.1"
  ..$ imports : chr(0) 
  ..$ suggests: chr "ggplot2"
 $ :List of 6
  ..$ date    : Date[1:1], format: "2014-07-28"
  ..$ package : chr "discreteRV"
  ..$ title   : chr "Functions to create and manipulate discrete random variables"
  ..$ version : chr "1.1.2"
  ..$ imports : chr(0) 
  ..$ suggests: chr [1:4] "testthat" "roxygen2" "MASS" "plyr"
 $ :List of 6
  ..$ date    : Date[1:1], format: "2014-07-28"
  ..$ package : chr "drfit"
  ..$ title   : chr "Dose-response data evaluation"
  ..$ version : chr "0.6.3"
  ..$ imports : chr [1:3] "MASS" "RODBC" "drc"
  ..$ suggests: chr(0) 
 $ :List of 6
  ..$ date    : Date[1:1], format: "2014-07-28"
  ..$ package : chr "GeneNet"
  ..$ title   : chr "Modeling and Inferring Gene Networks"
  ..$ version : chr "1.2.10"
  ..$ imports : chr(0) 
  ..$ suggests: chr(0) 
```

Now we can use `rlist` functions to do more interesting things with it.
