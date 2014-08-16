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
  layer_smooths()$
  value
```

<!--html_preserve--><div id="plot_id331905250-container" class="ggvis-output-container">
<div id="plot_id331905250" class="ggvis-output"></div>
<div class="plot-gear-icon">
<nav class="ggvis-control">
<a class="ggvis-dropdown-toggle" title="Controls" onclick="return false;"></a>
<ul class="ggvis-dropdown">
<li>
Renderer: 
<a id="plot_id331905250_renderer_svg" class="ggvis-renderer-button" onclick="return false;" data-plot-id="plot_id331905250" data-renderer="svg">SVG</a>
 | 
<a id="plot_id331905250_renderer_canvas" class="ggvis-renderer-button" onclick="return false;" data-plot-id="plot_id331905250" data-renderer="canvas">Canvas</a>
</li>
<li>
<a id="plot_id331905250_download" class="ggvis-download" data-plot-id="plot_id331905250">Download</a>
</li>
</ul>
</nav>
</div>
</div>
<script type="text/javascript">
var plot_id331905250_spec = {
	"data" : [
		{
			"name" : "value0",
			"format" : {
				"type" : "csv",
				"parse" : {
					"mpg" : "number",
					"wt" : "number"
				}
			},
			"values" : "\"mpg\",\"wt\"\n21,2.62\n21,2.875\n22.8,2.32\n21.4,3.215\n18.7,3.44\n18.1,3.46\n14.3,3.57\n24.4,3.19\n22.8,3.15\n19.2,3.44\n17.8,3.44\n16.4,4.07\n17.3,3.73\n15.2,3.78\n10.4,5.25\n10.4,5.424\n14.7,5.345\n32.4,2.2\n30.4,1.615\n33.9,1.835\n21.5,2.465\n15.5,3.52\n15.2,3.435\n13.3,3.84\n19.2,3.845\n27.3,1.935\n26,2.14\n30.4,1.513\n15.8,3.17\n19.7,2.77\n15,3.57\n21.4,2.78"
		},
		{
			"name" : "value0/smooth1",
			"format" : {
				"type" : "csv",
				"parse" : {
					"pred_" : "number",
					"resp_" : "number"
				}
			},
			"values" : "\"pred_\",\"resp_\"\n10.4,5.26709870786738\n10.6974683544304,5.14704047855112\n10.9949367088608,5.03118876520954\n11.2924050632911,4.91950899506212\n11.5898734177215,4.81196659532837\n11.8873417721519,4.70852699322776\n12.1848101265823,4.6091556159798\n12.4822784810127,4.51381789080397\n12.779746835443,4.42247924491978\n13.0772151898734,4.33510510554671\n13.3746835443038,4.25171377248888\n13.6721518987342,4.17322495920078\n13.9696202531646,4.09937968773676\n14.2670886075949,4.02937682750615\n14.5645569620253,3.96241524791825\n14.8620253164557,3.89901422494375\n15.1594936708861,3.84312733060352\n15.4569620253165,3.79025491272949\n15.7544303797468,3.74131843080013\n16.0518987341772,3.70318820076903\n16.3493670886076,3.67282222701719\n16.646835443038,3.64700052597305\n16.9443037974684,3.62250311406507\n17.2417721518987,3.59611000772168\n17.5392405063291,3.56460122337134\n17.8367088607595,3.5248055796778\n18.1341772151899,3.47838183528461\n18.4316455696203,3.42863815827054\n18.7291139240506,3.37701737152652\n19.026582278481,3.32496229794347\n19.3240506329114,3.2726173323394\n19.6215189873418,3.21156757675365\n19.9189873417722,3.14421038563615\n20.2164556962025,3.07569029842943\n20.5139240506329,3.01115185457599\n20.8113924050633,2.95573959351838\n21.1088607594937,2.91553607179047\n21.4063291139241,2.88630635433215\n21.7037974683544,2.84793204808514\n22.0012658227848,2.80989137002157\n22.2987341772152,2.77165845439756\n22.5962025316456,2.73270743546924\n22.8936708860759,2.69252434983033\n23.1911392405063,2.65099196354259\n23.4886075949367,2.60839825876548\n23.7860759493671,2.56503916494569\n24.0835443037975,2.52121061152996\n24.3810126582278,2.47720852796498\n24.6784810126582,2.43332884369747\n24.9759493670886,2.38986748817416\n25.273417721519,2.34712039084176\n25.5708860759494,2.30538348114697\n25.8683544303797,2.26495268853653\n26.1658227848101,2.22612394245714\n26.4632911392405,2.18919317235551\n26.7607594936709,2.15445630767837\n27.0582278481013,2.12220927787242\n27.3556962025316,2.09271002326136\n27.653164556962,2.06479889572395\n27.9506329113924,2.03789645504918\n28.2481012658228,2.01211937280276\n28.5455696202532,1.98758432055039\n28.8430379746835,1.96440796985775\n29.1405063291139,1.94270699229056\n29.4379746835443,1.9225980594145\n29.7354430379747,1.90419784279527\n30.0329113924051,1.88762301399857\n30.3303797468354,1.87299024459011\n30.6278481012658,1.86028970448271\n30.9253164556962,1.84928668066065\n31.2227848101266,1.8399745891983\n31.520253164557,1.83235763010661\n31.8177215189873,1.82644000339654\n32.1151898734177,1.82222590907903\n32.4126582278481,1.81971954716503\n32.7101265822785,1.81892511766547\n33.0075949367089,1.81984682059132\n33.3050632911392,1.82248885595351\n33.6025316455696,1.826855423763\n33.9,1.83295072403072"
		},
		{
			"name" : "scale/x",
			"format" : {
				"type" : "csv",
				"parse" : {
					"domain" : "number"
				}
			},
			"values" : "\"domain\"\n9.225\n35.075"
		},
		{
			"name" : "scale/y",
			"format" : {
				"type" : "csv",
				"parse" : {
					"domain" : "number"
				}
			},
			"values" : "\"domain\"\n1.31745\n5.61955"
		}
	],
	"scales" : [
		{
			"name" : "x",
			"domain" : {
				"data" : "scale/x",
				"field" : "data.domain"
			},
			"zero" : false,
			"nice" : false,
			"clamp" : false,
			"range" : "width"
		},
		{
			"name" : "y",
			"domain" : {
				"data" : "scale/y",
				"field" : "data.domain"
			},
			"zero" : false,
			"nice" : false,
			"clamp" : false,
			"range" : "height"
		}
	],
	"marks" : [
		{
			"type" : "symbol",
			"properties" : {
				"update" : {
					"fill" : {
						"value" : "#000000"
					},
					"size" : {
						"value" : 50
					},
					"x" : {
						"scale" : "x",
						"field" : "data.mpg"
					},
					"y" : {
						"scale" : "y",
						"field" : "data.wt"
					}
				},
				"ggvis" : {
					"data" : {
						"value" : "value0"
					}
				}
			},
			"from" : {
				"data" : "value0"
			}
		},
		{
			"type" : "line",
			"properties" : {
				"update" : {
					"stroke" : {
						"value" : "#000000"
					},
					"strokeWidth" : {
						"value" : 2
					},
					"x" : {
						"scale" : "x",
						"field" : "data.pred_"
					},
					"y" : {
						"scale" : "y",
						"field" : "data.resp_"
					},
					"fill" : {
						"value" : "transparent"
					}
				},
				"ggvis" : {
					"data" : {
						"value" : "value0/smooth1"
					}
				}
			},
			"from" : {
				"data" : "value0/smooth1"
			}
		}
	],
	"width" : 504,
	"height" : 504,
	"legends" : [],
	"axes" : [
		{
			"type" : "x",
			"scale" : "x",
			"orient" : "bottom",
			"layer" : "back",
			"grid" : true,
			"title" : "mpg"
		},
		{
			"type" : "y",
			"scale" : "y",
			"orient" : "left",
			"layer" : "back",
			"grid" : true,
			"title" : "wt"
		}
	],
	"padding" : null,
	"ggvis_opts" : {
		"keep_aspect" : false,
		"resizable" : true,
		"padding" : {},
		"duration" : 250,
		"renderer" : "svg",
		"hover_duration" : 0,
		"width" : 504,
		"height" : 504
	},
	"handlers" : null
};
ggvis.getPlot("plot_id331905250").parseSpec(plot_id331905250_spec);
</script><!--/html_preserve-->

`Pipe()` also works with rlist.


```r
library(rlist)
Pipe(1:10)$
  list.filter(x -> x <= 5)$
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
model$summary()$.(z$r.squared)
```

```
Error: object 'z' not found
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
 [1] 1.552 1.056 1.469 1.484 1.812 1.370 1.547 1.170 1.625 1.882
```

```r
rnd(min = 10, max = 20)
```

```
$value : numeric 
------
 [1] 12.80 13.98 17.63 16.69 12.05 13.58 13.59 16.90 15.36 17.11
```

