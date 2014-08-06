---
layout: post
title: Introducing rlist 0.3
categories: blog
tags: [ r, list, rlist, chaining, pipeline ]
highlight: [ r ]
---



rlist 0.3 is released! This package now provides a wide range of functions for dealing with list objects. It can be especially useful when they are used to store non-tabular data.

Two notable features are added in this version. First, `list.search` and several comparer functions are added in support of fuzzy filtering and searching. Second, `List` object is added to provide object-based, light-weight chaining operation for list objects.

In the examples, I will use both [rlist](http://renkun.me/rlist/) and [pipeR](http://renkun.me/pipeR/) package for easier coding. If you are not yet familiar with either of them, please visit the project pages first.

## Fuzzy filtering

Consider the following data in YAML format.


```r
library(rlist)
library(pipeR)
people <- list.parse('
  Ken:
    name: Ken
    age: 24
    interests: [reading, coding]
    friends: [James, Ashley]
  James:
    name: James
    age: 23
    interests: [reading, movie, hiking]
    friends: [Ken, David]
  Ashley:
    name: Ashley
    age: 25
    interests: [movies, music, reading]
    friends: [Ken, David]
  David:
    name: David
    age: 24
    interests: [coding, hiking]
    friends: [Ashley, James]
',type = "yaml")
str(people)
```

```
List of 4
 $ Ken   :List of 4
  ..$ name     : chr "Ken"
  ..$ age      : int 24
  ..$ interests: chr [1:2] "reading" "coding"
  ..$ friends  : chr [1:2] "James" "Ashley"
 $ James :List of 4
  ..$ name     : chr "James"
  ..$ age      : int 23
  ..$ interests: chr [1:3] "reading" "movie" "hiking"
  ..$ friends  : chr [1:2] "Ken" "David"
 $ Ashley:List of 4
  ..$ name     : chr "Ashley"
  ..$ age      : int 25
  ..$ interests: chr [1:3] "movies" "music" "reading"
  ..$ friends  : chr [1:2] "Ken" "David"
 $ David :List of 4
  ..$ name     : chr "David"
  ..$ age      : int 24
  ..$ interests: chr [1:2] "coding" "hiking"
  ..$ friends  : chr [1:2] "Ashley" "James"
```

In this version, `equal()` are added to support logical and fuzzy filtering and searching at different levels of exactness. By default, this function tests atomic equality between two atomic vectors unless more parameters are specified. Here are some examples:

Find names of people whose age is 24.


```r
people %>>% 
  list.filter(equal(24,age)) %>>%
  list.mapv(name, use.names = FALSE)
```

```
[1] "Ken"   "David"
```

If I change the target value to `24.0` and set `exactly = TRUE` then there would be no remaining results since ages are integers in the data but the condition is to find a numeric value. 


```r
people %>>%
  list.filter(equal(24,age,exactly = TRUE))
```

```
named list()
```

In fact, `equal(exactly = TRUE)` calls `identical()` which tells whether two objects are exactly the same. It not only compares values but their attributes such as names. In this sense, `c(1,2)` is not identical but atomically equal to `c(x=1,y=2)`. With `exactly = TRUE` this function becomes the strictest comparer.

In most cases, however, we don't need the target value and original data are exactly the same. Therefore, `equal()` by default performs atomic equality test.

Sometimes, we need to filter values that includes certain values, here we can specify `include = TRUE`.

Note that `exactly`, `equal`, and `include` are logical comparers. In addition to them, fuzzy comparers are also supported. They are `pattern` and `dist` arguments. 

If `pattern = TRUE` then `x` serves as a regular expression pattern and `equal()` tests whether the value matches it. For example, find all people whose interests include something that ends with "ing".


```r
people %>>% 
  list.filter(any(equal("ing$",interests,pattern = TRUE))) %>>%
  list.mapv(name, use.names = FALSE)
```

```
[1] "Ken"    "James"  "Ashley" "David" 
```

If `dist = ` is given a number, then it will tolerate all values with a maximum string distance implemented in [stringdist package](http://cran.r-project.org/web/packages/stringdist/). 

Note that in `interests`, `movie` and `movies` both appear but mean the same thing. To tolerate that difference and regard them as equal, specify a string distance in `equal()`. Now find those who like movies.


```r
people %>>%
  list.filter(any(equal("movies",interests,dist = 1))) %>>%
  list.mapv(name, use.names = FALSE)
```

```
[1] "James"  "Ashley"
```

If there are more records in `people` and more variants or typos in the term "movies", an appropriate string distance will tolerate them with higher flexibility than regular expressions.

## Fuzzy searching

In the new version of rlist, `list.search()` is added to support searching in a list. This function does nothing special but evaluates an expression recursively using `rapply`. 

For example, we search all character vectors which include "James".


```r
people %>>%
  list.search(x -> "James" %in% x, classes = "character")
```

```
$Ken
$Ken$friends
[1] "James"  "Ashley"


$James
$James$name
[1] "James"


$David
$David$friends
[1] "Ashley" "James" 
```

It is clearly shown that all character vectors are examined by the condition in contrast with `list.filter`.

`equal()` is also designed for facilitating logical and fuzzy searching. For example, search all character vectors that contain values with more than 5 letters and ending with letter "s".


```r
people %>>%
  list.search(any(equal("\\w{5}s$",pattern = TRUE)),"character")
```

```
$Ashley
$Ashley$interests
[1] "movies"  "music"   "reading"
```

Search all character vectors that contain string like "Kenny" with maximal distance 3.


```r
people %>>%
  list.search(any(equal("Kenny", dist = 3)),"character")
```

```
$Ken
$Ken$name
[1] "Ken"


$James
$James$friends
[1] "Ken"   "David"


$Ashley
$Ashley$friends
[1] "Ken"   "David"
```


## List environment for light-weight chaining

Another feature this version introduces is the `List` object which is designed for light-weight chaining. If you have read my post about [pipeR 0.4](http://renkun.me/blog/2014/08/04/introducing-pipeR-0.4.html), you will be familiar with the feature I'm going to talk about.

Here we continue using `people` data but in `List` approach. First, let's take a look at the traditional way to use `rlist` functions to query a list object like `people`. Suppose we need to extract the names of those who like reading.


```r
people %>>%
  list.filter("reading" %in% interests) %>>%
  list.mapv(name)
```

```
     Ken    James   Ashley 
   "Ken"  "James" "Ashley" 
```

Now we can use `List` object created by `List()` to make it easier.


```r
List(people)$
  filter("reading" %in% interests)$
  mapv(name)
```

```
List environment
Data:
     Ken    James   Ashley 
   "Ken"  "James" "Ashley" 
```

In essence, `List` is just an environment in which almost all rlist functions are contained but with shorter names. If you need to call external functions, use `List()$call(fun,...)`.

Note that the `List environment` header in the output indicates that the local functions (or closures) always return the next-level `List` object to allow chaining. To extract the data in the `List` object, use `[]` or `$data`.


```r
List(people)$cases(interests)$data
```

```
[1] "coding"  "hiking"  "movie"   "movies"  "music"   "reading"
```


```r
List(people)$cases(friends) []
```

```
[1] "Ashley" "David"  "James"  "Ken"   
```

In both cases the data stored in the object are extracted for further use.
