---
layout: post
title: "More operators or more syntax?"
categories: blog
tags: [ r, pipeR, Pipe, magrittr, pipe, pipeline ]
highlight: [ r ]
---



The motivation of pipeline operator is to make code more readable. In many cases, it indeed better organizes code so that the logic is presented in human-readable fluent style. In other cases, however, such operators can make things worse.

Recently, I had an interesting discussion on how to add side effect piping to pipeR functionality (in this [issue](https://github.com/renkun-ken/pipeR/issues/30)), just like the tee operator (`%T>%`) does. [Linlin Yan](https://github.com/yanlinlin82) initially suggested to introduce a new **operator** to handle this while my opinion is to introduce a new **syntax**. I'm not sure if a new operator is a good idea when there are too many, but at least he pointed out the central problem:

*More operators or more syntax?*

First, let me announce that the new version of pipeR supports element extraction by 


```r
x <- list(a=1,b=2)
x %>>% (a) # as if x[["a"]]
```

```
[1] 1
```

as well as side effect piping by the following syntax:


```r
mtcars %>>%
  (~ cat("columns:",ncol(.),"\n")) %>>%    # only for side effect
  head(3)
```

```
columns: 11 
```

```
               mpg cyl disp  hp drat    wt  qsec vs am gear carb
Mazda RX4     21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
Mazda RX4 Wag 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
Datsun 710    22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
```

The side-effect syntax can be best described as **Just add `~` to the left side of lambda expression to make it side effect**.

As I mentioned in the beginning, pipelined expressions are not necessarily human-readable. Let me show you why, with the side effect piping examples.

Suppose we are dealing with some example data like `mtcars`. We can use forward piping mechanism to construct a pipeline to process the data from the beginning to the end. This time we need to do some intermediate work that should not interrupt the pipeline. In practice, the work can often be logging and printing so that we can make sure the data and pipeline works correctly.

For example, when a user-defined data in input to the pipeline, we may want to print its mean value to make sure the data is not ridiculous. Without side-effect piping, inserting a `mean()` function into the pipeline will interrupt it because its output should not be the input of the next function.
Side effect piping simply evaluates the expression for side-effect and returns the original input value.

magrittr's solution to side-effect piping is another operator, `%T>%`, which does the same thing as `%>%` except that it returns its left-hand side value so that the value is still being piped to the next function.

Here's an example with the latest dev version:


```r
library(magrittr)
mtcars %T>%
  (l(. ~ cat("data:",ncol(.),"columns\n"))) %>%
  subset(mpg >= quantile(mpg, 0.05) & mpg <= quantile(mpg,0.95)) %T>%
  (l(. ~ cat("qualified rows:",nrow(.),"\n"))) %>%
  lm(mpg ~ cyl + disp + wt, data = .) %>%
  summary %$%
  coefficients %T>%
  (l(. ~ cat("coefficients:",class(.),"\n"))) %T>%
  (l(. ~ cat("significants:",length(which(.[,4]<=0.01)),"\n"))) %>%
  (l(coe ~ coe[-1,1]))
```

```
data: 11 columns
qualified rows: 28 
coefficients: matrix 
significants: 3 
```

```
        cyl        disp          wt 
-1.94573939  0.01270474 -3.05552146 
```

The example involves `%>%`, `%T>%` and `%$%` in one pipeline. Some of the lines do real work that influences the next input value, some are evaluated only for side effect, and the rest is extracting element from previous list.

If I want to understand the code, I must examine it line by line and for each line I must look from the first letter to the last operator to make sure I remember how this particular result will be dealt with. 

If I'm not familiar with the code, and I only take a glimpse of it, I would definitely not catch the important lines, nor could I quickly know the input for a given line without carefully back-looking at the operator before that line or several lines. You can randomly pick a line and try to quickly understand its input and how it will run, you would probably find it brain consuming. Maybe the above example is poorly implemented but it is quite unreadable to me.

Here's the alternative implementation with pipeR's operator and syntax.


```r
library(pipeR)
mtcars %>>%
  (~ cat("data:",ncol(.),"columns\n")) %>>%
  subset(mpg >= quantile(mpg, 0.05) & mpg <= quantile(mpg,0.95)) %>>%
  (~ cat("qualified rows:",nrow(.),"\n")) %>>%
  lm(formula = mpg ~ cyl + disp + wt) %>>%
  summary %>>%
  (coefficients) %>>%
  (~ cat("coefficients:",class(.),"\n")) %>>%
  (~ cat("significants:",length(which(.[,4]<=0.01)),"\n")) %>>%
  (coe ~ coe[-1,1])
```

```
data: 11 columns
qualified rows: 28 
coefficients: matrix 
significants: 3 
```

```
        cyl        disp          wt 
-1.94573939  0.01270474 -3.05552146 
```

You may find that all lines end with `%>>%`, which means there's only one operator that is put to work and you don't have to care about it any more.
The other thing is you can clearly distinguish the side-effect expressions from the working ones that transform the data to the next stage, because all side effect starts with `~`.

If I ask you the input of a random line, you must be able to quickly figure it out by back scanning until one line that does not start from `~`. In fact, all syntax design in pipeR are carefully introduced so that you can quickly figure out the main branch of piping by overlooking the side branches when necessary.

In fact, in the latest version of pipeR, a new and pretty interesting syntax is introduced as light-weight side-effect: `(? expr)`. It simply prints out the value of `expr` and returns the input value.

With this new syntax, the previous example can start like this:


```r
mtcars %>>%
  (? ncol(.)) %>>%
  subset(mpg >= quantile(mpg, 0.05) & mpg <= quantile(mpg,0.95)) %>>%
  (? nrow(.)) %>>%
  lm(formula = mpg ~ cyl + disp + wt) %>>%
  summary %>>%
  (coefficients)
```

```
? ncol(.)
[1] 11
? nrow(.)
[1] 28
```

```
               Estimate  Std. Error   t value     Pr(>|t|)
(Intercept) 38.71180800 2.273665885 17.026164 6.674394e-15
cyl         -1.94573939 0.539423500 -3.607072 1.412530e-03
disp         0.01270474 0.009908378  1.282223 2.120122e-01
wt          -3.05552146 0.860716677 -3.549974 1.627839e-03
```

Why the design? I should say that the pipeline operator is a meta function that transforms workflows. And the modifier to its functionality should deserve meta-level syntax to distinguish from user input. That's why I choose `(~ expr)` because it looks like side effect, `(? expr)` because it looks like a question. After all, the syntax should be intuitve and easily distinguishable to better represent ideas and better for eye-reading. And I don't define two functions to do the work because they mix the level and meta-level operations.

In a word, with `(~ expr)` you can do anything you want without breaking the pipeline. With `(? expr)`, you can ask anything you want to know without breaking the pipeline. And I believe the new syntax is carefully designed so that you don't have to carry heavy burden when you review the code where too many different small operators appear in the end of each line.

Finally, what maximizes the readability of the code is that **each line determines what happens by themselves, not by the operator in the end of the previous line** and that **you can find out the work of each line by looking at starting letters, not the ending operators**.

Therefore, pipeline is not necessarily readable especially when too many operators are involved, but with carefully designed syntax, it becomes much easier to write readable code.
