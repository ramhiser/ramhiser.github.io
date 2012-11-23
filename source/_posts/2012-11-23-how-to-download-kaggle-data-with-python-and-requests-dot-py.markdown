---
layout: post
title: "How to Download Kaggle Data with Python and requests.py"
date: 2012-11-23 10:08
comments: true
categories: Kaggle, Python, requests.py
---

Recently I started playing with [Kaggle](http://kaggle.com). I quickly became frustrated that in order to download their data I had to use their website. I prefer instead the option to download the data programmatically. After some Googling, [the best recommendation I found](http://www.kaggle.com/c/ClaimPredictionChallenge/forums/t/772/downloading-the-data-from-kaggle-to-remote-linux-instance) was to use [lynx](http://en.wikipedia.org/wiki/Lynx_(web_browser)). [My friend Anthony](http://twitter.com/amcclosky) recommended that alternatively I should write a Python script.

Although Python is not my primary language, I was intrigued by how simple it was to write the script using [requests.py](http://docs.python-requests.org/). In this example, I download the training data set from [Kaggle's Digit Recognizer competition](http://www.kaggle.com/c/digit-recognizer/data).

The idea is simple:

1. Attempt to download a file from Kaggle but get blocked because you are not logged in.
2. Login with [requests.py](http://docs.python-requests.org/).
3. Download the data.

Here's the code:

{% gist 4121260 %}

Simply change `my_username` and `my_password` to your Kaggle login info. Feel free to optimize the chunk size to your liking.