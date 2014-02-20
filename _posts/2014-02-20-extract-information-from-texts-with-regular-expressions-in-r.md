---
layout: post
title: Extract information from texts with regular expressions in R
categories:
- blog
- R
---

People love dealing with well-structured data. It costs much less efforts than working with disorganized raw texts.

In economic and financial research, we typically download data from open-access websites or authentication-required databases. These sources may provide data in multiple formats. For example, almost all databases are able to provide data in CSV format, which is a widely supported standard format. In R, it is convenient to call `read.csv()` to import the CSV file as a data frame with the right header and data types.

However, not all data files are well organized. Although dealing with poorly organized data is pain-staking, sometimes even a nightmire, it adds value to the job of data analysts. Built-in functions like `read.table()` and `read.csv()` work in most situations, but under some other circumstances these functions do not help.

For example, if you need to analyze a raw data (`messages.txt`) organized in a *CSV-like* format as pasted below, you had better be careful when applying `read.csv()`.

```no-highlight
2014-02-01,09:20:25,James,Ken,Hey, Ken!
2014-02-01,09:20:29,Ken,James,Hey, how are you?
2014-02-01,09:20:41,James,Ken, I'm ok, what about you?
2014-02-01,09:21:03,Ken,James,I'm feeling excited!
2014-02-01,09:21:26,James,Ken,What happens?
```

Suppose you want to import this file as a data frame like this:

```no-highlight
        Date     Time Sender Receiver                 Message
1 2014-02-01 09:20:25  James      Ken               Hey, Ken!
2 2014-02-01 09:20:29    Ken    James       Hey, how are you?
3 2014-02-01 09:20:41  James      Ken I'm ok, what about you?
4 2014-02-01 09:21:03    Ken    James    I'm feeling excited!
5 2014-02-01 09:21:26  James      Ken           What happens?
```

However, if you blindly call `read.csv()` you will find it does not work out correctly. This dataset is somehow special in the message column: There are commas that will be interpreted as separators in CSV file. Below is the data frame translated from the raw texts.

```no-highlight
          V1       V2    V3    V4                   V5               V6
1 2014-02-01 09:20:25 James   Ken                  Hey             Ken!
2 2014-02-01 09:20:29   Ken James                  Hey     how are you?
3 2014-02-01 09:20:41 James   Ken               I'm ok  what about you?
4 2014-02-01 09:21:03   Ken James I'm feeling excited!                 
5 2014-02-01 09:21:26 James   Ken        What happens?                 
```

