---
layout: post
title: "R: Essentials"
categories:
- blog
- R
---

It is quite easy to get started with R. You only need to download R from the [ official website ](http://www.r-project.org/), and install it. 

I suggest that you install both 32-bit and 64-bit versions for greater compatibility if you are running on a 64-bit operating system. For typical statistical programming, if your dataset is not huge, it does not matter which one you run; if you try to process a giant dataset (e.g. more than 2GB), you probably need to run a 64-bit version since it supports numeric vector that contains up to $(2^{64}-1)$ entries while the 32-bit version only supports $(2^{32}-1)$ entries. 

For ordinary purposes like learning statistics or analyzing simple dataset, we probably won't get close to the upper limit of a vector. For some other research, however, like quantitative trading, we often need to deal with high frequency data, which usually occupies a big part of your hard drive, and then we need database technology to be able to deal with the data; otherwise, we cannot even load it without killing your machine.

R can do many things in a convenient way, especially when we need to use statistical methods and techniques intensively. For example, if we want to develop a program that runs over the entire market to find profitable stocks according to some statistical theory given the market-wide stock data, it won't be more convenient to use C++ than R if we need to estimate some complex statistical models and perform some statistical tests. The reason is: In R community, many statistical techniques are already implemented and easy to use whereas it is time-consuming to find the C++ counterparts or otherwise we need to rewrite them.

The advantage of R in statistical programming is quite obvious: R specializes in statistical programming and it is free. However, the cost is obvious too. If you want to perform arbitrage over financial assets in a very high frequency like 200ms, you won't choose R because its performance is not at the same level with C/C++. Therefore, we need to ask ourselves: What is our purpose to learn it?

Once you recognize the advantage of R in your work, you can start to get your hands on it soon.

There are a great number of tutorials available online. Here I recommend [ R Tutorial ](http://www.cyclismo.org/tutorial/R/) by Kelly Black and an interactive tutorial called [ Try R ](http://tryr.codeschool.com/). These two online tutorials help you get the very basic ideas and understand the fundamental operations in R. That is the first step into this new world of statistical programming. Once you get familiar with the basics, you have the access to nearly 5000 packages related to statistics, econometrics, time series analysis, nonparametrics, machine learning, simulation, database, data manipulation, and even links to Java, Python, and .NET infrastructures.

In my later blogs, I will introduce some advanced techniques to manipulate data, some simulations to compare different statistical methods, and some applications in quantitative finance like statistical arbitrage.