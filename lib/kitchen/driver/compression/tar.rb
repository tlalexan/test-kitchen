require 'rubygems'
require 'rubygems/package'
require 'rubygems/package/tar_writer'

module Kitchen
  module Driver
    module Compression
      class Tar < Base

        def compress(locals, &block)
          tar(locals) do |tarball|
            block.call(tarball)
          end
        end

        def tar(locals, &block)
          tarball = Tempfile.new(%w(sandbox .tar))
          Gem::Package::TarWriter.new(tarball) do |archive|
            locals.each do |path|
              base_path = Pathname.new(path).parent
              files = File.file?(path) ? Array(path) : Dir.glob("#{path}/**/*")
              files.each do |file|
                mode = File.stat(file).mode
                relative_path = Pathname.new(file).relative_path_from(base_path)
                if File.directory?(file)
                  archive.mkdir(relative_path.to_s, mode)
                else
                  archive.add_file(relative_path.to_s, mode) do |tf|
                    File.open(file, 'rb') { |f| tf.write f.read }
                  end
                end
              end
            end
          end
          tarball.rewind
          block.call(tarball)
        ensure
          tarball.unlink if tarball
        end

        def unpack_command(filename, dest = '.')
          #chmod +x ./7za.exe
          is_win? ? "chmod +x ./7za.exe && ./7za.exe x #{filename} -o#{dest} -y > /dev/null" : "tar xf #{filename} -C #{dest}"
        end
      end
    end
  end
end
