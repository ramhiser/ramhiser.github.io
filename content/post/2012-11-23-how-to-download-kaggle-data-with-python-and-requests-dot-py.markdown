---
categories:
- Kaggle
- Python
- requests.py
comments: true
date: 2012-11-23T00:00:00Z
title: How to Download Kaggle Data with Python and requests.py
url: /2012/11/23/how-to-download-kaggle-data-with-python-and-requests-dot-py/
---

Recently I started playing with [Kaggle](http://kaggle.com). I quickly became frustrated that in order to download their data I had to use their website. I prefer instead the option to download the data programmatically. After some Googling, [the best recommendation I found](http://www.kaggle.com/c/ClaimPredictionChallenge/forums/t/772/downloading-the-data-from-kaggle-to-remote-linux-instance) was to use [lynx](http://en.wikipedia.org/wiki/Lynx_(web_browser)). [My friend Anthony](http://twitter.com/amcclosky) recommended that alternatively I should write a Python script.

Although Python is not my primary language, I was intrigued by how simple it was to write the script using [requests.py](http://docs.python-requests.org/). In this example, I download the training data set from [Kaggle's Digit Recognizer competition](http://www.kaggle.com/c/digit-recognizer/data).

The idea is simple:

1. Attempt to download a file from Kaggle but get blocked because you are not logged in.
2. Login with [requests.py](http://docs.python-requests.org/).
3. Download the data.

Here's the code:

{{< highlight python >}}
import requests

# The direct link to the Kaggle data set
data_url = 'http://www.kaggle.com/c/digit-recognizer/download/train.csv'

# The local path where the data set is saved.
local_filename = "train.csv"

# Kaggle Username and Password
kaggle_info = {'UserName': "my_username", 'Password': "my_password"}

# Attempts to download the CSV file. Gets rejected because we are not logged in.
r = requests.get(data_url)

# Login to Kaggle and retrieve the data.
r = requests.post(r.url, data = kaggle_info, prefetch = False)

# Writes the data to a local file one chunk at a time.
f = open(local_filename, 'w')
for chunk in r.iter_content(chunk_size = 512 * 1024): # Reads 512KB at a time into memory
    if chunk: # filter out keep-alive new chunks
        f.write(chunk)
f.close()
{{< / highlight >}}

Simply change `my_username` and `my_password` to your Kaggle login info. Feel free to optimize the chunk size to your liking.