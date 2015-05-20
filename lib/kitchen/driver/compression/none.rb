module Kitchen
  module Driver
    module Compression
      class None < Base

        def compress(locals, &block)
          locals.each do |path|
            block.call(path)
          end
        end

        def supports
          []
        end

        def unpack_command(filename, dest = '.')

        end
      end
    end
  end
end
