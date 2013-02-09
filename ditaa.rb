require 'fileutils'
require 'digest/md5'

module Jekyll
  class DitaaBlock < Liquid::Block
    def initialize(tag_name, options, tokens)
      super

      ditaa_exists = system('which ditaa > /dev/null 2>&1')

      # There is always a blank line at the beginning, so we remove to get rid
      # of that undesired top padding in the ditaa output
      ditaa = @nodelist.to_s
      ditaa.gsub!('\n', "\n")
      ditaa.gsub!(/^$\n/, "")
      ditaa.gsub!(/^\[\"\n/, "")
      ditaa.gsub!(/\"\]$/, "")
      ditaa.gsub!(/\\\\/, "\\")

      hash = Digest::MD5.hexdigest(@nodelist.to_s + options)
      ditaa_home = 'images/ditaa/'
      FileUtils.mkdir_p(ditaa_home)
      @png_name = ditaa_home + 'ditaa-' + hash + '.png'

      if ditaa_exists
        if not File.exists?(@png_name)
          args = ' ' + options + ' -o'
          File.open('/tmp/ditaa-foo.txt', 'w') {|f| f.write(ditaa)}
          @png_exists = system('ditaa /tmp/ditaa-foo.txt ' + @png_name + args)
        end
      end
      @png_exists = File.exists?(@png_name)
    end

    def render(context)
      if @png_exists
        '<figure><img src="/' + @png_name + '" /></figure>'
      else
        '<code><pre>' + super + '</pre></code>'
      end
    end
  end
end

Liquid::Template.register_tag('ditaa', Jekyll::DitaaBlock)
