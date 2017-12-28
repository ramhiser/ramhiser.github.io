---
categories:
- R
- Machine Learning
- Statistics
- Bioinformatics
- Microarray
- Data
comments: true
date: 2012-12-29T00:00:00Z
title: High-Dimensional Microarray Data Sets in R for Machine Learning
url: /2012/12/29/high-dimensional-microarray-data-sets-in-r-for-machine-learning/
---

Much of my research in machine learning is aimed at small-sample, high-dimensional bioinformatics data sets. For instance, here is [a paper of mine on the topic](http://www.tandfonline.com/doi/full/10.1080/00949655.2011.625946).

A large number of papers proposing new machine-learning methods that target high-dimensional data use the same two data sets and consider few others. These data sets are the 1) [Alon colon cancer data set](https://github.com/ramey/datamicroarray/wiki/Alon-%281999%29), and the 2) [Golub leukemia data set](https://github.com/ramey/datamicroarray/wiki/Golub-%281999%29). Both of the corresponding papers were published in 1999, which indicates that the methods are not keeping up with the data-collection techology. Furthermore, the Golub data set is not useful as a benchmark data set because it is well-separated so that most methods have nearly perfect classification.

My goal has been to find several alternative data sets and provide them in a convenient location so that I could load and analyze them easily and then incorporate the results into my papers. Initially, I aimed to identify a few more data sets, but after I got going on this effort, I found a lot more. What started as a small project turned into something that has saved me a lot of time. I have created the [datamicroarray package available from my GitHub account](https://github.com/ramey/datamicroarray). For each data set included in the package, I have provided a script to download, clean, and save the data set as a named list. See the [README file](https://github.com/ramey/datamicroarray/blob/master/README.md) for more details about how the data are stored.

Currently, the package consists of 20 small-sample, high-dimensional data sets to assess machine learning algorithms and models. I have also included a [wiki on the package's GitHub repository](https://github.com/ramey/datamicroarray/wiki) that describes each data set and provides additional information, including a link to the original papers.

The biggest drawback at the moment is the file size of the R package because I store an RData file for each data set. I am investigating alternative approaches to download the data dynamically and am open to suggestions. Also note that the data descriptions are incomplete, so assistance is appreciated.

Feel free to use any of the data sets. As a disclaimer, you should ensure that the data are processed correctly before analyzing and incorporating the results into your own work.