require 'seven_zip_ruby'

module Kitchen
  module Driver
    module Compression
      class SevenZip < Base
        def compress(paths)
          archive = Tempfile.new(%w(sandbox .7z))
          SevenZipRuby::SevenZipWriter.open(archive) do |szw|
            paths.each do |path|
              base_path = Pathname.new(path).parent
              files = File.file?(path) ? Array(path) : Dir.glob("#{path}/**/*")
              files.each do |file|
                relative_path = Pathname.new(file).relative_path_from(base_path)
                if File.directory?(file)
                  szw.mkdir(relative_path.to_s)
                else
                  szw.add_file(file, as: relative_path.to_s)
                end
              end
            end
          end
          yield(archive)
        ensure
          archive.unlink
        end

        def unpack_command(filename, dest = '.')
          is_win? ? "chmod +x ./7za.exe && ./7za.exe x #{filename} -o#{dest} -y > /dev/null"
            : "7z x #{filename} -o#{dest} -y > /dev/null"
        end
      end
    end
  end
end
