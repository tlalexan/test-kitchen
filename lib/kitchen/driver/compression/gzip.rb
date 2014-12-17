require 'rubygems'
require 'rubygems/package'
require 'rubygems/package/tar_writer'

module Kitchen
  module Driver
    module Compression
      class Gzip < Tar
        def initialize(instance)
          super
          raise 'Gzip compressor is not supported on windows platform!' if RUBY_PLATFORM =~ /mswin|mingw|windows/
        end

        def compress(locals, &block)
          tar(locals) do |tarball|
            gzip(tarball) do |tgz|
              block.call(tgz)
            end
          end
        end

        def gzip(tar, &block)
          gz = Tempfile.new(%w(sandbox .tar.gz))
          gzip = Zlib::GzipWriter.new(gz)
          gzip.write tar.read
          gzip.close
          block.call(gz)
        ensure
          gz.unlink if gz
        end

        def unpack_command(filename, dest = '.')
          is_win? ? "chmod +x ./7za.exe && ./7za.exe x #{filename} -so | ./7za.exe x -aoa -si -ttar -o#{dest} > /dev/null" : "tar xfz #{filename} -C #{dest}"
        end
      end
    end
  end
end
