---
layout: post
title: Reshape R data frame from long to wide format
categories:
- blog
- R
---

Oftentimes, we obtain a long or a wide table from a certain data source, and it may be the only format we can get. For example, some financial databases provide daily tick data for all stocks in a financial market. The data table may be arranged in a *long format* like this:

```
  Code       Date Open High  Low Close
1  A01 2014-03-10 10.0 13.0  9.0  11.0
2  A01 2014-03-11 11.0 12.0 10.6  10.9
3  A01 2014-03-12 10.9 11.5 10.6  11.2
4  A02 2014-03-10 15.0 16.0 15.5  15.6
5  A02 2014-03-11 15.6 15.7 14.6  15.1
6  A02 2014-03-12 15.1 16.2 14.8  15.4
...
```

This type of data arrangement is called long format because it stacks all data row by row. In this example, if the number of stocks exceeds a thousand, and the date ranges from 2000 to today, you should imagine how *long* this table would be.

There could be tons of reasons for the data provider to arrange data in this way. However, if you load it into R and work with this data frame, you will soon find it slow to query. For example, suppose the data frame is named `stocks` and contains the data of thousands of stocks from 2000 to 2014. Now you want to get all close prices of stock with code `A15` and date prior to 2005. In R, it is a only a simple subsetting, you probably have figured out the code.

```r
stocks[stocks$Code=="A15" & stocks$Date < as.Date("2005-01-01"),"Close"]
```

However easy is the code, the performance is the blocking issue. If the data frame is large, or even if you store the whole table in a database, it could cost a typical personal computer several seconds to extract the subset of data you want. If your program needs to solve problems that involve frequently subsetting the database like this, your machine does not really spend much time on *solving the problem* but *querying the data*.

Do we have a better way to organize the data so that it is easy to fast to query? The answer is definitely yes. A good solution is to *reshape* the long-format table to a wide-format one.

A package called `reshape2` ([CRAN](http://cran.r-project.org/web/packages/reshape2/)) written by [Hadley Wickham](http://had.co.nz/) provides a handy way to do this. You only need to call the `dcast` function and specify the index variable, column variable, and value variable.

```r
wstocks <- dcast(stocks,formula=Date~Code,value.var="Close")
```

If the above table of stock prices is casted to its wide form in terms of close price, just as what the above code does, it should look like this:

```
        Date  A01  A02 ...
1 2014-03-10 11.0 15.6 ...
2 2014-03-11 10.9 15.1 ...
3 2014-03-12 11.2 15.4 ...
...
```

The data frame is automatically reshaped to a wide-format version where `Date` serves as a common index, all stock codes are horizontally aligned as columns, and close prices are filled as values.

Such a data frame is more user-friendly and work in much higer performance with filtering and subsetting. To do the same thing as we just did, the code should be

```r
wstocks[stocks$Date < as.Date("2005-01-01"),"A15"]
```

Since the columns are well defined and there are much less rows to perform the comparison operator, the computing performance is hugely improved.

`reshape2` packages does more than this. To learn more about this package, you may visit Sean Anderson's [introduction](http://www.seananderson.ca/2013/10/19/reshape.html), or go to [Stockoverflow](http://stackoverflow.com/questions/tagged/reshape2/) and learn from peer experiences.