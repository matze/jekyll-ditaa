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

ditaa options can be passed through the tag:

    {% ditaa -S -E %}
    +---------------------------+
    | No separation and shadows |
    +---------------------------+
    {% endditaa %}

_Note_: If you haven't auto-regenerate enabled, the images might not get copied.
In this case you have to run a second Jekyll pass.

You may also use the option `--alt` followed by text in quotes to specify alt text for the generated image:

    {% ditaa -S --alt "Rounded box without Shadows" %}
    /-----------------------------\
    | Rounded box without shadows |
    \-----------------------------/
    {% endditaa %}

This option is not passed to ditaa.

## Configuration

You can use the `_config.yml` to specify the parameter `ditaa_output_directory` with the folder in which the rendered images will be placed:

    ... _config.yml file ...
    ...
    ditaa_output_directory: /resources/ditaa
    ...    
    ... _config.yml file ...

If not specified, the output directory will be `/images/ditaa` by default.

_Note_: The plugin keeps this output directory clean, deleting all obsolete files (orphaned by all posts). No problem in keeping other content in this folder, as long as the filenames are not like "`ditaa-foobar.png`".

The other parameter you can configure is `ditaa_debug_mode` which indicates if the plugin must show or not the output of the `ditaa` command line tool on building.

    ... _config.yml file ...
    ...
    ditaa_output_directory: /resources/ditaa
    ditaa_debug_mode: true
    ...    
    ... _config.yml file ...

If not specified, the debug mode is disabled by default, keeping the build process silent.
