---
layout: post
title: Difference between assignment operators in R
categories:
- blog
- R
---

For R beginners, the first operator they use is probably the *assignment operator* `<-`. [Google's R Style Guide](http://google-styleguide.googlecode.com/svn/trunk/Rguide.xml) suggests that we use `<-` rather than `=` even though the equal sign is also allowed in R to do exactly the same thing when we assign a value to a variable. However, some might feel inconvenient because you need to type two characters to represent one symbol, which is different from many other programming languages.

As a result, many users ask *Why we should use `<-` as the assignment operator?*

Here I provide a simple explanation to the difference between `<-` and `=` in R.

First, let's look at a simple example.

{% highlight R %}
x <- rnorm(100)
y <- 2*x + rnorm(100)
lm(formula=y~x)
{% endhighlight %}

The above code uses both `<-` and `=` symbols, but the work they do are different. `<-` in the first two lines are used as **assignment operator** while `=` in the third line does not serves as assignment operator but an operator that specifies a named parameter `formula` for `lm` function.

In other words, `<-` evaluates the the expression on its right side (`rnorm(100)`) and assign the evaluated value to the symbol (variable) on the left side (`x`) in the current environment. `=` evaluates the expression on its right side (`y~x`) and set the evaluated value to the parameter of the name specified on the left side (`formula`) for a certain function.

We know that `<-` and `=` are perfectly equivalent when they are used as assignment operators.

Therefore, the above code is equivalent to the following code:

{% highlight R %}
x = rnorm(100)
y = 2*x + rnorm(100)
lm(formula=y~x)
{% endhighlight %}

Here, we only use `=` but for two different purposes: line 1 and 2 use `=` as assignment operator and line 3 use `=` as named parameter setter.

Now let's see what happens if we change all `=` symbols to `<-`.

{% highlight R %}
x <- rnorm(100)
y <- 2*x + rnorm(100)
lm(formula <- y~x)
{% endhighlight %}

If you run this code, you will find that the output are similar. But if you inspect the environment, you will observe the difference: a new variable `formula` is defined in the environment whose value is `y~x`. So what happens?

Actually, in the third line, two things happened: First, we introduce a new symbol (variable) `formula` to the environment and assign it a formula-typed value `y~x`. Then, the value of `formula` is provided to the **first paramter** of function `lm` rather than, accurately speaking, to the **parameter named formula**, although this time they mean the identical parameter of the function.

To test it, we conduct an experiment. This time we first prepare the data.

{% highlight R %}
x <- rnorm(100)
y <- 2*x+rnorm(100)
z <- 3*x+rnorm(100)
data <- data.frame(z,x,y)
rm(x,y,z)
{% endhighlight %}

Basically, we just did similar things as before except that we store all vectors in a data frame and clear those numeric vectors from the environment. We know that `lm` function accepts a data frame as the data source when a formula is specified.

Standard usage:

{% highlight R %}
lm(formula=z~x+y,data=data)
{% endhighlight %}

Working alternative where two named parameters are reordered:

{% highlight R %}
lm(data=data,formula=z~x+y)
{% endhighlight %}

Working alternative with side effects that two new variable are defined:

{% highlight R %}
lm(formula <- z~x+y, data <- data)
{% endhighlight %}

Nonworking example:

{% highlight R %}
lm(data <- data, formula <- z~x+y)
{% endhighlight %}

The reason is exactly what I mentioned previously. We reassign `data` to `data` and give its value to the first argument (`formula`) of `lm` which only accepts a formula-typed value. We also try to assign `z~x+y` to a new variable `formula` and give it to the second argument (`data`) of `lm` which only accepts a data frame-typed value. Both types of the parameter we provide to `lm` are wrong, so we receive the message:

``` Text
Error in as.data.frame.default(data) : 
  cannot coerce class ""formula"" to a data.frame
```

In conclusion, for better readability of R code, I suggest that we only use `<-` for assignment and `=` only for specifying named parameter.
