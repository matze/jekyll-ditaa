require 'fileutils'
require 'tempfile'
require 'digest/md5'

module Jekyll
  module Tags
    class DitaaBlock < Liquid::Block

      @@debug = false

      @@output_dir = "/images/ditaa"
      def self.output_dir
        @@output_dir
      end

      @@generated_files = [ ]
      def self.generated_files
        @@generated_files
      end
      
      @@baseurl = ""
      def self.baseurl
        @@baseurl
      end

      def initialize(tag_name, options, tokens)
        super
        @ditaa_exists = system('which ditaa > /dev/null 2>&1')
        @ditaa_options = options
      end

      def self.init_globals(site)
        # Get the output_dir from the config or keep the hardcoded one if not defined.
        if !defined?(@@first_time)
          @@first_time = true
          if ! site.config["ditaa_debug_mode"].nil?
            @@debug = (site.config["ditaa_debug_mode"].to_s == 'true')
          end
          if ! site.config["ditaa_output_directory"].nil?
            @@output_dir = site.config["ditaa_output_directory"]
          end
          if ! site.config["baseurl"].nil?
            @@baseurl = site.config["baseurl"]
          end
          # Verify and prepare the output folder (src) if it doesn't exist
          src_dir = File.join(site.source, @@output_dir)
          FileUtils.mkdir_p(src_dir) unless File.exists?(src_dir)
        end
      end

      def render(context)
        source = super
        site = context.registers[:site]
        # First time read of the configuration parameters
        Tags::DitaaBlock::init_globals(site)

        # There is always a blank line at the beginning, so we remove to get rid
        # of that undesired top padding in the ditaa output
        source.gsub!('\n', "\n")
        source.gsub!(/^$\n/, "")
        source.gsub!(/^\[\"\n/, "")
        source.gsub!(/\"\]$/, "")
        source.gsub!(/\\\\/, "\\")

        # compose a hash to address the file
        hash = Digest::MD5.hexdigest(source + @ditaa_options)

        # obtain the path of the file once generated
        png_name = 'ditaa-' + hash + '.png'
        web_path = File.join(@@baseurl, @@output_dir, png_name)
        png_path = File.join(site.source, @@output_dir, png_name)

        if @ditaa_exists
          # only render the new blocks
          if not File.exists?(png_path)
            args = ' ' + @ditaa_options + ' -o '
            if ! @@debug 
              args += ' >/dev/null '  # silent execution
            end
            f = Tempfile.new('ditaa')
            f.write(source)
            f.close
            @png_exists = system('ditaa ' + f.path + ' ' + png_path + args)
            f.unlink  # cleanup of temporary file
          end
        end

        # only if the rendering process has taken effect and was successful
        if File.exists?(png_path)
          st = Jekyll::StaticFile.new(site, site.source, @@output_dir, png_name)
          @@generated_files << st
          site.static_files << st
          return '<img src="' + web_path + '"/>'
        else
          # return the code if failure
          return '<pre><code>' + source + '</code></pre>'
        end
      end
    end
  end
  
  # clean up process in Site::write
  class Site
    # override variable (to keep previous version)
    alias :super_ditaa_write :write

    def write
      super_ditaa_write                     # calling super

      output_dir = Tags::DitaaBlock::output_dir

      # create the destination folder for the rendered images (dest)
      dest_folder = File.join(dest, output_dir)
      FileUtils.mkdir_p(dest_folder) unless File.exists?(dest_folder)

      # get a list of all the generated files
      src_files = []
      Tags::DitaaBlock::generated_files.each do |f|
        src_files << f.path
      end

      # get a list of all the already present files
      pre_files = Dir.glob(File.join(source, output_dir, 'ditaa-*.png'))

      # clean all previously rendered files not rendered in the actual build
      to_remove = pre_files - src_files
      to_remove.each do |f|
        File.unlink f if File.exists?(f)
        d, fn = File.split(f)
        df = File.join(dest, output_dir, fn)
        File.unlink df if File.exists?(df)
      end
    end
  end

end

# Register the tag
Liquid::Template.register_tag('ditaa', Jekyll::Tags::DitaaBlock)