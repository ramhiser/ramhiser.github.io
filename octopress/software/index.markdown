---
layout: page
title: "software"
sharing: false
footer: true
---

* [sparsediscrim](https://github.com/ramey/sparsediscrim) - An R package that is a collection of classification models that assume conditionally independent features among all classes. These models have been shown to have excellent classification peformance with high-dimensional microarray data and can be viewed as special cases of the [Naive Bayes classifier](http://en.wikipedia.org/wiki/Naive_Bayes_classifier).

* [regdiscrim](https://github.com/ramey/regdiscrim) - An R package that is a collection of various regularization methods for discriminant analysis and supervised learning. This is includes an implementation of [Regularized Discriminant Analysis](http://www.jstor.org/pss/2289860) from [Professor Jerome H. Friedman](http://www-stat.stanford.edu/~jhf/) at Stanford.

* [datamicroarray](https://github.com/ramey/datamicroarray) - An R package that provides a collection of scripts to download, process, and load small-sample, high-dimensional microarray data sets to assess machine learning algorithms and models. For each data set, we include a small set of scripts that automatically download, clean, and save the data set. Additionally, we include thorough descriptions and additional information about each microarray data set in the [package's wiki](https://github.com/ramey/datamicroarray/wiki). The majority of the microarary data sets included in the package are cancer-related

* [errorest](https://github.com/ramey/errorest) - An R package that provides a variety of error rate estimation methods for supervised classification. To assess classification performance, I have provided several widely known estimators, including random split / Monte-Carlo cross-validation, cross-validation, bootstrap, .632, .632+, apparent, and bolstering/smoothed error rates. Furthermore, I am planning to implement other lesser known estimators. Currently, I am working to add MapReduce support for these estimators via the [RHIPE](http://ml.stat.purdue.edu/rhipe/) package and to add easy integration with the [caret](http://cran.r-project.org/web/packages/caret/index.html) package. 