---
layout: post
title: Use pipeline operators in R
categories:
- blog
- R
---

In data-driven statistical computing and data analysis, applying a chain of commands step by step is a common situation. However, it is neither straightforward nor flexible to write a group of deeply nested functions. It is because the function that comes later must be written first. 

Consider the following example in which we need to take the following steps:

1. Generate 10000 random numbers from normal distribution with mean 10 and standard deviation 1
2. Take a sample of 100 without replacement from these numbers
3. Take `log` of the sample
4. Take difference of the log numbers
5. Finally, plot these log differences as red line segments

These steps only require basic functions. In traditional way, if we do not want to introduce too many intermediate variables, we may finish it by the following code:

```r
plot(diff(log(sample(rnorm(10000,mean=10,sd=1),size=100,replace=FALSE))),col="red",type="l")
```

This line of code exactly demonstrate how "straightforward" and "flexible" it is to do a series of work with deeply nested functions. It is not straightforward because you can hardly identify what the author was actually trying to do in one glimpse; nor is it flexible because one careless change in the deeply nested brackets may cause problems that are difficult to locate.

The problem already has some decent solutions. One of my favorite solution is the idea of pipelining. A good representative of this idea is the pipeline operator in the F# programming language. Even if you don't really know the language, you may quickly figure out what the following code is trying to do:

```fsharp
let data =
    [|1..100|]
    |> Array.filter (fun i -> i*i <= 50)
    |> Array.map (fun i -> i+i*i)
    |> Array.sum
```

In simple words, the F# code above first filter the array from 1 to 100 by selecting any element `i` that satisfies `i*i <= 50`; then it maps each resulted element to a new integer, `i+i*i`; finally it calculates the sum of the resulted elements in the second step.

The magic of the pipeline operator, `|>`, in F# is nothing but a higher order function that takes two arguments: `x`, the object to be piped, and `f`, the function to take the piped object as the first argument.

Thanks to the language design, this kind of magic is immediately implementable in R. I created a package called [`pipeR`](http://renkun.me/pipeR/) hosted by [GitHub](https://github.com/renkun-ken/pipeR), which is quite similar with the already existing package [`magrittr`](http://cran.r-project.org/package=magrittr). Both of these packages provide `%>%` operator to pipe the resulted object forward to the first argument of the next function call. The following code is an equivalent example of the five-step example in the beginning:

```r
rnorm(10000,mean=10,sd=1) %>%
  sample(size=100,replace=FALSE) %>%
  log %>%
  diff %>%
  plot(col="red",type="l")
```

The thing `%>%` does is simple: pipe the value on the left-hand side to be the first argument of the function call on the right-hand side. Its functionality is very similar with the F# pipeline operator. As we can see, the code becomes much clearer than the nested version, which also results in greater flexibility. When the demand changes, it is very handy to add or remove steps from the chain of commands without reorganizing the structure of the code.

However, sometimes we don't only need the object to be piped to the first argument of the next function call; instead, we may need to pipe it to non-first argument, to the expression in the argument, or even to multiple places.

Consider a more complex example similar with the very first one. Now we need to do something more as instructed by the following steps:

1. Generate 10000 random numbers from normal distribution with mean 10 and standard deviation 1
2. Take a sample of 20% without replacement from the population
3. Take `log` of the sample
4. Take difference of the log numbers
5. Finally, plot these log differences as red line segments with a title containing the number of observations

Note that some function calls in the command chain need to use more than once of the resulted object. `pipeR` provides a more powerful pipe operator, `%>>%`, that uses `.` to represent the previous result in the next function call. To demonstrate how it functions, let's take a look at how it solves this problem.

```r
rnorm(10000,mean=10,sd=1) %>>%
  sample(.,size=length(.)*0.2,replace=FALSE) %>>%
  log %>%
  diff %>%
  plot(.,col="red",type="l",main=sprintf("length: %d",length(.)))
```

The difference is quite obvious: the environment of the chained function calls contains a specially defined variable `.` to represent the resulted object up to the previous evaluation. If a function is directly supplied, `.` will automatically serve as the first argument.

The existing packages encounter some problems when the authors try to create a unified pipe operator that deals with all situations including first-argument piping (`%>%`) and free-piping (`%>>%`). One is when `.` has some special meaning in `formula` object. To avoid ambiguity and reduce the risk of wrong guesses, I decide to provide two separate pipe operators and let the user decide which style of piping is to be used.

The power of pipe operators is more unleashed with `dplyr` package when we manipulate data by command chain. The following example demonstrate this point. We load `dplyr` package to use its handy functions for data manipulation and `hflights` packages to import its example data set.

In this example, a long chain of commands is to be executed:

1. Mutate `hflights` by adding a new column of flight speed
2. Group the data by the code of unique carrier
3. For each group summarize the data by computing the number of observations, average speed, median speed, standard deviation of speed
4. Mutate the resulted summary data by adding a new column of standardized average speed
5. Sort the data by standardized average speed in descending order
6. Assign the resulted data frame to `hflights.speed` in the global environment
7. Make a bar chart of the standardized average speed with the code of unique carrier as the names, and a title that shows the number of unique carriers.

```r
library(dplyr)
library(hflights)
data(hflights)

hflights %>%
  mutate(Speed=Distance/ActualElapsedTime) %>%
  group_by(UniqueCarrier) %>%
  summarize(n=length(Speed),speed.mean=mean(Speed,na.rm = T),
    speed.median=median(Speed,na.rm=T),
    speed.sd=sd(Speed,na.rm=T)) %>%
  mutate(speed.ssd=speed.mean/speed.sd) %>%
  arrange(desc(speed.ssd)) %>>%
  assign("hflights.speed",.,.GlobalEnv) %>>%
  barplot(.$speed.ssd, names.arg = .$UniqueCarrier,
    main=sprintf("Standardized mean of %d carriers", nrow(.)))
```

Just imagine how long the code will be and how many intermediate variables will you define if you don't use any pipe operators. To write readable, flexible, and maintainable code for data manipulation, please consider using pipe operators.

*Some contents are updated to adapt to the latest version of pipeR.*

*This article may be archived by [R-bloggers](http://www.r-bloggers.com/).*