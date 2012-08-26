# Jekyll ditaa Plugin

[ditaa][] (DIagrams Through Ascii Art) is

> a small command-line utility written in Java, that can convert diagrams drawn
> using ascii art ('drawings' that contain characters that resemble lines like
> `| / -`), into proper bitmap graphics.

This plugin allows you to write ditaa markup within a ditaa block, generate the
image file and replace the markup with the image. If the image could not be
generated, the plugin falls back to a `<pre>` block with the ditaa markup.

[ditaa]: http://ditaa.sourceforge.net/


## Installation

Install ditaa with your favorite package manager, e.g. on Ubuntu

    sudo apt-get install ditaa

and place the `ditaa.rb` plugin in your sites `_plugins` directory.


## Usage

Once installed `ditaa` blocks with ditaa markup can be inserted:

    {% ditaa %}
    /----+  DAAP /-----+-----+ Audio  /--------+
    | PC |<------| RPi | MPD |------->| Stereo |
    +----+       +-----+-----+        +--------+
       |                 ^ ^
       |     ncmpcpp     | | mpdroid /---------+
       +--------=--------+ +----=----| Nexus S |
                                     +---------+
    {% endditaa %}

When re-generating the site, the generated image is inserted into the page:

![ditaa output](http://i.imgur.com/QWAfY.png)

Remember though, the images are written into `images/ditaa` and must therefore
exist. Moreover, if you haven't auto-regenerate enabled, the images might not
get copied. In this case you have to run a second Jekyll pass. 
