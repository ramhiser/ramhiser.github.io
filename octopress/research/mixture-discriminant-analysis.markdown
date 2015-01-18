---
layout: page
title: "Technical Report"
comments: false
sharing: true
footer: true
---

* **Title**. An Overview of Mixture Discriminant Analysis

* **Document**.
  * [PDF Document](https://github.com/ramey/tech-reports/blob/master/mixture-discrim-analysis/mixture-discriminant-analysis.pdf?raw=true)
  * [LaTeX and R Code](https://github.com/ramey/tech-reports/tree/master/mixture-discrim-analysis)

* **Authors**. [John A. Ramey](http://ramhiser.com)

* **Abstract**. [Hastie and Tibshirani (1996)](http://www.jstor.org/stable/2346171)
proposed a discriminant analysis model based on a mixture of Gaussians, each of
which share a common covariance matrix. The mixture discriminant analysis (MDA)
model provides a natural extension of the standard Gaussian assumptions
underlying the well-known linear and quadratic discriminant analysis
methods. However, because the estimators for the model have no closed-form, an
EM algorithm was used. In this document, we provide a verbose construction of
the model along with a thorough derivation of the parameter estimators as some
of the details from [Hastie and Tibshirani (1996)](http://www.jstor.org/stable/2346171)
were indeed sparse. Using a simple two-dimensional simulated data set, we
demonstrate that the MDA classifier identifies three classes, each of which has
non-adjacent subclasses, whereas standard Gaussian assumption employed in linear
and quadratic discriminant analysis is clearly inadequate and produces poor
decision boundaries.

``` latex BibTeX Record
@techreport{Ramey2013:MDA,
author = {Ramey, John},
title = {An Overview of Mixture Discriminant Analysis},
year = {2013}
}
```