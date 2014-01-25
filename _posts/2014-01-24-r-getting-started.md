---
layout: post
title: "R: Getting Started"
categories:
- blog
- R
---

R rocks in both academia and industry nowadays. A rapidly increasing number of researchers choose R to be one of their productive tools for data analysis and data visualization. It is partially because the software is totally free and open-source but also because the community behind the stage who contributes to nearly 5000 packages remains growing, which results in a evolving and sustainable ecosystem.

If you are a student learning statistics or econometrics, you must have heard about R. But now, I strongly recommend that you learn some R programming and apply it in your work. Otherwise, you won't be able to get access to the world where specialists speak a language you do not understand and a big part of knowledge is written in a language you cannot read.

Before getting started, you should visit the [official website](http://www.r-project.com) of R and download the software by following the instructions. Here I briefly introduce what your learning curve will probably look like.

There are a large number of books about R, but I suggest that you follow a simple online tutorial to get your hands dirty first. For example, you may visit [Try R](http://tryr.codeschool.com/) and learn the essentials of R syntax and so on. But don't get me wrong. I always hear from people that learning R equals to learning R *syntax*. Unfortunately, it's wrong. You got a lot more to learn!

If you are only familiar with the syntax, you are still far from productive. What you need is a mindset, which is largely neutral to a specific language, a mindset that disassembles a seemingly difficult problem to a bunch of simple sub-problems. Only through solving problems will you get the skill of solving real problems.

Here I assume your work requires some time series analysis. To get started, you may read [Introductory Time Series with R](http://www.amazon.com/Introductory-Time-Series-Paul-Cowpertwait/dp/0387886974) which contains intuitive introduction to the basic theory and application implemented in R. The data is available online and easy to load. Try to crack all the problems in the end of each chapter. Try to create some "fake" data, test what happens when you change some code, and explore what other things the functions can do. If you get stuck to a problem, always turn to the documentation and community, or sometimes even to the source code!

Then, you may start to apply R to your projects. However, you may soon find yourself hopeless in the first stage: preparing the food for the machine to eat! You simply do not know much about how to deal with data from the real world. Now you need to read [Data Manipulation With R](http://www.springer.com/statistics/computational+statistics/book/978-0-387-74730-9) by [Phil Spector](http://www.stat.berkeley.edu/~spector/). You will get very intuitive explanations of the internal workings of R objects and the basic principles of data manipulation with R without knowing much about computer science and software programming. Knowing the basic concepts and the underlying mechanism, you will be less prone to errors. Later, I will write a series of blogs to introduce some other handy ways and packages to deal with data in R that are not covered by this book.

If you currently do not have or plan to use R in your research projects, a good way to quickly accumulate experience is to replicate the existing work in R. For example, if you are a master of PhD student, you may replicate a list of empirical papers in top journals. It will drag you to dealing with real world data which requires your attention to details. Upon this kind of practice, you will build up your intuition.

Finally, a good IDE (Integrated Development Environment) boosts your productivity. For learning purpose, you may use the naive R GUI program. But for productive purpose, I recommend that you use [RStudio](http://www.rstudio.com/), a very powerful cross-platform R code editor that offers rich features like syntax highlighting, debugging, version control, etc.

Have a nice trip with R!