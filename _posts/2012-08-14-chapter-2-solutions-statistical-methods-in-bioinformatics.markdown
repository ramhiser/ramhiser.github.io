---
layout: post
title: "Chapter 2 Solutions - Statistical Methods in Bioinformatics"
date: 2012-08-14 20:42
comments: true
categories: [Textbook, Solutions, Bioinformatics, Statistics]
---

As I have mentioned previously, I have begun reading [Statistical Methods in Bioinformatics by Ewens and Grant](http://amzn.to/PiXCiU) and working selected problems for each chapter. In this post, I will give my solution to two problems. The first problem is pretty straightforward.

## Problem 2.20
> Suppose that a parent of genetic type _Mm_ has three children. Then the parent transmits the _M_ gene to each child with probability 1/2, and __the genes that are transmitted to each of the three children are independent__. Let $$I_1 = 1$$ if children 1 and 2 had the same gene transmitted, and $$I_1 = 0$$ otherwise. Similarly, let $$I_2 = 1$$ if children 1 and 3 had the same gene transmitted, $$I_2 = 0$$ otherwhise, and let $$I_3 = 1$$ if children 2 and 3 had the same gene transmitted, $$I_3 = 0$$ otherwise.

The question first asks us to how that the three random variables are pairwise independent but not independent. The pairwise independence comes directly from the bolded phrase in the problem statement. Now, to show that the three random variables are not independent, denote by $$p_j$$ the probability that $$I_j = 1$$, $$j = 1, 2, 3$$. If we had independence, then the following statement would be true:

$$
P(I_1 = 1, I_2 = 1, I_3 = 0) = p_1 p_2 (1 - p_3).
$$

However, notice that the event in the lefthand side can never happen because if $$I_1 = 1$$ and $$I_2 = 1$$, then $$I_3$$ must be 1. Hence, the lefthand side must equal 0, while the righthand side equals 1/8. Therefore, the three random variables are not independent.

The question also asks us to discuss why the variance of $$I_1 + I_2 + I_3$$ is equal to the sum of the individual variances. Often, this is only the case of the random variables are independent. But because the random variables here are pairwise independent, the covariances must be 0. Thus, the equality must hold.

## Problems 2.23 - 2.27

While I worked the above problem because of its emphasis on genetics, the following set of problems is much more fun in terms of the mathematics because of its usage of approximations.

> For $$i = 1, \ldots, n$$, let $$X_i$$ be the $$i$$th lifetime of certain cellular proteins until degradation. We assume that $$X_1, \ldots, X_n$$ are iid random variables, each of which is [exponentially distributed](http://en.wikipedia.org/wiki/Exponential_distribution) with rate parameter $$\lambda > 0$$. Furthermore, let $$n = 2m + 1$$ be an odd integer.

This set of questions is concerned with the mean and variance of the sample median, $$X_{(m + 1)}$$, where $$X_{(i)}$$ denotes the $$i$$th [order statistic](http://en.wikipedia.org/wiki/Order_statistic). First, note that the mean and variance of the minimum value $$X_{(1)}$$ are $$1/(n\lambda)$$ and $$1/(n\lambda)^2$$, respectively. From the [memoryless property](http://en.wikipedia.org/wiki/Memorylessness#The_memoryless_distributions_are_the_exponential_distributions) of the [exponential distribution](http://en.wikipedia.org/wiki/Exponential_distribution), the mean value of the time until the next protein degrades is independent of the previous. However, there are now $$n - 1$$ proteins remaining. Thus, the mean and variance of $$X_{(2)}$$ are $$1/(n\lambda) + 1/((n-1)\lambda)$$ and $$1/(n\lambda)^2 + 1/((n-1)\lambda)^2$$, respectively. Continuining in this manner, we have

$$
E[X_{(m + 1)}] = \frac{1}{(2m + 1)\lambda} + \frac{1}{(2m)\lambda} + \ldots + \frac{1}{(m + 1)\lambda}
$$

and

$$
Var[X_{(m + 1)}] = \frac{1}{(2m + 1)^2\lambda^2} + \frac{1}{(2m)^2\lambda^2} + \ldots + \frac{1}{(m + 1)^2\lambda^2}.
$$

### Approximation of $$E[X_{(m + 1)}]$$

Now, we wish to approximate the mean with a much simpler formula. First, from (B.7) in Appendix B, we have

$$
\sum_{k=1}^n \frac{1}{k} \approx \log n + \gamma,
$$

where $$\gamma$$ is [Euler's constant](http://en.wikipedia.org/wiki/Euler%E2%80%93Mascheroni_constant). Then, we can write the expected sample median as

$$
\begin{aligned}
E[X_{(m + 1)}] &= \frac{1}{\lambda} \sum_{k=m+1}^{2m+1} \frac{1}{k}\\
&= \frac{1}{\lambda} \left(\sum_{k=1}^{2m+1} \frac{1}{k} - \sum_{k=1}^{m} \frac{1}{k} \right)\\
&\approx \frac{1}{\lambda} \left( \log (2m + 1) + \gamma - \log m - \gamma \right)\\
&= \frac{1}{\lambda} \log \left(2 + \frac{1}{m} \right).
\end{aligned}
$$

Hence, as $$n \rightarrow \infty$$, this approximation goes to $$ \frac{\log 2}{\lambda}$$, which is the median of an exponentially distributed random variable. Specifically, the median is the solution to $$F_X(x) = 1/2$$, where $$F_X$$ denotes the [cumulative distribution function](http://en.wikipedia.org/wiki/Cumulative_distribution_function) of the random variable $$X$$.

### Improved Approximation of $$E[X_{(m + 1)}]$$

It turns out that we can improve this approximation with the following two results:

$$
\begin{aligned}
\sum_{k=1}^n \frac{1}{k} &= \log n + \frac{1}{2n} + o\left(\frac{1}{n}\right),\\
\log \left(\frac{2m + 1}{m}\right) &= \log 2 + \frac{1}{2m} + o\left(\frac{1}{m}\right).
\end{aligned}
$$

Following the derivation of our above approximation, we have that

$$
\begin{aligned}
E[X_{(m + 1)}] &= \frac{1}{\lambda} \left(\sum_{k=1}^{2m+1} \frac{1}{k} - \sum_{k=1}^{m} \frac{1}{k} \right)\\
&= \frac{1}{\lambda} \left( \log (2m + 1) + \gamma - \log m - \gamma \right)\\
&= \frac{1}{\lambda} \left[ \log \left( \frac{2m + 1}{m} \right) + \frac{1}{2(2m+1)} - \frac{1}{2m} + o\left(\frac{1}{m}\right)  \right]\\
&= \frac{\log 2}{\lambda} + \frac{1}{2\lambda (2m + 1)} + o\left(\frac{1}{m}\right).
\end{aligned}
$$

### Approximation of $$Var[X_{(m + 1)}]$$

We can also approximate $$Var[X_{(m + 1)}]$$ using the approximation

$$
\frac{1}{a^2} + \frac{1}{(a+1)^2} + \ldots + \frac{1}{b^2} \approx \frac{1}{a - 1/2} - \frac{1}{b + 1/2}.
$$

With $$a = m+1$$ and $$b = 2m + 1$$, we have

$$
Var[X_{(m + 1)}] \approx \frac{2}{\lambda^2} + o\left(\frac{1}{n^2}\right).
$$