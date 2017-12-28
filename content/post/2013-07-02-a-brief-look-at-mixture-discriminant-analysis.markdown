---
categories:
- R
- Statistics
- Machine Learning
- Classification
- Mixture Models
comments: true
date: 2013-07-02T00:00:00Z
title: A Brief Look at Mixture Discriminant Analysis
url: /2013/07/02/a-brief-look-at-mixture-discriminant-analysis/
---

Lately, I have been working with finite mixture models for my postdoctoral work
on data-driven automated [gating](http://en.wikipedia.org/wiki/Gate_%28cytometry%29).
Given that I had barely scratched the surface with mixture models in the
classroom, I am becoming increasingly comfortable with them. With this in mind,
I wanted to explore their application to classification because there are times
when a single class is clearly made up of multiple subclasses that are not
necessarily adjacent.

As far as I am aware, there are two main approaches (there are lots and lots of
variants!) to applying finite mixture models to classfication:

1. The [Fraley and Raftery approach](http://www.stat.washington.edu/raftery/Research/PDF/fraley2002.pdf) via [the mclust R package](http://cran.r-project.org/web/packages/mclust/index.html)

2. The [Hastie and Tibshirani approach](http://www.jstor.org/stable/2346171) via [the mda R package](http://cran.r-project.org/web/packages/mda/index.html)

Although the methods are similar, I opted for exploring the latter method. Here
is the general idea. There are $$K \ge 2$$ classes, and each class is assumed to
be a Gaussian mixuture of subclasses. Hence, the model formulation is generative,
and the posterior probability of class membership is used to classify an
unlabeled observation. Each subclass is assumed to have its own mean vector, but
all subclasses share the same covariance matrix for model parsimony. The model
parameters are estimated via [the EM algorithm](http://en.wikipedia.org/wiki/Expectation%E2%80%93maximization_algorithm).

Because the details of the likelihood in the paper are brief, I realized I was a
bit confused with how to write the likelihood in order to determine how much
each observation contributes to estimating the common covariance matrix in the
M-step of the EM algorithm. Had each subclass had its own covariance matrix, the
likelihood would simply be the product of the individual class likelihoods and
would have been straightforward. The source of my confusion was how to write
the complete data likelihood when the classes share parameters.

I decided to write up a document that explicitly defined the likelihood and
provided the details of the EM algorithm used to estimate the model parameters.
[The document is available here](http://ramhiser.com/research/mixture-discriminant-analysis.html)
along with [the LaTeX and R code](https://github.com/ramey/tech-reports/tree/master/mixture-discrim-analysis).
If you are inclined to read the document, please let me know if any notation is
confusing or poorly defined. Note that I did not include the additional topics
on reduced-rank discrimination and shrinkage.

To see how well the mixture discriminant analysis (MDA) model worked, I
constructed a simple toy example consisting of 3 bivariate classes each having 3
subclasses. The subclasses were placed so that within a class, no subclass is
adjacent. The result is that no class is Gaussian. I was interested in seeing
if the MDA classifier could identify the subclasses and also comparing its
decision boundaries with those of [linear discriminant analysis (LDA)](http://en.wikipedia.org/wiki/Linear_discriminant_analysis)
and [quadratic discriminant analysis (QDA)](http://en.wikipedia.org/wiki/Quadratic_classifier#Quadratic_discriminant_analysis).
I used the implementation of the LDA and QDA classifiers in [the MASS package](http://cran.r-project.org/web/packages/MASS/index.html).
From the scatterplots and decision boundaries given below,
the LDA and QDA classifiers yielded puzzling decision boundaries as expected.
Contrarily, we can see that the MDA classifier does a good job of identifying
the subclasses. It is important to note that all subclasses in this example have
the same covariance matrix, which caters to the assumption employed in the MDA
classifier. It would be interesting to see how sensitive the classifier is to
deviations from this assumption. Moreover, perhaps a more important investigation
would be to determine how well the MDA classifier performs as the feature
dimension increases relative to the sample size.

![LDA Decision Boundaries](http://i.imgur.com/LIQPL0u.png)

![QDA Decision Boundaries](http://i.imgur.com/GeyXCsf.png)

![MDA Decision Boundaries](http://i.imgur.com/lw0iBxe.png)

{{< highlight r >}}
library(MASS)
library(mvtnorm)
library(mda)
library(ggplot2)

set.seed(42)
n <- 500

# Randomly sample data
x11 <- rmvnorm(n = n, mean = c(-4, -4))
x12 <- rmvnorm(n = n, mean = c(0, 4))
x13 <- rmvnorm(n = n, mean = c(4, -4))

x21 <- rmvnorm(n = n, mean = c(-4, 4))
x22 <- rmvnorm(n = n, mean = c(4, 4))
x23 <- rmvnorm(n = n, mean = c(0, 0))

x31 <- rmvnorm(n = n, mean = c(-4, 0))
x32 <- rmvnorm(n = n, mean = c(0, -4))
x33 <- rmvnorm(n = n, mean = c(4, 0))

x <- rbind(x11, x12, x13, x21, x22, x23, x31, x32, x33)
train_data <- data.frame(x, y = gl(3, 3 * n))

# Trains classifiers
lda_out <- lda(y ~ ., data = train_data)
qda_out <- qda(y ~ ., data = train_data)
mda_out <- mda(y ~ ., data = train_data)

# Generates test data that will be used to generate the decision boundaries via
# contours
contour_data <- expand.grid(X1 = seq(-8, 8, length = 300),
                            X2 = seq(-8, 8, length = 300))

# Classifies the test data
lda_predict <- data.frame(contour_data,
                          y = as.numeric(predict(lda_out, contour_data)$class))
qda_predict <- data.frame(contour_data,
                          y = as.numeric(predict(qda_out, contour_data)$class))
mda_predict <- data.frame(contour_data,
                          y = as.numeric(predict(mda_out, contour_data)))

# Generates plots
p <- ggplot(train_data, aes(x = X1, y = X2, color = y)) + geom_point()
p + stat_contour(aes(x = X1, y = X2, z = y), data = lda_predict)
  + ggtitle("LDA Decision Boundaries")
p + stat_contour(aes(x = X1, y = X2, z = y), data = qda_predict)
  + ggtitle("QDA Decision Boundaries")
p + stat_contour(aes(x = X1, y = X2, z = y), data = mda_predict)
  + ggtitle("MDA Decision Boundaries")
{{< / highlight >}}
