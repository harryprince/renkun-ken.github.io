---
layout: post
title: "A new gitbook - learnR"
categories:
- r
---

[Gitbook](https://www.gitbook.io/) is rather a relatively new concept on the web. It provides a user-friendly framework for authors to write and produce online books with beautiful illustrations and responsive interactions. It allows authors to write in [Markdown](https://en.wikipedia.org/wiki/Markdown) syntax, which is very easy to learn and use, so that they can focus more on the contents they try to produce than the layout and styles of the contents.

There are already couple of books online. However, I can't find any authors writing a gitbook related to R. A month ago, I needed to give lectures to introduce R to my team, so I prepared a variety of code that covers a wide range of topics from the absolute basics to advanced programming concepts and practices. 

I created [learnR](https://github.com/renkun-ken/learnR) project and decided to produce a gitbook based on that code. Therefore I transformed the repo to a new gitbook repo entitled *learnR* for R users to better understand the basics and underlying mechanisms of R so as to solve problems using R with easier and more elegant code and techniques.

Thanks to Jason Bryer's [Rgitbook](https://github.com/jbryer/Rgitbook) package! It allows me to write the book in [R Markdown](http://rmarkdown.rstudio.com/) and transform the output to markdown.

The gitbook is still in its early stage, but it's already online for [preview](http://renkun.me/learnR), and the contents are planned as the following:

* Quick start
    * What is R
    * Why R
    * How to install R
    * RStudio
    * First model
* Basic objects
    * Vector
    * Matrix
    * Array
    * List
    * Data frame
    * Function
    * Formula
* Basic expressions
    * Assignment
    * Condition
    * Loop
* Basic functions
    * Environment
    * Package
    * Object
    * Logical
    * Character
    * Math
    * Statistics
    * Data
    * Graphics
* Basic statistics
    * Preparing data
    * Descriptive statistics
    * Linear regression
    * Hypothesis testing
    * Model analysis
    * Time series modeling
* Basic data mining
    * Using models
    * Cross validation
* Basic grahpics
    * Scatter plot
    * Line plot
    * Bar chart
    * Pie chart
    * Histogram
    * Composing plots
    * Partitioning plots
    * Graphics devices
* Inside R
    * Lazy evaluation
    * Dynamic scoping
    * Object searching
    * Memory management
    * dot-dot-dot
    * Functions
    * Environment
    * Expression
    * Call
* Data structures
    * S3 object
    * S4 object    
* Database
    * SQL
    * Excel workbook
    * SQLite
    * SQL on data frame
* Parallel computing
    * parallel package
* Functional programming
    * Anonymous functions
    * Closures
    * Higher-order functions
* Profiling
    * Computing time
    * Memory usage
* Advanced graphics
    * Interative graphics
    * ggplot2
    * ggvis
* Popular-packages
    * stringr
    * reshape2
    * rootSolve
    * Rsolnp
    * plyr
    * dplyr
    * data.table
    * pipeR
    * jsonlite
    * Rcpp
* Exercises

If you are interested in making contributions, please [fork](https://github.com/renkun-ken/learnR/fork) the repo and send me pull requests.
