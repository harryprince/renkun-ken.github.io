---
layout: post
title: Easier way to chain commands using Pipe function
categories: blog
tags: [ r, pipeR, Pipe ]
highlight: [ r ]
---



In pipeR 0.4 version, one of the new features is `Pipe()` function. The function basically creates a Pipe object that allows command chaining with `$`, and thus makes it easier to perform operations in pipeline without any external operator.

In this post, I will introduce how to use this function and some basic knowledge about how it works. But before that, I would like to make clear that you don't have to learn a whole new thing if you are familiar with magrittr's `%>%` operator or pipeR's `%>>%` operator. If you are not, you can go ahead without hesitation. After all, the tools are made to be easier to work with.

## Introducing `Pipe()`

Consider a task we plot the log differences of 100 normally distributed random numbers with mean 10. The traditional code can be written as 

```r
plot(diff(log(rnorm(100, mean = 10))),col = "red")
```

magrittr's `%>%` and pipeR's `%>>%` are designed to chain these commands in a human readable way. With `%>%` operator, the code can be restructured like

```r
library(magrittr)
rnorm(100, mean = 10) %>%
  log %>%
  diff %>%
  plot(col="red")
```

In this case, `%>%` and `%>>%` are interchangeable which produce similar output. The operator does nothing special but hack the expression so that the left-hand side object is inserted into the function call on the right-hand side of the operator.

```r
library(pipeR)
rnorm(100, mean = 10) %>>%
  log %>>%
  diff %>>%
  plot(col="red")
```

