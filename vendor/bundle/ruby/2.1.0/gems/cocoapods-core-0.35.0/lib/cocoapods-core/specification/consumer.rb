require 'active_support/core_ext/string/strip.rb'

module Pod
  class Specification
    # Allows to conveniently access a Specification programmatically.
    #
    # It takes care of:
    #
    # - standardizing the attributes
    # - handling multi-platform values
    # - handle default values
    # - handle inherited values
    #
    # This class allows to store the values of the attributes in the
    # Specification as specified in the DSL. The benefits is reduced reliance
    # on meta programming to access the attributes and the possibility of
    # serializing a specification back exactly as defined in a file.
    #
    class Consumer
      # @return [Specification] The specification to consume.
      #
      attr_reader :spec

      # @return [Symbol] The name of the platform for which the specification
      #         needs to be consumed.
      #
      attr_reader :platform_name

      # @param  [Specification] spec @see spec
      # @param  [Symbol, Platform] platform
      #         The platform for which the specification needs to be consumed.
      #
      def initialize(spec, platform)
        @spec = spec
        @platform_name = platform.is_a?(Symbol) ? platform : platform.name

        unless spec.supported_on_platform?(platform)
          raise StandardError, "#{self} is not compatible with #{platform}."
        end
      end

      # Creates a method to access the contents of the attribute.
      #
      # @param  [Symbol] name
      #         the name of the attribute.
      #
      # @macro  [attach]
      #         @!method $1
      #
      def self.spec_attr_accessor(name)
        define_method(name) do
          value_for_attribute(name)
        end
      end

      #-----------------------------------------------------------------------#

      # @!group Regular attributes

      # @return [Bool] Whether the source files of the specification require to
      #         be compiled with ARC.
      #
      spec_attr_accessor :requires_arc
      alias_method :requires_arc?, :requires_arc

      # @return [Array<String>] A list of frameworks that the user’s target
      #         needs to link against
      #
      spec_attr_accessor :frameworks

      # @return [Array<String>] A list of frameworks that the user’s target
      #         needs to **weakly** link against
      #
      spec_attr_accessor :weak_frameworks

      # @return [Array<String>] A list of libraries that the user’s target
      #         needs to link against
      #
      spec_attr_accessor :libraries

      # @return [Array<String>] the list of compiler flags needed by the
      #         specification files.
      #
      spec_attr_accessor :compiler_flags

      # @return [Hash{String => String}] the xcconfig flags for the current
      #         specification.
      #
      spec_attr_accessor :xcconfig

      # @return [String] The contents of the prefix header.
      #
      spec_attr_accessor :prefix_header_contents

      # @return [String] The path of the prefix header file.
      #
      spec_attr_accessor :prefix_header_file

      # @return [String] the headers directory.
      #
      spec_attr_accessor :header_dir

      # @return [String] the directory from where to preserve the headers
      #         namespacing.
      #
      spec_attr_accessor :header_mappings_dir

      #-----------------------------------------------------------------------#

      # @!group File patterns

      # @return [Array<String>] the source files of the Pod.
      #
      spec_attr_accessor :source_files

      # @return [Array<String>] the public headers of the Pod.
      #
      spec_attr_accessor :public_header_files

      # @return [Array<String>] the private headers of the Pod.
      #
      spec_attr_accessor :private_header_files

      # @return [Array<String>] The paths of the framework bundles shipped with
      #         the Pod.
      #
      spec_attr_accessor :vendored_frameworks

      # @return [Array<String>] The paths of the libraries shipped with the
      #         Pod.
      #
      spec_attr_accessor :vendored_libraries

      # @return [Hash{String=>String}]]  hash where the keys are the names of
      #         the resource bundles and the values are their relative file
      #         patterns.
      #
      spec_attr_accessor :resource_bundles

      # @return [Array<String>] A hash where the key represents the
      #         paths of the resources to copy and the values the paths of
      #         the resources that should be copied.
      #
      spec_attr_accessor :resources

      # @return [Array<String>] The file patterns that the
      #         Pod should ignore.
      #
      spec_attr_accessor :exclude_files

      # @return [Array<String>] The paths that should be not
      #         cleaned.
      #
      spec_attr_accessor :preserve_paths

      #-----------------------------------------------------------------------#

      # @return [Array<Dependency>] the dependencies on other Pods.
      #
      def dependencies
        value = value_for_attribute(:dependencies)
        value.map do |name, requirements|
          Dependency.new(name, requirements)
        end
      end

      # Raw values need to be prepared as soon as they are read so they can be
      # safely merged to support multi platform attributes and inheritance
      #-----------------------------------------------------------------------#

      # Returns the value for the attribute with the given name for the
      # specification. It takes into account inheritance, multi-platform
      # attributes and default values.
      #
      # @param  [Symbol] attr_name
      #         The name of the attribute.
      #
      # @return [String, Array, Hash] the value for the attribute.
      #
      def value_for_attribute(attr_name)
        attr = Specification::DSL.attributes[attr_name]
        value = value_with_inheritance(spec, attr)
        value = attr.default(platform_name) if value.nil?
        value = attr.container.new if value.nil? && attr.container
        value
      end

      # Returns the value of a given attribute taking into account inheritance.
      #
      # @param  [Specification] the_spec
      #         the specification for which the value is needed.
      #
      # @param  [Specification::DSL::Attribute] attr
      #         the attribute for which that value is needed.
      #
      # @return [String, Array, Hash] the value for the attribute.
      #
      def value_with_inheritance(the_spec, attr)
        value = raw_value_for_attribute(the_spec, attr)
        if the_spec.root? || !attr.inherited?
          return value
        end

        parent_value = value_with_inheritance(the_spec.parent, attr)
        merge_values(attr, parent_value, value)
      end

      # Returns the value of a given attribute taking into account multi
      # platform values.
      #
      # @param  [Specification] the_spec
      #         the specification for which the value is needed.
      #
      # @param  [Specification::DSL::Attribute] attr
      #         the attribute for which that value is needed.
      #
      # @return [String, Array, Hash] The value for an attribute.
      #
      def raw_value_for_attribute(the_spec, attr)
        value = the_spec.attributes_hash[attr.name.to_s]
        value = prepare_value(attr, value)

        if attr.multi_platform?
          if platform_hash = the_spec.attributes_hash[platform_name.to_s]
            platform_value = platform_hash[attr.name.to_s]
            platform_value = prepare_value(attr, platform_value)
            value = merge_values(attr, value, platform_value)
          end
        end
        value
      end

      # Merges the values of an attribute, either because the attribute is
      # multi platform or because it is inherited.
      #
      # @param  [Specification::DSL::Attribute] attr
      #         the attribute for which that value is needed.
      #
      # @param  [String, Array, Hash] existing_value
      #         the current value (the value of the parent or non-multiplatform
      #         value).
      #
      # @param  [String, Array, Hash] new_value
      #         the value to append (the value of the spec or the
      #         multi-platform value).
      #
      # @return [String, Array, Hash] The merged value.
      #
      def merge_values(attr, existing_value, new_value)
        return existing_value if new_value.nil?
        return new_value if existing_value.nil?

        if attr.types.include?(TrueClass)
          new_value.nil? ? existing_value : new_value
        elsif attr.container == Array
          r = [*existing_value] + [*new_value]
          r.compact
        elsif attr.container == Hash
          existing_value.merge(new_value) do |_, old, new|
            if new.is_a?(Array) || old.is_a?(Array)
              r = [*old] + [*new]
              r.compact
            else
              old + ' ' + new
            end
          end
        else
          new_value
        end
      end

      # Wraps a value in an Array if needed and calls the prepare hook to
      # allow further customization of a value before storing it in the
      # instance variable.
      #
      # @note   Only array containers are wrapped. To automatically wrap
      #         values for attributes with hash containers a prepare hook
      #         should be used.
      #
      # @return [Object] the customized value of the original one if no
      #         prepare hook was defined.
      #
      def prepare_value(attr, value)
        if attr.container ==  Array
          value = [*value].compact
        end

        hook_name = prepare_hook_name(attr)
        if self.respond_to?(hook_name, true)
          value = send(hook_name, value)
        else
          value
        end
      end

      # @!group Preparing Values
      #-----------------------------------------------------------------------#

      # @return [String] the name of the prepare hook for this attribute.
      #
      # @note   The hook is called after the value has been wrapped in an
      #         array (if needed according to the container) but before
      #         validation.
      #
      def prepare_hook_name(attr)
        "_prepare_#{attr.name}"
      end

      # Converts the prefix header to a string if specified as an array.
      #
      # @param  [String, Array] value.
      #         The value of the attribute as specified by the user.
      #
      # @return [String] the prefix header.
      #
      def _prepare_prefix_header_contents(value)
        if value
          value = value.join("\n") if value.is_a?(Array)
          value.strip_heredoc.chomp
        end
      end

      # Ensures that the file patterns of the resource bundles are contained in
      # an array.
      #
      # @param  [String, Array, Hash] value.
      #         The value of the attribute as specified by the user.
      #
      # @return [Hash] the resources.
      #
      def _prepare_resource_bundles(value)
        result = {}
        if value
          value.each do |key, patterns|
            result[key] = [*patterns].compact
          end
        end
        result
      end

      #-----------------------------------------------------------------------#
    end
  end
end
