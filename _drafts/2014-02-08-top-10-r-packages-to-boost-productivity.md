---
layout: post
title: Top 10 R packages to boost productivity
categories:
- blog
- R
---

R is a free, open-source software environment for statistical computing, data analysis, and data visualization. Its high extensibility allows us to perform flexible analysis on a wide range of datasets.

If you are a data analyst, empirical researcher, or even a quantitative investor, most of your working hours are probably not spent on the final step of your work. Rather, major part of your time is spent dealing with data and related issues. Fortunately, you don't have to solve all the problem yourself from the scratch because there are decent solutions to a wide range of everyday data issues.

In this article, I will introduce 10 packages that provide decent solutions to a wide range of data issues and will hugely boost your productivity.

# sqldf

For R users, one of the most frequently used object is probably the data frame. Data frame is list of columns in regular alignment row by row, which is quite similar with a *table* in a typical relational database. 

However, it is not as convenient to operate data frames in R as we apply exactly the same operations to tables in a database if we merely call built-in functions provided by elementary R packages. 

Then we should bring in the power of [SQL](http://en.wikipedia.org/wiki/SQL), which enables you to query data tables in a convenient way. `sqldf` ([Google Code](http://cran.r-project.org/web/packages/sqldf/), [CRAN](http://cran.r-project.org/web/packages/sqldf/)) is a package that allows you to directly execute SQL `SELECT` statements over R data frames as if you were operating a database. You may learn basic SQL at [W3School](http://www.w3schools.com/sql/).

# reshape2

Oftentimes, we obtain a long or a wide table from a certain data source, and that is the only format we can get from it. However, it may not be the one we need. For example, some financial databases provide daily tick data for all stocks in a financial market. The data table is arranged in a long format like


# plyr

# lubridate

Date and time

# stringr

String

# forecast

# parallelMap

# ggplot2

# knitr

# RSQLite