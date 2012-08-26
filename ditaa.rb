require 'fileutils'
require 'digest/md5'

module Jekyll
  class DitaaBlock < Liquid::Block
    def initialize(tag_name, markup, tokens)
      super

      @ditaa_exists = system('which ditaa > /dev/null 2>&1')
      @result = True

      if @ditaa_exists
        # No cheesy separations and shadows
        options = ' -E -S -o'

        # There is always a blank line at the beginning, so we remove to get rid
        # of that undesired top padding in the ditaa output
        ditaa = @nodelist.to_s.gsub(/^$\n/, '')

        hash = Digest::MD5.hexdigest(@nodelist.to_s)
        @png_name = 'images/ditaa/ditaa-' + hash + '.png'

        if not File.exists?(@png_name)
          File.open('/tmp/ditaa-foo.txt', 'w') {|f| f.write(ditaa)}
          @result = system('ditaa /tmp/ditaa-foo.txt ' + @png_name + options)
        end
      end
    end

    def render(context)
      if @ditaa_exists and @result
        '<figure><img src="/' + @png_name + '" /></figure>'
      else
        '<code><pre>' + super + '</pre></code>'
      end
    end
  end
end

Liquid::Template.register_tag('ditaa', Jekyll::DitaaBlock)
