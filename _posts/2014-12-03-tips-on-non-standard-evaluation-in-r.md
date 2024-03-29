---
layout: post
title: "Tips on non-standard evaluation in R"
categories: blog
tags: [ r, nse ]
highlight: [ r ]
---



One of my favorite features of R is its meta-programming facilities. It can be simply demonstrated by the following examples.

An ordinary use of R is to do statistical computing. We can evaluate something like 


```r
sin(0)
```

```
[1] 0
```

Meta-programming in R allows users to manipulate the expression to evaluate. We can use `quote` to create an object that represents a function call.


```r
quote(sin(0))
```

```
sin(0)
```

In this way, `sin(0)` is not evaluated but parsed as a `call` object which basically can be represented as a list of function name and the arguments.


```r
as.list(quote(sin(0)))
```

```
[[1]]
sin

[[2]]
[1] 0
```

Now we can use some functions to manipulate the expression so that we can alter the expression to evaluate.


```r
expr <- quote(sin(0))
expr[[1L]] <- quote(cos)
expr
```

```
cos(0)
```

Now we can see the expression is modified. This feature, as stated in the official documentation, is *computing on language*, that is, R not only is able to compute on literal values, but also on language itself. Then what can we do with the modified expression? We can evaluate it using `eval()` as if we do in the console.


```r
eval(expr)
```

```
[1] 1
```

The meta-programming feature requires the definition of language objects and a meta-function to evaluate such a language object. In R, a `call` object represents a function call like `sin(x)`, a `name` or `symbol` represents a variable/symbol like `x`, a `numeric`, `character`, etc. represents literal values like `1`, `"a"`, and finally `eval()` evaluates such a language object in a specific context.

The evaluation context matters when we evaluate an expression containing symbols that are not self-contained. Consider the following example.


```r
expr <- quote(sin(x))
eval(expr)
```

```
Error in eval(expr, envir, enclos): object 'x' not found
```

`x` is not found because in the evaluation environment, there is no value assigned to symbol `x`. If we assign some value to `x` now,


```r
x <- 0
eval(expr)
```

```
[1] 0
```

and evaluate the expression again, `x` can be found and the value can be successfully calculated. More specifically, `expr` is evaluated in the global environment. Once `x` is given a value in this environment, the expression can be evaluated.

We can create our own environment for an expression to evaluate using `new.env()`.


```r
env <- new.env()
env$y <- 0
expr <- quote(cos(y))
expr
```

```
cos(y)
```

If we evaluate `cos(y)` directly in the global environment, it should produce an error.


```r
eval(expr)
```

```
Error in eval(expr, envir, enclos): object 'y' not found
```

If we evaluate it in `env` where `y` is properly defined, then it should produce the right result.


```r
eval(expr, env)
```

```
[1] 1
```

We can also create two environments, one being the parent of the other, and evaluate the expression.


```r
env1 <- new.env()
env1$x <- 1
env2 <- new.env(parent = env1)
env2$y <- 2
```

Now we have two environments, `env1` and `env2`. `env2`'s parent is `env1`, and `env1`'s parent is global environment. This means that when `eval()` evaluates an expression in the context of `env2` and encounters a symbol that is not defined in it, it will go to `env1`, and then global environment, package environments, and base environment. Now we evaluate a simple arithmetic expression containing symbols in these two environments.


```r
expr <- quote(x + y)
eval(expr, env1)
```

```
Error in eval(expr, envir, enclos): object 'y' not found
```


```r
eval(expr, env2)
```

```
[1] 3
```

In fact, `eval(expr, envir, enclos)` basically follows the following logic to evaluate a quoted expression: 

1. If `envir` is an `environment`, then evaluate `expr` in `envir` by looking for symbols all the way along `envir` and its parent environments until found. 
2. If `envir` is a `list`, then evaluate `expr` given the symbols defined in the list; Whenever a symbol is not found in the list, the function will go to `enclos` environment to find along the chain until found.
3. If a symbol is not found until the empty environment (the only environment having no parent) is reached, an error occurs.

This logic has some notable "strange" behaviors. For example, 


```r
env3 <- new.env()
eval(quote(x <- 1), env3)
ls.str(env3)
```

```
x :  num 1
```

The assignment works as expected. However, if we supply a named list of values to serve the evaluation, and specify `env3` as the enclosing environment, then the assignment does not work as some might expect.


```r
eval(quote(y <- p), list(p = 1), env3)
ls.str(env3)
```

```
x :  num 1
```

It is understandable because `list(p = 1)` provides a set of symbols that are given values. If the symbols in `expr` are not defined in the list, then it should go to the enclosing environment and its parents to see if the symbol exists. Therefore the assignment does not happen in `env3` at all. Only symbol lookup happens there.

