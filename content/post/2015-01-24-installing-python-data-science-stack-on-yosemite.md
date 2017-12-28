---
categories:
- Python
- scikit-learn
- SciPy
- Mac
- data-science
comments: true
date: 2015-01-24T00:00:00Z
title: Installing Python Data Science Stack on Yosemite
url: /2015/01/24/installing-python-data-science-stack-on-yosemite/
---

I was attempting to install the Python data-science stack within a fresh virtual
environment on my Mac with OS X 10.10.1 (Yosemite) but encountered various
frustrating errors. I logged my steps below that eventually yielded a successful
installation.

My primary goal was actually to install version 0.15.2 of
[scikit-learn](http://scikit-learn.org/) via `pip install -U scikit-learn`, but
I encountered some errors during the `scipy` installation. The process
successfully added `numpy 1.9.1` but failed on `scipy 0.15.1`. I then tried to
install that version of `scipy` individually but received the following error.

{{< highlight bash >}}
In file included from /usr/include/dispatch/dispatch.h:51:0,

  from /System/Library/Frameworks/IOKit.framework/Headers/IOKitLib.h:56,

  from /System/Library/Frameworks/CoreGraphics.framework/Headers/CGDisplayConfiguration.h:8,

  from /System/Library/Frameworks/CoreGraphics.framework/Headers/CoreGraphics.h:41,

  from /System/Library/Frameworks/Accelerate.framework/Frameworks/vImage.framework/Headers/vImage_Utilities.h:14,

  from /System/Library/Frameworks/Accelerate.framework/Frameworks/vImage.framework/Headers/vImage.h:200,

  from /System/Library/Frameworks/Accelerate.framework/Headers/Accelerate.h:24,

  from /Users/ramhiser/.virtualenvs/dossier/build/scipy/scipy/_build_utils/src/wrap_accelerate_c.c:1:

  /usr/include/dispatch/object.h:143:15: error: expected identifier or '(' before '^' token

   typedef void (^dispatch_block_t)(void);

                 ^

  /usr/include/dispatch/object.h:362:3: error: unknown type name 'dispatch_block_t'

   dispatch_block_t notification_block);
{{< / highlight >}}


After a few Google searches and a bit of trial and error, I followed
instructions in this [StackOverflow
post](http://stackoverflow.com/a/19850962/234233) to attempt a fix. As mentioned
below, I still received an error. Here were my initial steps:
  
1. Download and install XCode Command Line Tools from [Apple](https://developer.apple.com)

2. Installing `scipy` still failed at this point

3. `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer/`

4. `brew update`

5. `brew doctor`

6. `pip install -U scipy` still failed with same error message.

7. A few hints from a random [README
file](https://github.com/robotastic/homebrew-hackrf#troubleshooting) suggested
that I do the following:

{{< highlight bash >}}
export CC=clang
export CXX=clang++
export LDFLAGS='-L/opt/X11/lib'
export CFLAGS='-I/opt/X11/include -I/opt/X11/include/freetype2'
{{< / highlight >}}

Well, a new error message at this point.

{{< highlight bash >}}
  "_main", referenced from:

       implicit entry/start for main executable

  ld: symbol(s) not found for architecture x86_64

  collect2: error: ld returned 1 exit status

{{< / highlight >}}

Based on [a couple](http://stackoverflow.com/a/11798574/234233) [more
posts](http://forrestbao.blogspot.com/2010/04/compiling-numpy-and-scipy-on-centos.html),
I next unset `LDFLAGS` and `CFLAGS`. I attempted to install at this point and
again saw the latter error message.

At this point, I was quite frustrated. I closed my terminal
[iTerm2](http://iterm2.com) and reopened it. Forgoing the `LDFLAGS` and `CFLAGS`
options, I set:

{{< highlight bash >}}
export CC=clang
export CXX=clang++
{{< / highlight >}}

This time I was able to install both `scipy` and `scikit-learn` successfully.
