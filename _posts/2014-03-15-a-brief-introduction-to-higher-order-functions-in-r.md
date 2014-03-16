---
layout: post
title: A brief introduction to higher order functions in R
categories:
- blog
- R
---

In R, *function* may not be as special as it is in other programming languages; it is regarded as one of the many types and can be passed as an argument to some other `function`. The way we deal with other objects such `list` and `data.frame` definitely applies to `function`. Here is a simple example in which we define two functions and pass them to another function as an argument, respectively.

```r
add <- function(x,y,z) {
    x+y+z
}
product <- function(x,y,z) {
    x*y*z
}
aggregate(x,y,z,fun) {
    fun(x,y,z)
}
```

In the example code above, we first define two functions called `add` and `product` respectively. Then we define another function called `aggregate` that tries to aggregate the three numeric vectors `x`, `y`, and `z` in some way specified by function `fun`. Here `fun` is assumed to be a function that takes three arguments as we call it in the body of `aggregate`. This treatment makes `aggregate` function more flexible in that it allows us to define the specific way in which we actually aggregate data.

To use `aggregate` function, we only need to call:

```r
aggregate(1,2,3,product)
```

Therefore, `aggregate` in this example serves as a *higher-order function* because it is a function that takes a function as an argument.

In many situations, higher-order functions are shorter yet more expressive and implementation-neutral when a problem has diverse solutions but shares a common framework. For example, for-loop is an ordinary flow-control device that repeatedly does something but with a variable iterating along a vector.

Suppose we need to apply a function named `f` to each entry in a vector `x`. If the function in itself implemented to support vectorized operation, that is, it can directly take a vector as an argument, we may just call `f(x)` to do the job. However, not many functions directly support vectorized operations, nor do they need to in some circumstances. If we still want to proceed, a readily working solution is to use a for-loop.

```r
result <- list()
for(i in seq_along(x)) {
    result[[i]] <- f(x[i])
}
```

In the code above, `seq_along(x)` produces a sequence from 1 to the length of 
`x`; `1:length(x)` will do the same thing. The code looks simple and easy to implement, but it has some drawbacks in its design. 

First, if the operation gets more complicated, it would be hard to read if we adopt a for-loop. Actually, the code tells R *how* to finish the task by a for-loop but does not tell us *what* the task is about. Trust me, when you take a look at very long loops, it would be a tough task to figure out what it is acutally doing. 

Second, the for-loop relies on *side effect*. We say an operation has no side effect if it always yields the same output whenever it is given the same input. In this case, if you go through a vector and apply a function to each entry by a for-loop, you have to change the environment by introducing a iterating variable (e.g. `i`) and some others. In casual usage, it does no harm; but if you want to apply parallelism to the whole operation, side effects will be the roots of almost all bugs. That is because an operation with side effects depends not only on the input but also on the environment, which makes it too unpredictable to directly apply parallel computing correctly.

Note that R is a programming language that specializes in statistical computing. Its key advantage that sets it apart from other statistical software is its easiness to work with, its flexibility and extensibility. However, the correctness of code always beats simplicity, flexibility, extensibility and almost all other features. Unfortunately, the traditional techniques like for-loop relies on side effect, which is likely to not only reduce readability but also undermine the validity. 

To tacle the problem, it is better to write R code that is easier for *users* to read rather than for the *machine*, and use higher-order functions that can be free from side-effects.

R provides a higher-order function called `lapply` which applies a function iteratively along a vector or a list, and yields a list containing the values.Using higher-order functions like `lapply` is just a good way to improve readability and correctness of the code. To demonstrate the point, here we show another simple example. The example implemented in for-loop can now be altered to using `lapply`.

```r
result <- lapply(x, f)
```

It looks easy and elegant, doesn't it? `lapply` simpliy takes a vector or list as the first arugment, and a function as the second argument to apply to each entry. All results will be put into a new list and returned. If the function `f` needs more argument, you can still pass them by specifying more named arguments for `lapply`. For example, if `add` takes two argument, `x` and `y`, you can still pass the value of `y` in `lapply`.

```r
add <- function(x,y) {
    x+y
}
result <- lapply(1:10, add, y=3)
```

Another way is to use *closure*. The code can be written like the following.

```r
add <- function(y) {
    function(x) {
        x+y
    }
}
result <- lapply(1:10,add(3))
```

Here function `add` does not directly compute the value of `x+y`; instead, it computes a function that adds `y` to argument `x`. The anonymous function returned is called closure, which may be covered in more details in later posts.

If you want to get a numeric vector rather than a list, you can use `sapply` instead. It is the same with `lapply` except for that it simplifies the result by yielding a vector or a matrix.

```r
result <- sapply(1:10,add(3))
```

In addition to `lapply` and `sapply`, R offers several more higher-order functions. `apply` calls a function to aggregate a certain dimension of a matrix. More common in other functional programming languages are `Filter`, `Map`, `Reduce`, `Find`, `Position`, and `Negate`. For more details on how we can use these higher-order functions, please read *Common Higher-Order Functions in Functional Programming Languages* in R documentation.

In R programming, I strongly recommend that you use higher-order functions to do most iterative tasks and better avoid using for-loops to minimize the unnecessary side effects that may reduce the performance and accountability of your code.