Meta-programming allows a function to interpret its arguments in its own way. For example, we can write a `slice` function that perform easy subsetting with a vector using non-standard evaluation.


```r
slice <- function(x, s) {
  s <- substitute(s)
  x[eval(s, list(. = length(x)))]
}
```

`substitute(s)` prevents `s` from being evaluated but substitute the input value by its expression. Then we can get a `call` or a `name` so that we can manipulate it.

`slice()` does nothing special but evaluates argument `s` in a non-standard way: `s` is evaluated with a specially defined symbol whose value is the length of `x`. Therefore we can use it to easily slice a vector like


```r
slice(1:10, 1:(.-3))
```

```
[1] 1 2 3 4 5 6 7
```

```r
slice(1:10, c(1, .))
```

```
[1]  1 10
```

However, `slice()` does not work correctly in the following example:


```r
local({
  p <- 3
  slice(1:10, c(1,.,p))
})
```

```
Error in eval(expr, envir, enclos): object 'p' not found
```

In this case, `p` is not found because `c(1,.,p)` is not evaluated in the calling environment but the function environment whose parent is the environment where the function is defined (i.e. global environment). We need to modify `slice()` to always evaluate the expression in the environment where it is created.


```r
slice <- function(x, s) {
  s <- substitute(s)
  x[eval(s, list(. = length(x)), parent.frame())]
}
```

The enclosing environment is set to `parent.frame()` to refer to the calling environment which, in this case, is exactly the context where the expression is fully meaningful.


```r
local({
  p <- 3
  slice(1:10, c(1,.,p))
})
```

```
[1]  1 10  3
```

Using non-standard evaluation, you have to be careful. The above shows the first point: **Evaluate the expression in a context where the expression is fully meaningful.** In R, you need to take care of the environments to ensure the symbol search path is correct. To do that, you need to be aware of the scope of the evaluation context.

Another point I want to stress is that a danger of non-standard evaluation is 
potential clash of symbol interpretation. If two functions both use non-standard evaluation to facilitate some kind of tasks, they might clash on interpreting certain symbols. 

For example, functions in rlist package and magrittr package use some non-standard evaluation to make things easy. In the following cases, they two might clash.


```r
library("rlist")
library("magrittr")
data <- list("a","b","b","c","b","a")
list.table(data, .)
```

```
.
a b c 
2 3 1 
```

```r
data %>% list.table(.)
```

```
Error in table(useNA = "ifany"): nothing to tabulate
```

In this case, `.` is interpreted by `list.table()` as the current element in iteration in `data`, that is, it tries to create a table from `data` directly by its element value. However, `%>%` interprets `.` differently: it understands `.` as the demand that the user wants to pipe `data` to `.` as an argument of `list.table`. Therefore, `%>%` basically evaluates `list.table(data)` rather than `list.table(data, .)`. I call this behavior an *interpretation clash*, which might result in unexpected error.

Another example can be reproduced using dplyr and the latest release of magrittr. In the latest release of `%>%`, it creates a chaining function easily by starting from `.`. For example, 


```r
sapply(1:3, . %>% seq_len %>% sum)
```

```
[1] 1 3 6
```

`. %>% seq_len %>% sum` actually creates a function. It works by giving `.` a special behavior: if `.` appears as the start of the pipeline, then a functional sequence should be created. This largely facilitates creating such functions in many cases. However, its risk is *interpretation clash* when such magic is used with other functions giving the same symbol different behaviors. For example,


```r
library("dplyr")
mtcars %>%
  group_by(vs) %>%
  do(. %>% 
      arrange(desc(mpg)) %>% 
      head(3))
```

```
Error: Results are not data frames at positions: 1, 2
```

In this case `do()` works with `.` representing each group data frame. User might want to arrange each group by `mpg` in descending order and take the top 3 records and finally get a combined data frame. However, `.` encounters an interpretation clash: `do()` gives `.` a special meaning but `%>%` understands `.` differently and creates a functional sequence which is not expected by `do()`.


```r
mtcars %>%
  group_by(vs) %>%
  do(head(arrange(., desc(mpg)), 3))
```

```
Source: local data frame [6 x 11]
Groups: vs

   mpg cyl  disp  hp drat    wt  qsec vs am gear carb
1 26.0   4 120.3  91 4.43 2.140 16.70  0  1    5    2
2 21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
3 21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
4 33.9   4  71.1  65 4.22 1.835 19.90  1  1    4    1
5 32.4   4  78.7  66 4.08 2.200 19.47  1  1    4    1
6 30.4   4  75.7  52 4.93 1.615 18.52  1  1    4    2
```

My conclusion is simple: non-standard evaluation can be magic, but be careful when you use it. It may produce unexpected errors because the evaluation context is wrong, or the interpretation of a symbol is inconsistent.
