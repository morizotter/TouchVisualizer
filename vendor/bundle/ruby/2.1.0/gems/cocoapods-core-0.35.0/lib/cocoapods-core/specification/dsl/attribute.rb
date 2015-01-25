module Pod
  class Specification
    module DSL
      # A Specification attribute stores the information of an attribute. It
      # also provides logic to implement any required logic.
      #
      class Attribute
        require 'active_support/inflector/inflections'

        # @return [Symbol] the name of the attribute.
        #
        attr_reader :name

        # Returns a new attribute initialized with the given options.
        #
        # Attributes by default are:
        #
        # - inherited
        # - multi-platform
        #
        # @param    [Symbol] name @see name
        #
        # @param    [Hash{Symbol=>Object}] options
        #           The options for configuring the attribute (see Options
        #           group).
        #
        # @raise    If there are unrecognized options.
        #
        def initialize(name, options)
          @name = name

          @multi_platform = options.delete(:multi_platform) { true      }
          @inherited      = options.delete(:inherited)      { false     }
          @root_only      = options.delete(:root_only)      { false     }
          @required       = options.delete(:required)       { false     }
          @singularize    = options.delete(:singularize)    { false     }
          @file_patterns  = options.delete(:file_patterns)  { false     }
          @container      = options.delete(:container)      { nil       }
          @keys           = options.delete(:keys)           { nil       }
          @default_value  = options.delete(:default_value)  { nil       }
          @ios_default    = options.delete(:ios_default)    { nil       }
          @osx_default    = options.delete(:osx_default)    { nil       }
          @types          = options.delete(:types)          { [String] }

          unless options.empty?
            raise StandardError, "Unrecognized options: #{options} for #{self}"
          end
        end

        # @return [String] A string representation suitable for UI.
        #
        def to_s
          "Specification attribute `#{name}`"
        end

        # @return [String] A string representation suitable for debugging.
        #
        def inspect
          "<#{self.class} name=#{name} types=#{types} " \
            "multi_platform=#{multi_platform?}>"
        end

        #---------------------------------------------------------------------#

        # @!group Options

        # @return [Array<Class>] the list of the classes of the values
        #         supported by the attribute writer. If not specified defaults
        #         to #{String}.
        #
        attr_reader :types

        # @return [Array<Class>] the list of the classes of the values
        #         supported by the attribute, including the container.
        #
        def supported_types
          @supported_types ||= @types.dup.push(container).compact
        end

        # @return [Class] if defined it can be #{Array} or #{Hash}. It is used
        #         as default initialization value and to automatically wrap
        #         other values to arrays.
        #
        attr_reader :container

        # @return [Array, Hash] the list of the accepted keys for an attribute
        #         wrapped by a Hash.
        #
        # @note   A hash is accepted to group the keys associated only with
        #         certain keys (see the source attribute of a Spec).
        #
        attr_reader :keys

        # @return [Object] if the attribute follows configuration over
        #         convention it can specify a default value.
        #
        # @note   The default value is not automatically wrapped and should be
        #         specified within the container if any.
        #
        attr_reader :default_value

        # @return [Object] similar to #{default_value} but for iOS.
        #
        attr_reader :ios_default

        # @return [Object] similar to #{default_value} but for OS X.
        #
        attr_reader :osx_default

        # @return [Bool] whether the specification should be considered invalid
        #         if a value for the attribute is not specified.
        #
        def required?
          @required
        end

        # @return [Bool] whether the attribute should be specified only on the
        #         root specification.
        #
        def root_only?
          @root_only
        end

        # @return [Bool] whether the attribute is multi-platform and should
        #         work in conjunction with #{PlatformProxy}.
        #
        def multi_platform?
          @multi_platform
        end

        # @return [Bool] whether there should be a singular alias for the
        #         attribute writer.
        #
        def singularize?
          @singularize
        end

        # @return [Bool] whether the attribute describes file patterns.
        #
        # @note   This is mostly used by the linter.
        #
        def file_patterns?
          @file_patterns
        end

        # @return [Bool] defines whether the attribute reader should join the
        # values with the parent.
        #
        # @note   Attributes stored in wrappers are always inherited.
        #
        def inherited?
          !root_only? && @inherited
        end

        #---------------------------------------------------------------------#

        # @!group Accessors support

        # Returns the default value for the attribute.
        #
        # @param  [Symbol] platform
        #         the platform for which the default value is requested.
        #
        # @return [Object] The default value.
        #
        def default(platform = nil)
          if platform && multi_platform?
            platform_value = ios_default if platform == :ios
            platform_value = osx_default if platform == :osx
            platform_value || default_value
          else
            default_value
          end
        end

        # @return [String] the name of the setter method for the attribute.
        #
        def writer_name
          "#{name}="
        end

        # @return [String] an aliased attribute writer offered for convenience
        #         on the DSL.
        #
        def writer_singular_form
          "#{name.to_s.singularize}=" if singularize?
        end

        #---------------------------------------------------------------------#

        # @!group Values validation

        # Validates the value for an attribute. This validation should be
        # performed before the value is prepared or wrapped.
        #
        # @note   The this is called before preparing the value.
        #
        # @raise  If the type is not in the allowed list.
        #
        # @return [void]
        #
        def validate_type(value)
          return if value.nil?
          unless supported_types.any? { |klass| value.class == klass }
            raise StandardError, "Non acceptable type `#{value.class}` for "\
              "#{self}. Allowed values: `#{types.inspect}`"
          end
        end

        # Validates a value before storing.
        #
        # @raise If a root only attribute is set in a subspec.
        #
        # @raise If a unknown key is added to a hash.
        #
        # @return [void]
        #
        def validate_for_writing(spec, value)
          if root_only? && !spec.root?
            raise StandardError, "Can't set `#{name}` attribute for " \
              "subspecs (in `#{spec.name}`)."
          end

          if keys
            value.keys.each do |key|
              unless allowed_keys.include?(key)
                raise StandardError, "Unknown key `#{key}` for "\
                  "#{self}. Allowed keys: `#{allowed_keys.inspect}`"
              end
            end
          end

          # @return [Array] the flattened list of the allowed keys for the
          # hash of a given specification.
          #
          def allowed_keys
            if keys.is_a?(Hash)
              keys.keys.concat(keys.values.flatten.compact)
            else
              keys
            end
          end
        end
      end

      #-----------------------------------------------------------------------#
    end
  end
end
