---
layout: page
title: "projects"
sharing: false
footer: true
---

* [regdiscrim](https://github.com/ramey/regdiscrim) - An R package that is a collection of various regularization methods for discriminant analysis and supervised learning. This is includes an implementation of [Regularized Discriminant Analysis](http://www.jstor.org/pss/2289860) from [Professor Jerome H. Friedman](http://www-stat.stanford.edu/~jhf/) at Stanford.

* [diagdiscrim](https://github.com/ramey/diagdiscrim) - An R package that is a collection of classification models that assume conditionally independent features among all classes. These models have been shown to have excellent classification peformance with high-dimensional microarray data and can be viewed as special cases of the [Naive Bayes classifier](http://en.wikipedia.org/wiki/Naive_Bayes_classifier).

* [errorest](https://github.com/ramey/errorest) - An R package that provides a variety of error rate estimation methods for supervised classification. To assess classification performance, I have provided several widely known estimators, including random split / Monte-Carlo cross-validation, cross-validation, bootstrap, .632, .632+, apparent, and bolstering/smoothed error rates. Furthermore, I am planning to implement other lesser known estimators. Currently, I am working to add MapReduce support for these estimators via the [RHIPE](http://ml.stat.purdue.edu/rhipe/) package and to add easy integration with the [caret](http://cran.r-project.org/web/packages/caret/index.html) package. 