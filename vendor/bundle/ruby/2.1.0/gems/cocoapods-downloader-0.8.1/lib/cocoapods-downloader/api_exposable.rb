module Pod
  module Downloader
    module APIExposable
      def expose_api(mod = nil, &block)
        if mod.nil?
          if block.nil?
            raise "Either a module or a block that's used to create a module is required."
          else
            mod = Module.new(&block)
          end
        elsif mod && block
          raise 'Only a module *or* is required, not both.'
        end
        include mod
      end

      alias_method :override_api, :expose_api
    end
  end
end
