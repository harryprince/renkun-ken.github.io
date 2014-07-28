---
layout: post
title: Introduction to parallel computing in R
categories: blog
highlight: [ r ]
---

For R beginners, `for` loop is an elementary flow-control device that simplifies repeatedly calling functions with different parameters. A possible block of code is like this:

```r
run <- function(i) {
  return((i+1)/(i^2+1))
}
for(i in 1:100) {
  run(i)
}
```

In this code, we first define a function that calculates something, and then run the function from `i = 1` to `i = 100`. This can be altered to a Monte Carlo simulation in which we estimate the distribution of a statistic or to calculate the theoretical price of an European call option in a binomial tree.

The code above can be reduced by high-level aggregate function `lapply` or `sapply`, for example, we can eliminate the `for` loop by `lapply`:

```r
lapply(1:100,run)
```

The code will return a list of values, each of which equals `run(i)` where `i` is iteratively chosen from the numeric vector `1:100`. The code is made simpler, but its internal mechanism does not change at all.

However, in many cases of Monte Carlo simulation the tasks are dividable to sub-tasks that are uncorrelated with each other. This allows us to take advantage of parallel computing to boost the calculation. In other words, if a task can be divided to, for example, 3 sub-tasks that can be independently solved, we could actually use three computers (or three cores) to finish the tasks simultaneously and then aggregate the results.

In the example above, if `run` function only depends on parameter `i`, we should know that we can run this `for` loop in parallel because it does not matter when we run `i = 10` or `i = 20` or in the other way around.

This idea leads to the use of parallel computing. Parallelism on a local machine employs multiple cores to perform computing tasks at the same time. It is especially useful for statisticians and econometricians when they need to figure out the distribution of a statistic produced by a particular data generating process. The distribution is estimated from a number of realizations of the statistics. If the data generating process for each realization is independent with each other, we may largely reduce the time if we get the result using parallel computing.

Here, I introduce two ways to perform parallel computing in R using different packages.

# Packages for parallel computing

A considerable number of packages are developed to provide support for various paradigms of parallel computing. An official list [CRAN Task View: High-Performance and Parallel Computing with R](http://cran.r-project.org/web/views/HighPerformanceComputing.html) offers brief introduction to the different paradigms and the packages available.

In this article, I only introduce `parallel` package and `parallelMap` package.

## `parallel` package

`parallel` package supports local multi-core parallelism. If you don't have it installed, you may call

```r
install.packages("parallel")
```

The back-end mechanism is quite transparent: first, we set up a local cluster over multiple cores in CPU, which run in parallel and are able to process data simultaneously. Then we send commands to all cluster nodes (cores) to run a task specified by a function. Below is a minimal example:

```r
library(parallel)
cl <- makeCluster(detectCores())
result <- clusterApply(cl,1:100,run)
values <- do.call(c,result)
stopCluster(cl)
```

First, we load `parallel` library. Then we create a cluster of several nodes. `detectCores()` will return the number of logical processors in your machine. Next we call `clusterApply` to run parallel computing over cluster `cl` we just created, and through the vector `1:100` each node calls `run` function defined above. The computation will yield a list of returned values of `run`. To aggregate these numbers in `list`, we use `do.call` to pass the list as parameters to the function `c` to combine all these values into a numeric vector. Finally, we stop the cluster and clear the resources.

If our task returns a vector containing more than one values, we still do not have to change much of our code above. For example, if `run` function return a named vector of `a`, `b`, and `c` each time:

```r
run <- function(i) {
  return(c(a=i,b=i+1,c=i*2))
}
```

We don't need to change anything but how we aggregate the results. Here it is:

```r
library(parallel)
cl <- makeCluster(detectCores())
result <- clusterApply(cl,1:100,run)
values <- do.call(rbind,result)
stopCluster(cl)
```

We only change `c` to `rbind` in `do.call` function so that the `list` of returned named vectors are combined row by row, which finally makes a matrix with column names `a`, `b`, and `c`. If you want to get a data frame in the final result, there are two ways to do it.

One way is to call `data.frame` to convert the matrix to data frame after we have already obtained the matrix.

```r
values.df <- data.frame(values)
```

The other way is to change `run` function so that it directly returns a data frame with a single row.

```r
run <- function(i) {
  return(data.frame(a=i,b=i+1,c=i*2))
}
```

Here we don't need the change anything in the rest of the code.

## `parallelMap` package

The functionality of `parallelMap` package is quite similar with that of `parallel` package except that we don't need to explicitly operate the cluster object. If you don't have this package installed, run the code:

```r
install.packages("parallelMap")
```

To initialize a cluster, we run the following code:

```r
library(parallelMap)
parallelStart("socket",cpus=4)
```

Then the environment has an implicitly defined local cluster of 4 CPUs, each node of which communicate with each other by socket. Here you don't have to know anything about *socket*. We have just created a similar cluster as we did with `parallel` package. But this time, we don't need to manage the cluster object by ourselves. The package will automatically manage it.

To run the same task we did before, we run the code:

```r
result <- parallelLapply(1:100,run)
values <- do.call(rbind,result)
```

Note that here we use `parallelLapply` and don't need to explicitly specify which `cluster` we use since on a local machine we usually have only one cluster. The code looks much simpler. In addition, the way to produce data frames perfectly applies here too.

# Conclusion

A tip for writing R loop in which iterations are independent with each other is to eliminate it. I rarely use `for` when `sapply` and `lapply` can finish the same task. If you use these high-order functions, it is likely that they can be easily switched to a parallel version.

As a result, a better development procedure is like this: First, write code with `sapply` or `lapply` to ensure the code works. Then alter these functions to their parallel version if you need a higher performance.

This post only works for the situation where the function each node runs does not require non-elementary packages and does not refer to *outer* resources in the environment. In my later posts, I will introduce how we run functions in standalone code file over cluster nodes which may require non-elementary packages, and how we pass variables in the current environment to the environment of the cluster nodes.
