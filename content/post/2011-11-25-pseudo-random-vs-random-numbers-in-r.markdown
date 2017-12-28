---
categories: R
comments: true
date: 2011-11-25T00:00:00Z
published: true
title: Pseudo-Random vs. Random Numbers in R
url: /2011/11/25/pseudo-random-vs-random-numbers-in-r/
---

Earlier, I found [an interesting post from Bo Allen](http://www.boallen.com/random-numbers.html) on [pseudo-random](http://en.wikipedia.org/wiki/Pseudorandom_number_generator) vs [random numbers](http://en.wikipedia.org/wiki/Random_number), where the author uses a simple bitmap ([heat map](http://en.wikipedia.org/wiki/Heat_map)) to show that the __rand__ function in [PHP](http://www.php.net/) has a systematic pattern and compares these to __truly random__ numbers obtained from [random.org](http://www.random.org/). The post's results suggest that pseudo-randomness in [PHP](http://www.php.net/) is faulty and, in general, should not be underestimated in practice. Of course, the findings should not be too surprising, as there is a large body of literature on the subtleties, philosophies, and implications of the __pseudo__ aspect of the most common approaches to random number generation. However, it is silly that [PHP](http://www.php.net/)'s [random number generator (RNG)](http://en.wikipedia.org/wiki/Random_number_generation) displays such an obvious pattern nowadays because there are several decent, well-studied pseudo-RNG algorithms available as well as numerous tests for randomness.  For a good introduction to [RNG](http://en.wikipedia.org/wiki/Random_number_generation), I recommend [John D. Cook's discussion on testing a random number generator](http://www.johndcook.com/blog/2010/12/06/how-to-test-a-random-number-generator-2/).

Now, I would never use [PHP](http://www.php.net/) for any (serious) statistical analysis, partly due to my fondness for [R](http://www.r-project.org/), nor do I doubt the practicality of the [RNG](http://en.wikipedia.org/wiki/Random_number_generation) in [R](http://www.r-project.org/). But I was curious to see what would happen. So, created equivalent plots in [R](http://www.r-project.org/) to see if a __rand__ equivalent would exhibit a systematic pattern like in [PHP](http://www.php.net/), even if less severe. Also, for comparison, I chose to use [the __random__ package](http://cran.r-project.org/web/packages/random/index.html), from [Dirk Eddelbuettel](http://dirk.eddelbuettel.com/), to draw __truly random__ numbers from [random.org](http://www.random.org/). Until today, I had only heard of [the __random__ package](http://cran.r-project.org/web/packages/random/index.html) but had never used it.

I have provided the function __rand_bit_matrix__, which requires the number of rows and columns to display in the plotted bitmap. To create the bitmaps, I used [the __pixmap__ package](http://cran.r-project.org/web/packages/pixmap/index.html) rather than [the much-loved __ggplot2__ package](http://had.co.nz/ggplot2/), simply because of how easy it was for me to create the plots. (If you are concerned that I have lost the faith, please note that I am aware of the awesomeness of [__ggplot2__](http://had.co.nz/ggplot2/) and [its ability](http://ramhiser.com/blog/2011/06/05/conways-game-of-life-in-r-with-ggplot2-and-animation/) [to create heat maps](http://learnr.wordpress.com/2010/01/26/ggplot2-quick-heatmap-plotting/).)

It is important to note that there were two challenges that I encountered when using drawing __truly random numbers__.

1. Only 10,000 numbers can be drawn at once from [random.org](http://www.random.org/). (This is denoted as __max_n_random.org__ in the function below.)
2. There is a daily limit to the number of times the [random.org](http://www.random.org/) service will provide numbers.

To overcome the first challenge, I split the total number of bits into separate calls, if necessary. This approach, however, increases our number of requests, and after too many requests, you will see the error: __random.org suggests to wait until tomorrow__. Currently, I do not know the exact number of allowed requests or if the amount of requested random numbers is a factor, but looking back, I would guess about 20ish large requests is too much.

Below, I have plotted 500 x 500 bitmaps based on the _random_ bits from both of [R](http://www.r-project.org/) and [random.org](http://www.random.org/). As far as I can tell, no apparent patterns are visible in either plot, but from the graphics alone, our conclusions are limited to ruling out obvious systematic patterns, which were exhibited from the [PHP](http://www.php.net/) code. I am unsure if the [PHP](http://www.php.net/) folks formally tested their [RNG](http://en.wikipedia.org/wiki/Random_number_generation) algorithms for __randomness__, but even if they did, the code in both [R](http://www.r-project.org/) and [PHP](http://www.php.net/) is straightforward and provides a quick eyeball test. Armed with similar plots alone, the [PHP](http://www.php.net/) devs could have sought for better [RNG](http://en.wikipedia.org/wiki/Random_number_generation) algorithms — perhaps, borrowed those from [R](http://www.r-project.org/).


{{< highlight r >}}
library("plyr")
library("pixmap")
library("random")

rand_bit_matrix <- function(num_rows = 500, num_cols = 500, max_n_random.org = 10000, 
    seed = NULL) {
    # I have copied the following function directly from help('integer').
    is.wholenumber <- function(x, tol = .Machine$double.eps^0.5) {
        abs(x - round(x)) < tol
    }
    
    # The number of bits to draw at 'random'.
    n <- num_rows * num_cols
    if (n <= 0 || !is.wholenumber(n)) {
        stop("The number of bits 'n' should be a natural number.")
    }
    
    if (!is.null(seed)) {
        set.seed(seed)
    }
    
    # Create a matrix of pseudo-random bits.
    bits_R <- replicate(n = num_cols, sample(c(0, 1), size = num_rows, replace = TRUE))
    
    # Because random.org will only return a maximum of 10,000 numbers at a
    # time, we break this up into several calls.
    seq_n_random.org <- rep.int(x = max_n_random.org, times = n%/%max_n_random.org)
    if (n%%max_n_random.org > 0) {
        seq_n_random.org <- c(seq_n_random.org, n%%max_n_random.org)
    }
    bits_random.org <- lapply(seq_n_random.org, function(n) {
        try_default(randomNumbers(n = n, min = 0, max = 1, col = 1), NA)
    })
    
    bits_random.org <- matrix(unlist(bits_random.org), nrow = num_rows, ncol = num_cols)
    
    list(R = bits_R, random.org = bits_random.org)
}

bit_mats <- rand_bit_matrix(num_rows = 500, num_cols = 500, seed = 42)

with(bit_mats, plot(pixmapGrey(data = R, nrow = nrow(R), ncol = ncol(R)), main = "R"))
{{< / highlight >}}

![plot of chunk code](http://i.imgur.com/hZd2N.png) 

{{< highlight r >}}
with(bit_mats, plot(pixmapGrey(data = random.org, nrow = nrow(random.org), 
    ncol = ncol(random.org)), main = "random.org"))
{{< / highlight >}}

![plot of chunk code](http://i.imgur.com/E59lB.png) 

