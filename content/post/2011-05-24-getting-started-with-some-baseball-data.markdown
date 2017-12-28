---
categories:
- Statistics
- SQL
- Baseball
comments: true
date: 2011-05-24T00:00:00Z
title: Getting Started with Some Baseball Data
url: /2011/05/24/getting-started-with-some-baseball-data/
---

With all of the discussions (hype?) regarding applied statistics, machine learning, and data science, I have been looking for a go-to source of data unrelated to my day-to-day work. I loved baseball as
a kid. I love baseball now. I love baseball stats. Why not do a grown-up version of what I used to do when I spent hours staring at and memorizing baseball stats on the back of a few pieces of cardboard
on which I spent my allowance?

To get started, I purchased a copy of [Baseball Hacks](http://www.amazon.com/Baseball-Hacks-Joseph-Adler/dp/0596009429/ref=sr_1_1?ie=UTF8&qid=1306290220&sr=8-1). The author suggests the usage of MySQL,
so I will oblige. First, I downloaded some baseball data in MySQL format on my web server (Ubuntu 10.04) and decompressed it; when I downloaded the data, it was timestamped as 28 March 2011, so
double-check if there is an updated version.

{{< highlight bash >}}
mkdir baseball
cd baseball
wget http://www.baseball-databank.org/files/BDB-sql-2011-03-28.sql.zip
unzip BDB-sql-2011-03-28.sql.zip
{{< / highlight >}}

Next, in MySQL I created a user named __baseball__, a database entitled __bbdatabank__ and granted all privileges on this database to the user __baseball__. To do this, first open MySQL as root:

{{< highlight bash >}}
mysql -u root -p
{{< / highlight >}}

At the MySQL prompt, type: (Note the tick marks (`) around __bbdatabank__ when granting privileges.)

{{< highlight sql >}}
CREATE USER 'baseball'@'localhost' IDENTIFIED BY 'YourPassword';
CREATE database bbdatabank;
GRANT ALL PRIVILEGES ON `bbdatabank`.* TO 'baseball'@'localhost';
FLUSH PRIVILEGES;
quit
{{< / highlight >}}

Finally, we read the data into the database we just created by:

{{< highlight bash >}}
mysql -u baseball -p -s bbdatabank < BDB-sql-2011-03-28.sql
{{< / highlight >}}

That’s it! Most of this code has been adapted from [Baseball Hacks](http://www.amazon.com/Baseball-Hacks-Joseph-Adler/dp/0596009429/ref=sr_1_1?ie=UTF8&qid=1306290220&sr=8-1), although I’ve tweaked a
couple of things. As I progress through the book, I will continue to add interesting finds and code as posts. Eventually, I will move away from the book’s code as it focuses too much on the
"Intro to Data Exploration" reader with constant mentions of MS Access/Excel. The author means well though as he urges the reader to use *nix/Mac OS X.
