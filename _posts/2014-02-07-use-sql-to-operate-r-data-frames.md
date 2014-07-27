---
layout: post
title: Use SQL to operate R data frames
categories:
- r
highlight:
- r
- sql
---

In both research and application, we need to manipulate data frames by selecting desired columns, filtering records, transforming and aggregating data. 

R provides built-in functions for data frame manipulation. Suppose `df` is the data frame we are dealing with. We use `df[1:100,]` to select the first 100 rows, `df[,c("price","volume")]` to select `price` and `volume` columns, `df[df$price >= mean(df$price),]` to single out records with prices no less than their average, `transform(df, totalValue=price*volume)` to add a new column `totalValue` for each record, `apply(df,2,mean)` to calculate the mean of each column.

However, if we want to do something more, together, the R code will be totally a mess. Say we want to sort `df` by a new column `totalValue`, which equals `price` times `volume`, and then average the `price` and `totalValue` columns for the top 20 records. The R code, if written in several lines, can be this:

```r
df$totalValue <- df$price * df$volume
df.sorted <- df[order(df$totalValue,decreasing=T),]
df.subset <- df.sorted[1:20,c("price","totalValue")]
apply(df.subset,2,mean)
```

The above code introduces several intermediary variables. If we want to do more with the built-in functions, the code will quickly be unreadable.

In the realm of database, people already have a decent solution to regular data manipulation. It is a language called [SQL](https://en.wikipedia.org/wiki/SQL) (Structured Query Language). You can write SQL as English-like statements to query the database in order to finish all tasks mentioned above, including doing much more complex tasks, together, even in one line. SQL boosts how people interact with data. If you are not familiar with it, you may learn some essentials [here](http://www.w3schools.com/sql/).

`sqldf` package provides an interface between SQLite memory database and R through SQL. You even don't need to know database stuff since this package makes everything happen in the back-stage. With this package, you only need to call `sqldf()` to query a data frame in the current environment. Here you only need to know some basic SQL to begin with. 

For example, if you need to select `price` and `volume` columns, the SQL statement should be:

```sql
SELECT price, volume FROM df
```

The statement looks very much like an English sentence. It's true, and it is exactly one of the purposes for which SQL was designed. In R, `sqldf` allows us to directly query `df` by calling `sqldf()` function:

```r
sqldf("SELECT price, volume FROM df")
```

To introduce a new colume `totalValue`, the SQL statement should be:

```sql
SELECT *, price * volume AS totalValue FROM df
```

In fact, SQL keywords (e.g. `SELECT`, `AS`, `FROM`) are not case sensitive. You can write lower capital counterparts instead. However, R variable names are case sensitive, so you need to be careful with the cases of data frame columns. 

Filtering can be very easy too. Here we use `WHERE` to select records where `totalValue` is no less than 3000.

```sql
SELECT *, price * volume AS totalValue FROM df WHERE totalValue >= 3000
```

Sorting can also be simple. Here we use `ORDER BY` to sort the records by `totalValue` in a descending way.

```sql
SELECT *, price * volume AS totalValue FROM df ORDER BY totalValue DESC
```

The code for subsetting a table is also intuitive. Here we use `LIMIT` to select only the top 30 records with the highest `totalValue`.

```sql
SELECT *, price * volume AS totalValue 
FROM df 
ORDER BY totalValue DESC 
LIMIT 30
```

Note that we break the lines to make the statement clear. It works perfectly in the same way as a statement without line breaks.

The power of SQL may not be very clear yet, unless we combine them together. For example, if we want to finish all the tasks in the first paragraph in one SQL statement, here it is:

```sql
SELECT AVG(price), AVG(totalValue) 
FROM 
    (SELECT *, price * volume AS totalValue 
    FROM df 
    ORDER BY totalValue DESC 
    LIMIT 20)
```

Here we embed a SQL statement inside another.

Another example is to select the top 100 records ordered by `totalValue` in descending way where their prices are no less than the average price.

```sql
SELECT *, price * volume AS totalValue 
FROM df 
WHERE price >= (SELECT AVG(price) FROM df)
ORDER BY totalValue DESC
LIMIT 100
```

If you are familiar with SQL, the statement above is almost as friendly as plain English, and it does not matter whether we write it in one line or in several lines. Here we separate the different clauses in the statement for greater readability.

You may try to implement it only by built-in R functions and you will certainly find SQL a very powerful tool. Here I should remark that `sqldf` is based on SQLite memory database and provides its `select` functionality. Since different database engines support the standard of SQL to a different degree, we are only allowed to use the SQL-SELECT statements within the support of SQLite database engine. You may get more information [here](http://www.sqlite.org/lang_select.html).

In conclusion, SQL is a powerful tool so that R users should pick it up. And `sqldf` is the way we use this language with R to operate data frame in a more decent way. `sqldf` is listed on [CRAN](http://cran.r-project.org/web/packages/sqldf/) and is hosted by [Google Code](https://code.google.com/p/sqldf/). Its official website offers a comprehensive tutorial and frequently asked questions.
