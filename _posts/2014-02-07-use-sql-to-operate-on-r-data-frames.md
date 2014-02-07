---
layout: post
title: Use SQL to operate R data frames
categories:
- blog
- R
---

Both in research and application, we need to manipulate data frames by selecting desired columns, filtering records, transforming data from one form to another, and aggregating data. Traditionally, we have a rich source of functions to do that. Suppose `df` is the data frame we are operating on. We use `df[1:100,]` to select the first 100 rows, `df[,c("price","volume")]` to select `price` and `volume` columns, `df[df$price >= mean(df$price),]` to single out records with prices no less than their average, `transform(df, totalValue=price*volume)` to add a new column `totalValue` of each record, `apply(df,2,mean)` to calculate the mean for each column.

However, if we want to do something more, together, in one statement, the R code will be totally a mess. In the realm of database, people already have a decent solution to regular data manipulation. It is a language called [SQL](https://en.wikipedia.org/wiki/SQL) (Structured Query Language). You can write SQL as English-like statements to query the database in order to finish all tasks mentioned above, including doing much more complex tasks, together, even in one line. SQL boosts how people interact with data. If you are not familiar with it, you may learn some essentials [here](http://www.w3schools.com/sql/).

`sqldf` package provides an interface between SQLite memory database and R through SQL. You even don't need to know database stuff because everything happens in the back-stage. Here you only need to know some basic SQL to begin with. For example, if we want to finish all the tasks in the first paragraph in one SQL statement, here it is:

{% highlight sql %}
SELECT *, price * volume AS totalValue 
FROM df 
WHERE price >= (SELECT AVG(price) FROM df) 
LIMIT 100
{% endhighlight %}

In R, assuming `df` is the data frame we want to operate with in the current environment, we only need to call this to finish the tasks altogether:

{% highlight R %}
sqldf("SELECT *, price * volume AS totalValue 
        FROM df WHERE price >= (SELECT AVG(price) FROM df)
        LIMIT 100")
{% endhighlight %}

If you are familiar with SQL, the statement above is almost as friendly as plain English.

`sqldf` is listed on [CRAN](http://cran.r-project.org/web/packages/sqldf/) and is hosted by [Google Code](https://code.google.com/p/sqldf/). Its official website offers a comprehensive tutorial and FAQ on it.
