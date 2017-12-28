---
categories:
- Python
- Spark
- data-science
comments: true
date: 2015-02-01T00:00:00Z
title: Configuring IPython Notebook Support for PySpark
url: /2015/02/01/configuring-ipython-notebook-support-for-pyspark/
---

[Apache Spark](https://spark.apache.org/) is a great way for performing
large-scale data processing. Lately, I have begun working with
[PySpark](https://spark.apache.org/docs/0.9.0/python-programming-guide.html), a
way of interfacing with Spark through Python. After a discussion with a
coworker, we were curious whether PySpark could run from within an [IPython
Notebook](http://ipython.org/notebook.html).  It turns out that this is fairly
straightforward by setting up an IPython profile.

Here's the `tl;dr` summary:

1. Install Spark
2. Create PySpark profile for IPython
3. Some config
4. Simple word count example

The steps below were successfully executed using Mac OS X 10.10.2 and
[Homebrew](http://brew.sh/). The majority of the steps should be similar for
non-Windows environments. For demonstration purposes, Spark will run in local
mode, but the configuration can be updated to submit code to a cluster.

Many thanks to my coworker [Steve Wampler](https://twitter.com/stevewampler) who
did much of the work.

## Installing Spark

1. Download the [source for the latest Spark release](http://spark.apache.org/downloads.html)
2. Unzip source to `~/spark-1.2.0/` (or wherever you wish to install Spark)
3. From the CLI, type: `cd ~/spark-1.2.0/`
4. Install the Scala build tool: `brew install sbt`
5. Build Spark:  `sbt assembly` (Takes a while)

## Create PySpark Profile for IPython

After Spark is installed, let's start by creating a new IPython profile for PySpark.

{{< highlight bash >}}
ipython profile create pyspark
{{< / highlight >}}

To avoid port conflicts with other IPython profiles, I updated the default port
to `42424` within `~/.ipython/profile_pyspark/ipython_notebook_config.py`:

{{< highlight python >}}
c = get_config()

# Simply find this line and change the port value
c.NotebookApp.port = 42424
{{< / highlight >}}

Set the following environment variables in `.bashrc` or `.bash_profile`:

{{< highlight bash >}}
# set this to whereever you installed spark
export SPARK_HOME="$HOME/spark-1.2.0"

# Where you specify options you would normally add after bin/pyspark
export PYSPARK_SUBMIT_ARGS="--master local[2]"
{{< / highlight >}}

Create a file named `~/.ipython/profile_pyspark/startup/00-pyspark-setup.py` containing the following:

{{< highlight python >}}
# Configure the necessary Spark environment
import os
import sys

spark_home = os.environ.get('SPARK_HOME', None)
sys.path.insert(0, spark_home + "/python")

# Add the py4j to the path.
# You may need to change the version number to match your install
sys.path.insert(0, os.path.join(spark_home, 'python/lib/py4j-0.8.2.1-src.zip'))

# Initialize PySpark to predefine the SparkContext variable 'sc'
execfile(os.path.join(spark_home, 'python/pyspark/shell.py'))
{{< / highlight >}}

Now we are ready to launch a notebook using the PySpark profile

{{< highlight bash >}}
ipython notebook --profile=pyspark
{{< / highlight >}}

## Word Count Example

Make sure the ipython `pyspark` profile created a SparkContext by typing `sc`
within the notebook. You should see output similar to
`<pyspark.context.SparkContext at 0x1097e8e90>`.

Next, load a text file into a Spark RDD. For example, load the Spark README file:

{{< highlight python >}}
import os

spark_home = os.environ.get('SPARK_HOME', None)
text_file = sc.textFile(spark_home + "/README.md")
{{< / highlight >}}

The word count script below is quite simple. It takes the following steps:

1.  Split each line from the file into words
2. Map each word to a tuple containing the word and an initial count of 1
3. Sum up the count for each word

{{< highlight python >}}
word_counts = text_file \
    .flatMap(lambda line: line.split()) \
    .map(lambda word: (word, 1)) \
    .reduceByKey(lambda a, b: a + b)
{{< / highlight >}}

At this point, the word count has not been executed (lazy evaluation). To
actually count the words, execute the pipeline:

{{< highlight python >}}
word_counts.collect()
{{< / highlight >}}

Here's a portion of the output:

{{< highlight python >}}
[(u'all', 1),
 (u'when', 1),
 (u'"local"', 1),
 (u'including', 3),
 (u'computation', 1),
 (u'Spark](#building-spark).', 1),
 (u'using:', 1),
 (u'guidance', 3),
...
 (u'spark://', 1),
 (u'programs', 2),
 (u'documentation', 3),
 (u'It', 2),
 (u'graphs', 1),
 (u'./dev/run-tests', 1),
 (u'first', 1),
 (u'latest', 1)]
{{< / highlight >}}