From the examples above, it seems that `%>%` and `%>>%` are exactly the same. In fact, they are not. I wrote an article *[Difference between magrittr and pipeR](http://renkun.me/blog/2014/08/08/difference-between-magrittr-and-pipeR.html)* to explain their differences.

Both operators can solve the problem above by building a pipeline to avoid deeply nested code and make the operations readable. But is there an even easier way? The answer is Yes.

With `Pipe()` function introduced in pipeR 0.4, the code can be more simplified, even without any weird user-defined operator that has to be enclosed by `% %`. It goes like

```r
library(pipeR)
Pipe(rnorm(100, mean = 10))$
  log()$
  diff()$
  plot(col="red")
```

You may have noticed that the pipeline starts with `Pipe()` function. This function basically creates a Pipe object which, in essence, is an environment which stores a value and whose `$` is specially defined to perform first-argument piping. If a function name that  follows `$` is called, then the resulted value will be stored in the next-level Pipe object. 


```r
Pipe(c(1,2,3))$
  mean()
```

```
$value : numeric 
------
[1] 2
```

Note that the output indicates that the result is not a simple numeric vector but *a box* that contains that numeric vector as an element `$value`. 

To see the difference, try to run


```r
Pipe(c(1,2,3))$mean() + 1
```

```
Error: non-numeric argument to binary operator
```

If the pipeline returns a numeric value `2`, it should add 1 and return 3 as a result. Clearly, this is not the case. It is the box containing the value that allows `$` to perform more levels of piping. In fact, The pipeline construction does not stop until the value is extracted by `$value`.


```r
Pipe(c(1,2,3))$
  mean()$
  value
```

```
[1] 2
```

or simply `[]` as a shortcut.


```r
Pipe(c(1,2,3))$
  mean() []
```

```
[1] 2
```

Once the value is extracted from the box (or Pipe environment), the pipeline is ended with the stored value returned. 

Having known these features, `Pipe()` function can be used to work with pipeline-friendly packages such as [dplyr](https://github.com/hadley/dplyr), [ggvis](http://ggvis.rstudio.com/), and [rlist](http://renkun.me/rlist/). Here are some simple examples. 

`Pipe()` works with dplyr functions.


```r
library(dplyr)
Pipe(mtcars)$
  filter(mpg <= mean(mpg))$
  select(mpg, cyl, wt)$
  group_by(cyl)$
  do(Pipe(.)$
      arrange(wt)$
      head(1)$
      value)$
  value
```

```
Source: local data frame [2 x 3]
Groups: cyl

   mpg cyl   wt
1 19.7   6 2.77
2 15.8   8 3.17
```

`Pipe()` works with ggvis.

```r
library(ggvis)
Pipe(mtcars)$
  ggvis(~ mpg, ~ wt)$
  layer_points()$
  layer_smooths()
```

`Pipe()` also works with rlist.


```r
library(rlist)
Pipe(1:10)$
  list.filter(x ~ x <= 5)$
  list.mapv(letters[.])
```

```
$value : character 
------
[1] "a" "b" "c" "d" "e"
```

## More features

As I mentioned in *[Introducing pipeR 0.4](http://renkun.me/blog/2014/08/04/introducing-pipeR-0.4.html)*, pipeR's `%>>%` operator is able to 

* Pipe left-hand side object as the first argument to the right-hand side function name or call;
* Pipe as `.` within `{}` or by lambda expression within `()`;
* Extract element when followed by a name enclosed by `()` (new feature in version 0.4-1). 

The same features are supported with `.()` function used with `Pipe()`. For example,


```r
Pipe(mtcars)$
  .(lm(mpg ~ cyl + wt, data = .))$
  summary()$
  .(coefficients)
```

```
$value : matrix 
------
            Estimate Std. Error t value  Pr(>|t|)
(Intercept)   39.686     1.7150  23.141 3.043e-20
cyl           -1.508     0.4147  -3.636 1.064e-03
wt            -3.191     0.7569  -4.216 2.220e-04
```

You can regard the above code as evaluated in the following steps:

```r
m <- lm(mpg ~ cyl + wt, data = mtcars)
msum <- summary(m)
msum$coefficients
```

A noteworthy difference between the results produced by the two cases is that the final result produced by `Pipe()` is still stored in the Pipe object (the box), and you can extract the value or build longer pipeline with it. For example,


```r
model <- Pipe(mtcars)$
  .(lm(mpg ~ cyl + wt, data = .))
```

Then `model` is a Pipe object in which the value is a linear model and can be used for further piping.


```r
model$summary()$.(r.squared)
```

```
$value : numeric 
------
[1] 0.8302
```

```r
model$predict(list(cyl = 6, wt = 2.9))
```

```
$value : numeric 
------
    1 
21.39 
```

Another interesting feature of Pipe object is about creating easy-to-use closures (roughly, a function created runtime within a context). For example, we can create a closure that generates 10 uniformly distributed numbers but its range is undecided.


```r
rnd <- Pipe(10)$runif
```

A function `rnd(...)` has been created an it can be used to generate 10 uniformly distributed random numbers with different settings of range.


```r
rnd(min = 1, max = 2)
```

```
$value : numeric 
------
 [1] 1.258 1.552 1.056 1.469 1.484 1.812 1.370 1.547 1.170 1.625
```

```r
rnd(min = 10, max = 20)
```

```
$value : numeric 
------
 [1] 18.82 12.80 13.98 17.63 16.69 12.05 13.58 13.59 16.90 15.36
```

## Performance

The overhead of `Pipe()` function is very low. Its performance is very close to `%>>%`. In intensive iterations, using `Pipe()` may also save some time. For more details, see pipeR's vignette [Performance](http://cran.r-project.org/web/packages/pipeR/vignettes/Performance.html).

## Conclusion

While `%>%` and `%>>%` implements operator-based pipeline like in F#, `Pipe()` function implements an object-like pipeline mechanism like the implementation in jQuery in JavaScript and LINQ in C#.

It dynamically creates closures as if the object had the child function to operate with it. It is more light-weight and easier to type than operator approach especially in R which requires user-defined operators take a name enclosed by `% %`.

If you like this idea, just install pipeR with

```r
install.packages("pipeR")
```

and try `Pipe()`.
