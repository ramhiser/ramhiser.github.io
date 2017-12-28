---
categories:
- Serverless
- AWS
- Python
- Computer Vision
comments: true
date: 2016-09-05T00:00:00Z
title: Serverless API around Google Cloud Vision with the Serverless Framework
url: /2016/09/05/serverless-api-around-google-cloud-vision-with-the-serverless-framework/
---

The [Serverless Framework](http://serverless.com/) hit v1.0 (beta) recently
after about a year of development. The framework has matured quickly to help
devs build scalable applications without having to maintain servers. It aims to
ease deployment via:

* Easy-to-use CLI tool
* Customizable deployment via config files
* Simplifies/automates the annoying parts
* Extensible via plugins

Although the Serverless Framework
[does not yet support Google Cloud Functions](https://github.com/serverless/serverless/issues/1510),
it is designed to support a variety of event-driven compute services, including
[AWS Lambda](https://aws.amazon.com/lambda/) and (eventually)
[Google Cloud Functions](https://cloud.google.com/functions/). If you're not
familiar with serverless computing, I recommend you start with
[Martin Fowler's overview](http://martinfowler.com/bliki/Serverless.html).

So why would I use a framework rather than glue a bunch of bash scripts
together? Simple. Serverless Framework takes care of **AWS IAM Roles**, making
deployment much less annoying. Also, as we'll see below, Serverless makes it
easy to include Python dependencies along with your Lambda function.

I've been eager to build a
[serverless app](https://github.com/ramhiser/serverless-cloud-vision). Combining
that goal with wanting to make
[Google Cloud Vision](https://cloud.google.com/vision/) a bit more convenient to
work with, I built a serverless API wrapper around
[Google Cloud Vision](https://cloud.google.com/vision/) using
[AWS API Gateway](https://aws.amazon.com/api-gateway/) and
[AWS Lambda](https://aws.amazon.com/lambda/). I expected there to be some
craziness when combining services from both Amazon and Google, but the
Serverless Framework ensured there was none. I focused on AWS Lambda in this
project but may play with Google's offering after it matures a bit.

# What Does the App Do?

For the impatient, check out [the GitHub repository](https://github.com/ramhiser/serverless-cloud-vision).

Briefly, I created a microservice via API Gateway that accepts an image URL and
triggers a Lambda function, which ingests the image from a URL and sends the
image to [Google Cloud Vision](https://cloud.google.com/vision/) for standard
image recognition tasks (e.g., facial detection, OCR, etc.). A JSON response is
returned, from which I was able to produce a new image with bounding boxes
around the faces detected (my son and me).

![highlighted faces](https://raw.githubusercontent.com/ramhiser/serverless-cloud-vision/master/examples/images/highlighted-faces.jpg)

Beyond facial detection, Google Cloud Vision [supports the following image
recognition tasks](https://cloud.google.com/vision/docs/requests-and-responses):

* `LABEL_DETECTION`
* `TEXT_DETECTION`
* `SAFE_SEARCH_DETECTION`
* `FACE_DETECTION`
* `LANDMARK_DETECTION`
* `LOGO_DETECTION`
* `IMAGE_PROPERTIES`

## How to Get Started?

Above, we described what the project does. Now, let's go through how to set up
the project and deploy it in your own cloud environment.

## Google Cloud Vision API

First, let's go through a few details to set up the
[Google Cloud Vision API](https://cloud.google.com/vision/). In order to access
the Cloud Vision API, you will need a Google Cloud Platform
account. Fortunately, Google provides a
[free 60-day trial with $300 credit](https://cloud.google.com/free-trial/).

Next, you will need to create Google Application Credentials. You will need to
create a **Service Account Key** by following the instructions given
[here](https://cloud.google.com/vision/docs/common/auth#set_up_a_service_account).
After creating a **Service Account Key**, I downloaded a JSON file with my
application credentials into
[my app](https://github.com/ramhiser/serverless-cloud-vision) and renamed the
file as `cloudvision/google-application-credentials.json`.

That's it.

## AWS

As I said above, we are mixing cloud providers, which might be weaksauce to some
of you. Regardless, AWS doesn't have a spiffy API for image recognition, but
their cloud offerings are mature.

You'll first need an [AWS account](https://aws.amazon.com/). Quick disclaimer:
it's not free, but for our purposes,
[AWS Lambda is pretty cheap](https://aws.amazon.com/lambda/pricing/).

Next, you need to create a default AWS profile on your local box. To do this,
[install the `aws-cli`](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
and then run the following at the command line:

{{< highlight bash >}}
aws configure
{{< / highlight >}}

For more details, Serverless provides an
[AWS overview](https://github.com/serverless/serverless/blob/master/docs/02-providers/aws/01-setup.md) along with a [video walkthrough on YouTube](https://www.youtube.com/watch?v=weOsx5rLWX0).

That's it.

## Serverless Framework to Deploy the App on AWS

After your AWS account is ready to go, make sure you have
[Node.js 4.0+](https://nodejs.org) installed. Then, install the
[Serverless Framework](https://github.com/serverless/serverless).

{{< highlight bash >}}
npm install serverless -g
{{< / highlight >}}

The above command makes the `serverless` command available at the CLI along with
two shortcuts: `sls` and `slss`. If you simply type `serverless`, the Serverless
Framework provides some intuitive docs.

If you haven't already done so, `git clone` the app with:

{{< highlight bash >}}
git clone git@github.com:ramhiser/serverless-cloud-vision.git
cd serverless-cloud-vision
{{< / highlight >}}

Here's one of the best parts about Serverless Framework. We can install any
Python dependencies we need in our app to a local folder, and those dependencies
will be deployed along with our app. To see this, install the Python
dependencies in our `requirements.txt` to the `cloudvision/vendored` folder:

{{< highlight bash >}}
pip install -t cloudvision/vendored/ -r requirements.txt
{{< / highlight >}}

**NOTE**: Homebrew + Mac OS users who encounter the `DistutilsOptionError` error
should see [this SO post](http://stackoverflow.com/a/24357384/234233) for a fix.

After installing the Python requirements to the `vendored` folder, we are ready
to deploy our app to AWS. Type the following at the commandline to deploy the
wrapper API:

{{< highlight bash >}}
serverless deploy
{{< / highlight >}}

This command does the following:

* Create IAM roles on AWS for Lambda and API Gateway (only done once)
* Zips Python code and uploads to S3
* Creates AWS Lambda function
* Creates API Gateway endpoint that triggers AWS Lambda function

Serverless takes a bit longer to run this command the first time because it has
to create IAM roles. However, after you have deployed your app once and then
made a change to the code, this command executes much quicker.

After the Serverless command returns successfully, it'll provide a few useful
pieces of information, including the API endpoint you'll need to use your
microservice:

{{< highlight yaml >}}
Service Information
service: cloudvision
stage: dev
region: us-east-1
endpoints:
  POST - https://some-api-gateway.execute-api.us-east-1.amazonaws.com/dev/detect_image
functions:
  lambda-cloudvision: arn:aws:lambda:us-east-1:1234567890:function:lambda-cloudvision
{{< / highlight >}}

The endpoint
`https://some-api-gateway.execute-api.us-east-1.amazonaws.com/dev/detect_image`
provided by API Gateway is automatically generated by AWS and will differ in
your implementation.

Now we have a simple API to apply basic image recognition tasks. For instance,
the following `curl` command sends an image URL of my son and me to the API.

{{< highlight bash >}}
curl -H "Content-Type: application/json" -X POST \
-d '{"image_url": "https://raw.githubusercontent.com/ramhiser/serverless-cloud-vision/master/examples/images/ramhiser-and-son.jpg"}' \
https://some-api-gateway.execute-api.us-east-1.amazonaws.com/dev/detect_image
{{< / highlight >}}

The response JSON includes a variety of metadata to describe the image and the faces detected:

{{< highlight javascript >}}
{
  "responses": [
    {
      "faceAnnotations": [
        {
          "angerLikelihood": "VERY_UNLIKELY",
          "blurredLikelihood": "VERY_UNLIKELY",
          "boundingPoly": {
            "vertices": [
              {
                "x": 512,
                "y": 249
              },
              {
                "x": 637,
                "y": 249
              },
              {
                "x": 637,
                "y": 395
              },
              {
                "x": 512,
                "y": 395
              }
            ]
          },
          "detectionConfidence": 0.98645973,
          ...
{{< / highlight >}}

This JSON response was used to draw the bounding boxes in the image above. For
implementation details, [see the `examples` folder](https://github.com/ramhiser/serverless-cloud-vision/tree/master/examples) within my repo.

By default, facial recognition is performed as we can see from the
`lambda_handler` function in `cloudvision/handler.py`:

{{< highlight python >}}
def lambda_handler(event, context):
    """AWS Lambda Handler for API Gateway input"""
    post_args = event.get("body", {})
    image_url = post_args["image_url"]
    detect_type = post_args.get("detect_type", "FACE_DETECTION")
    max_results = post_args.get("max_results", 4)

    logging.debug("Detecting image from URL: %s" % image_url)
    logging.debug("Image detection type: %s" % detect_type)
    logging.debug("Maximum number of results: %s" % max_results)

    json_return = detect_image(image_url,
                               detect_type,
                               max_results)
    return json_return
{{< / highlight >}}

The API calls the `detect_image` function with the image URL and
two optional arguments: `max_results` and `detect_type`. The `max_results`
argument specifies how many entities (e.g., faces) we wish to find, whereas the
`detect_type` argument indicates the image recognition task we wish to
perform. As mentioned above, Google Cloud Vision [supports multipe image
recognition tasks](https://cloud.google.com/vision/docs/requests-and-responses)
beyond facial detection. For instance, let's apply OCR to [my employer,
uStudio's, logo](https://ustudio.com/):

[![uStudio](https://raw.githubusercontent.com/ramhiser/serverless-cloud-vision/master/examples/images/ustudio.jpg)](https://ustudio.com/)

To do this, let's run the following `curl` command:

{{< highlight bash >}}
curl -H "Content-Type: application/json" -X POST \
-d '{"image_url": "https://raw.githubusercontent.com/ramhiser/serverless-cloud-vision/master/examples/images/ustudio.jpg", "detect_type": "TEXT_DETECTION"}' \
https://some-api-gateway.execute-api.us-east-1.amazonaws.com/dev/detect_image
{{< / highlight >}}

The response JSON has a similar form as our facial detection example, but this
time a bounding box around the logo is given with a `description: Ustudio`.

{{< highlight javascript >}}
{
  "responses": [
    {
      "textAnnotations": [
        {
          "locale": "et",
          "description": "Ustudio\n",
          "boundingPoly": {
            "vertices": [
              {
                "y": 91,
                "x": 176
              },
              {
                "y": 91,
                "x": 1322
              },
              {
                "y": 348,
                "x": 1322
              },
              {
                "y": 348,
                "x": 176
              }
            ]
          }
        },
        ...
{{< / highlight >}}

Nice! OCR made simple.

# Gotchas

The Serverless Framework simplified our microservice deployment via API Gateway
and Lambda. There are some gotchas though that you should be aware of.

First, neither AWS nor Serverless Framework are fully aware of your folder
structure, so you'll need to ensure Python is aware of where your dependencies
are located, as in this snippet from `cloudvision/lib/__init__.py`:

{{< highlight python >}}
import os
import sys

here = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(here, "../vendored"))
{{< / highlight >}}

Second, YAML indentation. Grrrrr. My API Gateway endpoints were not working for
some time (no errors!) because I was missing two spaces in my YAML file. Two
spaces!!! It was only after [someone else](https://github.com/serverless/serverless/issues/1810) encountered the same issue did I see
[what to do](https://github.com/ramhiser/serverless-cloud-vision/commit/0f0bba03f1d739f005aadafcc1c3b6e0fc17f922):

![Fixing YAML Indentation](https://raw.githubusercontent.com/ramhiser/serverless-cloud-vision/master/yaml-indentation-grrrr.png)

That's it! Besides the couple of gotchas, the Serverless Framework makes it easy
to deploy simple microservices.
