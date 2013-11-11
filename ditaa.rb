require 'fileutils'
require 'digest/md5'

module Jekyll
  class DitaaBlock < Liquid::Block

    @@globals = {
      "output_dir" => "images/ditaa/"
    }

    def initialize(tag_name, options, tokens)
      super

      @ditaa_exists = system('which ditaa > /dev/null 2>&1')
      @ditaa_options = options
    end

    def render(context)
      source = super

      # There is always a blank line at the beginning, so we remove to get rid
      # of that undesired top padding in the ditaa output
      source.gsub!('\n', "\n")
      source.gsub!(/^$\n/, "")
      source.gsub!(/^\[\"\n/, "")
      source.gsub!(/\"\]$/, "")
      source.gsub!(/\\\\/, "\\")

      hash = Digest::MD5.hexdigest(source + @ditaa_options)

      # ditaa_home = 'images/ditaa/'
      FileUtils.mkdir_p(@@globals["output_dir"]) unless File.exists?(@@globals["output_dir"])

      @png_name = 'ditaa-' + hash + '.png' #ditaa_home + 'ditaa-' + hash + '.png'
      @png_path = @@globals["output_dir"] + @png_name

      if @ditaa_exists
        if not File.exists?(@png_path)
          args = ' ' + @ditaa_options + ' -o'
          File.open('/tmp/ditaa-foo.txt', 'w') {|f| f.write(source)}
          @png_exists = system('ditaa /tmp/ditaa-foo.txt ' + @png_path + args)
        end
      end

      if File.exists?(@png_path)
        site = context.registers[:site]
        site.static_files << Jekyll::StaticFile.new(site, site.source, @@globals["output_dir"], @png_name)

        '<figure><a href="/' + @png_path + '" title="' + @png_name + '" ><img src="/' + @png_path + '" title="' + @png_name + '" max-width="99%" /></a></figure>'
      else
        '<code><pre>' + source + '</pre></code>'
      end
    end
  end
end

Liquid::Template.register_tag('ditaa', Jekyll::DitaaBlock)
