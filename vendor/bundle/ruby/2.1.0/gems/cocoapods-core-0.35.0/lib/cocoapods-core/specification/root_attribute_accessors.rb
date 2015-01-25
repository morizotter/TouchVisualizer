module Pod
  class Specification
    module DSL
      # Provides the accessors methods for the root attributes. Root attributes
      # do not support multi-platform values and inheritance.
      #
      module RootAttributesAccessors
        # @return [String] The name of the specification *not* including the
        #         names of the parents, in case of ‘sub-specifications’.
        #
        def base_name
          attributes_hash['name']
        end

        # @return [String] The name of the specification including the names of
        #         the parents, in case of ‘sub-specifications’.
        #
        def name
          parent ? "#{parent.name}/#{base_name}" : base_name
        end

        # @return [Version] The version of the Pod.
        #
        # @todo   The version is memoized because the Resolvers sets the head
        #         state on it. This information should be stored in the
        #         specification instance and the lockfile should have a more
        #         robust handling of head versions (like a dedicated section).
        #
        def version
          if root?
            @version ||= Version.new(attributes_hash['version'])
          else
            @version ||= root.version
          end
        end

        # @return [Hash] a hash containing the authors as the keys and their
        #         email address as the values.
        #
        # @note   The value is coerced to a hash with a nil email if needed.
        #
        # @example Possible values
        #
        #   { 'Author' => 'email@host.com' }
        #   [ 'Author', { 'Author_2' => 'email@host.com' } ]
        #   [ 'Author', 'Author_2' ]
        #   'Author'
        #
        def authors
          authors = attributes_hash['authors']
          if authors.is_a?(Hash)
            authors
          elsif authors.is_a?(Array)
            result = {}
            authors.each do |name_or_hash|
              if name_or_hash.is_a?(String)
                result[name_or_hash] = nil
              else
                result.merge!(name_or_hash)
              end
            end
            result
          elsif authors.is_a?(String)
            { authors => nil }
          end
        end

        # @return [String] The social media URL.
        #
        def social_media_url
          attributes_hash['social_media_url']
        end

        # @return [String] The docset URL.
        #
        def docset_url
          attributes_hash['docset_url']
        end

        # @return [Hash] A hash containing the license information of the Pod.
        #
        # @note   The indentation is stripped from the license text.
        #
        def license
          license = attributes_hash['license']
          if license.is_a?(String)
            { :type => license }
          elsif license.is_a?(Hash)
            license = convert_keys_to_symbol(license)
            license[:text] = license[:text].strip_heredoc if license[:text]
            license
          else
            {}
          end
        end

        # @return [String] The URL of the homepage of the Pod.
        #
        def homepage
          attributes_hash['homepage']
        end

        # @return [Hash{Symbol=>String}] The location from where the library
        #         should be retrieved.
        #
        def source
          convert_keys_to_symbol(attributes_hash['source'])
        end

        # @return [String] A short description of the Pod.
        #
        def summary
          attributes_hash['summary']
        end

        # @return [String] A longer description of the Pod.
        #
        # @note   The indentation is stripped from the description.
        #
        def description
          description = attributes_hash['description']
          description.strip_heredoc.chomp if description
        end

        # @return [Array<String>] The list of the URL for the screenshots of
        #         the Pod.
        #
        # @note   The value is coerced to an array.
        #
        def screenshots
          value = attributes_hash['screenshots']
          [*value]
        end

        # @return [String, Nil] The documentation URL of the Pod if specified.
        #
        def documentation_url
          attributes_hash['documentation_url']
        end

        # @return [String, Nil] The prepare command of the Pod if specified.
        #
        def prepare_command
          command = attributes_hash['prepare_command']
          command.strip_heredoc.chomp if command
        end

        # @return [Bool] Whether the Pod has been deprecated.
        #
        def deprecated
          attributes_hash['deprecated']
        end

        # @return [String] The name of the Pod that this one has been
        #         deprecated in favor of.
        #
        def deprecated_in_favor_of
          attributes_hash['deprecated_in_favor_of']
        end

        # @return [Bool] Wether the pod is deprecated either in favor of some other
        #         pod or simply deprecated.
        #
        def deprecated?
          deprecated || !deprecated_in_favor_of.nil?
        end

        #---------------------------------------------------------------------#

        private

        # Converts the keys of the given hash to a string.
        #
        # @param  [Object] value
        #         the value that needs to be stripped from the Symbols.
        #
        # @return [Hash] the hash with the strings instead of the keys.
        #
        def convert_keys_to_symbol(value)
          return unless value
          result = {}
          value.each do |key, subvalue|
            subvalue = convert_keys_to_symbol(subvalue) if subvalue.is_a?(Hash)
            result[key.to_sym] = subvalue
          end
          result
        end

        #---------------------------------------------------------------------#
      end
    end
  end
end