There are various methods to tackle this problem. One of the simplist and most robust way is to use the so-called [Regular Expression](https://en.wikipedia.org/wiki/Regular_expression). Don't worry if you feel strange about the terminology. Its usage is very simple: Describe the **pattern** that matches the text and extract the desired part from that text.

Before we apply the technique, we need some basic knowledge. The best way to motivate is look at a simpler problem and consider what is needed to solve the problem.

Suppose we are dealing with the following texts (`fruits.txt`) and we need to distinguish texts that match a particular pattern from the ones that do not.

```no-highlight
apple: 20
orange: missing
banana: 30
pear: sent to Jerry
watermelon: 2
blueberry: 12
strawberry: sent to James
```

Now we want to pick out all fruits with a number rather than a message. Although we can easily finish the task visually, it can be hard for a computer. If the number of lines exceeds two thousand, it can be easy for a computer with appopriate technique applied and be hard, time-consuming, and error-prone for human. Here the right techniqe is definitely regular expression.

Regular expressions solve problems in two stages: first is patterning to match the text, and second is grouping to extract information in need.

## Patterning

Note that to solve the problem, our computer does not have to understand what fruit means. We only need to tell the pattern of what we want. Literally, we want to get all lines that start with a word followed by a semicolon and a space, and ends with an integer rather than words or other symbols.

Regular expression provides us a way to represent the pattern in a standard way. The pattern above can be translated to `\w+:\s\d+` where `\w` means a word character, `\s` a space character, `\d` a digit character. More specifically, `\w+` means one or more word characters, `:` is exactly the symbol we expect to see after a word, and `\d+` means one or more digit characters. See, this pattern is so magic that it represents all cases we want and exclude all cases we don't want.

To pick out the desired cases in R, we run the following code:

```r
fruits <- readLines("fruits.txt")
library(stringr)
matches <- str_match(fruits,"\\w+:\\s\\d+")
```

Note that `\` in R should be written as `\\` to avoid escaping. Then we can see what `matches` results in.

```no-highlight
     [,1]           
[1,] "apple: 20"    
[2,] NA             
[3,] "banana: 30"   
[4,] NA             
[5,] "watermelon: 2"
[6,] "blueberry: 12"
[7,] NA             
```

See, we successfully distinguish desirable lines from undesirable ones. The lines that do not match the pattern yield `NA`, which can be eliminated by `na.omit`.

Once the pattern works correctly, we can step to the second stage: grouping.

## Grouping

Grouping is to make marks in the pattern to tell which parts we want to extract from the texts. The simplest way is to use parenthesis. In this problem, we can modify the pattern to `(\w+):\s(\d+)` where two groups are marks: one is the fruit name matched by `\w+`, and the other is the number of the fruit matched by `\d+`.

Now we can use this modified version of pattern to extract the information we want. To proceed, we call `str_match` again with the new pattern.

```r
matches <- str_match(fruits,"(\\w+):\\s(\\d+)")
```

This time, `matches` is a matrix with more than one columns.

```no-highlight
     [,1]            [,2]         [,3]
[1,] "apple: 20"     "apple"      "20"
[2,] NA              NA           NA  
[3,] "banana: 30"    "banana"     "30"
[4,] NA              NA           NA  
[5,] "watermelon: 2" "watermelon" "2" 
[6,] "blueberry: 12" "blueberry"  "12"
[7,] NA              NA           NA  
```

The groups in parenthesis are extracted from the text and are put to column 2 and 3. Now we can easily transform this character matrix to a data frame with the right header and data types.

```r
# transform to data frame
fruits.df <- data.frame(na.omit(matches[,-1]),stringsAsFactors=FALSE)

# add a header
colnames(fruits.df) <- c("fruit","quantity")

# convert type of quantity from character to integer
fruits.df$quantity <- as.integer(fruits.df$quantity)
```

Now `fruits.df` is a data frame with the right header and data types.

```no-highlight
       fruit quantity
1      apple       20
2     banana       30
3 watermelon        2
4  blueberry       12
```

Finally this problem is perfectly solved with regular expression.

Now let's go back to the problem we face in the very beginning. The procedure is exactly the same with the previous one: patterning and grouping.

First, let's look at a typical line of the raw data.

```no-highlight
2014-02-01,09:20:29,Ken,James,Hey, how are you?
```

It is obvious that all lines are based on the same format, that is, date, time, sender, receiver, message are separated by comma. The only special thing is that comma may appear in the message but we don't want our program to interpret it as a separator. 

Note that regular expression perfectly works with this purpose as it did in the previous example. Its magic is nothing but a group of identifiers used to represent different kinds of characters and symbols. For example, `\d` represents a single **d**igit, `\w` a single **w**ord character, and `\s` a single **s**pace character (e.g. space or tab), as we all mentioned. Moreover, `[0-9]` represents a single integer from 0 to 9, `[a-z]` a single lower capital letter from a to z, `.` represents any single symbol, and so on. To represent one or more symbols that follow the same pattern, just place a `+` after the symbolic indentifier. For example, `\d+` represents a chain of integers like `123`. 

However, there are situations where expected pattern does not appear at all. Then we need to place a `*` after the symbolic indentifier to mark that this particular pattern may appear once or more, or even may not appear, in order to match a wide range of texts.

Here I list some patterns that match `Text1` and `Text2` but do not match `Unmatched`.

```no-highlight
Pattern       Text1  Text2  Unmatched 
\d\d\w        23m    56k    a1p       
\d+\w         1t     234g   m         
\w\s*\w       mv     m v    5_m       
\d-\d-\d      1-2-3  2-3-5  1-2-a     
\w+:\d+       mm:12  sd:3   1:a       
[0-9]*[a-z]+  pq     12pp   x12       
```

If you want to learn more specific examples and the full set of identifiers, [this website](http://www.regular-expressions.info/) will help.

Let's go back to our problem. We need to recognize a sufficiently general pattern of a typical line. The following is the pattern with grouping we should figure out.

```no-highlight
(\d+-\d+-\d+),(\d+:\d+:\d+),(\w+),(\w+),\s*(.+)
```

This pattern is like a key. Once we get it, we are confident to be able to open the door. Now we need to import the raw texts line by line. A working method is to call `readLines()` function. The function requires that the raw text ends with a new line. 

```r
msgs <- readLines("data/messages.txt")
```

Then we need to work out the pattern that represents the text and the information we want to extract from the text.

```r
library(stringr)
pattern <- "(\\d+-\\d+-\\d+),(\\d+:\\d+:\\d+),(\\w+),(\\w+),\\s*(.+)"
matches <- str_match(msgs,pattern)
msgs.df <- data.frame(matches[,-1])
colnames(msgs.df) <- c("Date","Time","Sender","Receiver","Message")
```

The pattern here looks like some secret code. Don't worry. That's exactly how regular expression works, and it should make some sense now if you go through the examples above. 

The regular expression works perfectly. `msgs.df` looks like the following structure.

```no-highlight
        Date     Time Sender Receiver                 Message
1 2014-02-01 09:20:25  James      Ken               Hey, Ken!
2 2014-02-01 09:20:29    Ken    James       Hey, how are you?
3 2014-02-01 09:20:41  James      Ken I'm ok, what about you?
4 2014-02-01 09:21:03    Ken    James    I'm feeling excited!
5 2014-02-01 09:21:26  James      Ken           What happens?
```

That's exactly what we want. We extract information from a mess of raw data. In other words, we find out gold from a mess of wetlands!
