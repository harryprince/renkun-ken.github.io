---
layout: post
title: Difference between magrittr and pipeR
categories: blog
highlight: [ r ]
---



Pipeline is receiving increasing attention in R community these days. It is hard to tell when it starts but more people start to use it since the easy-and-fast [dplyr](https://github.com/hadley/dplyr) package imports the magic operator `%>%` from [magrittr](https://github.com/smbache/magrittr), the pioneer package of pipeline operators for R.

The two packages co-work well: dplyr works with data frames by a set of basic operations, and magrittr chains these operations together and makes the data manipulation process consistent with our intuition.

A little example will demonstrate how easy it is to work with dplyr and the magic `%>%`.

Suppose we are working with the built-in data frame `iris`.


```r
head(iris)
```

```
  Sepal.Length Sepal.Width Petal.Length Petal.Width Species
1          5.1         3.5          1.4         0.2  setosa
2          4.9         3.0          1.4         0.2  setosa
3          4.7         3.2          1.3         0.2  setosa
4          4.6         3.1          1.5         0.2  setosa
5          5.0         3.6          1.4         0.2  setosa
6          5.4         3.9          1.7         0.4  setosa
```

We can use `%>%` and the *verbs* dplyr provides to quickly transform the data. The following example runs to find out the top 3 largest items in terms of total sizes of sepal and petal for each species.


```r
library(dplyr)
iris %>% 
  mutate(Sepal.Size=Sepal.Length*Sepal.Width,
    Petal.Size=Petal.Length*Petal.Width) %>%
  select(Sepal.Size,Petal.Size,Species) %>%
  group_by(Species) %>%
  do(arrange(.,desc(Sepal.Size+Petal.Size)) %>% head(3))
```

```
Source: local data frame [9 x 3]
Groups: Species

  Sepal.Size Petal.Size    Species
1      25.08       0.60     setosa
2      23.20       0.24     setosa
3      23.10       0.28     setosa
4      22.40       6.58 versicolor
5      21.39       7.35 versicolor
6      20.10       8.50 versicolor
7      29.26      14.74  virginica
8      30.02      12.80  virginica
9      25.92      15.25  virginica
```

Thanks for magrittr's `%>%`, the code is quite easy to read because all verbs are chained in a pipeline.

However, if the operator is used in nested loops, the performance can be very low. Suppose we are solving such a problem: Conduct an experiment for 100000 times. Each time we take a random sample from lower letters (a-z) with replacement, paste these letters and see whether it equals the string *rstats*. The following code is a simple and intuitive solution.


```r
system.time({
  lapply(1:100000, function(i) {
    sample(letters,6,replace = T) %>%
      paste(collapse = "") %>%
      "=="("rstats")
  })
})
```

```
   user  system elapsed 
  26.77    0.00   26.76 
```

It took rather a long time to go through the iterations, which motivated me to developed [pipeR](http://renkun.me/pipeR) package that provides high performance operators.

magrittr is great in that it smartly analyzes the way user tries to use the pipeline, which makes the operator robust in a wide range of situations. For example, it knows whether you want to pipe the previous object to the first argument or `.` symbol in the next function.

For interactive analysis, its smart behavior helps save a lot of time. But for large iteration in which we also want to use pipeline to organize our code, its performance loss may offset the time we have saved.

The design of pipeR is suitable for the situation where we want to trade performance with robustness. In other words, the operators in pipeR are dumb: they don't analyze and find out how you want to pipe an object. They only specialize in single type of piping respectively: 

- `%>>%` only pipes the object to the first argument of the next function.
- `%:>%` only pipes the object to `.` symbol in the next expression.
- `%|>%` only pipes according to a lambda expression like `x ~ f(x)`, that is, it evaluates `f(x)` with `x` representing the piped object.

Here is a demonstration that `%>%` are replaced with `%>>%` in the previous example.


```r
library(pipeR)
system.time({
  lapply(1:100000, function(i) {
    sample(letters,6,replace = T) %>>%
      paste(collapse = "") %>>%
      "=="("rstats")
  })
})
```

```
   user  system elapsed 
   2.50    0.00    2.51 
```

The performance improvement is significant, especially in nested loops, but he cost is that we have to know in advance which operator should take charge.

So here is my recommendation:

- If you do interactive analysis or want it to be simple and robust and do not care about the performance, `%>%` is the perfect choice. It also provides aliases of basic functions to make piping more friendly.
- If you care about performance issues, feel sure about the type of piping to use, or want to use pipeline in massive or nested loops, or want to avoid ambiguity in reading since `.` can be meaningful within some functions like `do()`, pipeR operators can be good choices.

Since the two packages use different set of symbols, they are fully compatible with each other. You may choose according to your needs and considerations, and finally, enjoy piping!
