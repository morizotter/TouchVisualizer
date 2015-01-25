module Pod
  class Specification
    module DSL
      # The PlatformProxy works in conjunction with Specification#_on_platform.
      # It provides support for a syntax like `spec.ios.source_files = 'file'`.
      #
      class PlatformProxy
        # @return [Specification] the specification for this platform proxy.
        #
        attr_accessor :spec

        # @return [Symbol] the platform described by this proxy. Can be either
        #         `:ios` or `:osx`.
        #
        attr_accessor :platform

        # @param  [Specification] spec @see spec
        # @param  [Symbol] platform @see platform
        #
        def initialize(spec, platform)
          @spec, @platform = spec, platform
        end

        # Defines a setter method for each attribute of the specification
        # class, that forwards the message to the {#specification} using the
        # {Specification#on_platform} method.
        #
        # @return [void]
        #
        def method_missing(meth, *args, &block)
          attribute = Specification::DSL.attributes.values.find do |attr|
            if attr.writer_name.to_sym == meth
              true
            elsif attr.writer_singular_form
              attr.writer_singular_form.to_sym == meth
            end
          end
          if attribute && attribute.multi_platform?
            spec.store_attribute(attribute.name, args.first, platform)
          else
            super
          end
        end

        # Allows to add dependency for the platform.
        #
        # @return [void]
        #
        def dependency(*args)
          name, *version_requirements = args
          platform_name = platform.to_s
          platform_hash = spec.attributes_hash[platform_name] || {}
          platform_hash['dependencies'] ||= {}
          platform_hash['dependencies'][name] = version_requirements
          spec.attributes_hash[platform_name] = platform_hash
        end

        # Allows to set the deployment target for the platform.
        #
        # @return [void]
        #
        def deployment_target=(value)
          platform_name = platform.to_s
          spec.attributes_hash['platforms'] ||= {}
          spec.attributes_hash['platforms'][platform_name] = value
        end
      end
    end
  end
end
