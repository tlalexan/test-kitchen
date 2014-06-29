module Kitchen
  module Driver
    module Compression
      class Base

        attr_accessor :instance
        def initialize(instance)
          @instance = instance
        end

        def is_win?
          @instance.platform.name.include?('win')
        end

        def supports
          return [] unless is_win?
          [Kitchen.source_root.join('support', '7za.exe')]
        end

        def unpack_command(filename)
          raise 'Must be defined lin child class!'
        end
      end
    end
  end
end
