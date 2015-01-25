module Pod
  # Converts objects to their YAML representation.
  #
  # This class was created for the need having control on how the YAML is
  # representation is generated. In details it provides:
  #
  # - sorting for hashes in ruby 1.8.x
  # - ability to hint the sorting of the keys of a dictionary when converting
  #   it. In this case the keys are also separated by an additional new line
  #   feed for readability.
  #
  # @note This class misses important features necessary for a correct YAML
  #       serialization and thus it is safe to use only for the Lockfile.
  #       The missing features include:
  #       - Strings are never quoted even when ambiguous.
  #
  # @todo Remove any code required solely for Ruby 1.8.x.
  #
  class YAMLHelper
    class << self
      # Returns the YAML representation of the given object. If the given object
      # is a Hash, it accepts an optional hint for sorting the keys.
      #
      # @param  [String, Symbol, Array, Hash] object
      #         the object to convert
      #
      # @param  [Array] hash_keys_hint
      #         an array to use as a hint for sorting the keys of the object to
      #         convert if it is a hash.
      #
      # @return [String] the YAML representation of the given object.
      #
      def convert(value)
        result = process_according_to_class(value)
        result << "\n"
      end

      def convert_hash(value, hash_keys_hint, line_separator = "\n")
        result = process_hash(value, hash_keys_hint, line_separator)
        result << "\n"
      end

      # Loads a YAML string and provide more informative
      # error messages in special cases like merge conflict.
      #
      # @param [String] yaml_string
      #        The YAML String to be loaded
      #
      # @param [Pathname] file_path
      #        The (optional) file path to be used for read for the YAML file
      #
      # @return [Hash, Array] the Ruby YAML representaton
      #
      def load_string(yaml_string, file_path = nil)
        YAML.load(yaml_string)
        rescue
          if yaml_has_merge_error?(yaml_string)
            raise Informative, yaml_merge_conflict_msg(yaml_string, file_path)
          else
            raise Informative, yaml_parsing_error_msg(yaml_string, file_path)
          end
      end

      # Loads a YAML file and leans on the #load_string imp
      # to do error detection
      #
      # @param [Pathname] file_path
      #        The file path to be used for read for the YAML file
      #
      # @return [Hash, Array] the Ruby YAML representaton
      #
      def load_file(file_path)
        load_string(File.read(file_path), file_path)
      end

      #-----------------------------------------------------------------------#

      private

      # Implementation notes:
      #
      # - each of the methods returns a YAML partial without an ending new
      #   line.
      # - if a partial needs to be indented is responsibility of the method
      #   using it.
      #
      # ---

      # @!group Private Helpers

      # @return [String] the YAML representation of the given object.
      #
      def process_according_to_class(value, hash_keys_hint = nil)
        case value
        when String     then value
        when Symbol     then ":#{value}"
        when TrueClass  then 'true'
        when FalseClass then 'false'
        when Array      then process_array(value)
        when Hash       then process_hash(value, hash_keys_hint)
        else
          raise StandardError, 'Unsupported class for YAML conversion ' \
            "#{value.class}"
        end
      end

      # Converts an array to YAML after sorting it.
      #
      # @param  [Array] array
      #         the array to convert.
      #
      # @return [String] the YAML representation of the given object.
      #
      def process_array(array)
        result = []
        sorted_array(array).each do |array_value|
          result << process_according_to_class(array_value)
        end
        "- #{result * "\n- "}"
      end

      # Converts a hash to YAML after sorting its keys. Optionally accepts a
      # hint for sorting the keys.
      #
      # @note   If a hint for sorting the keys is provided the array is assumed
      #         to be the root object and the keys are separated by an
      #         additional new line feed for readability.
      #
      # @note   If the value of a given key is a String it displayed inline,
      #         otherwise it is displayed below and indented.
      #
      # @param  [Hash] hash
      #         the hash to convert.
      #
      # @return [String] the YAML representation of the given object.
      #
      def process_hash(hash, hash_keys_hint = nil, line_separator = "\n")
        keys = sorted_array_with_hint(hash.keys, hash_keys_hint)
        key_lines = []
        keys.each do |key|
          key_value = hash[key]
          processed = process_according_to_class(key_value)
          processed_key = process_according_to_class(key)
          case key_value
          when Array, Hash
            key_partial_yaml = processed.lines.map { |line| "  #{line}" } * ''
            key_lines << "#{processed_key}:\n#{key_partial_yaml}"
          else
            key_lines << "#{processed_key}: #{processed}"
          end
        end
        key_lines * line_separator
      end

      # Check for merge errors in a YAML string.
      #
      # @param [String] yaml_string
      #        A YAML string to evaluate
      #
      # @return If a merge error was detected or not.
      #
      def yaml_has_merge_error?(yaml_string)
        yaml_string.include?('<<<<<<< HEAD')
      end

      # Error message describing that a merge conflict was found
      # while parsing the YAML.
      #
      # @param [String] yaml
      #        Offending YAML
      #
      # @param [Pathname] path
      #        The (optional) offending path
      #
      # @return [String] The Error Message
      #
      def yaml_merge_conflict_msg(yaml, path = nil)
        err = 'ERROR: Parsing unable to continue due '
        err += "to merge conflicts present in:\n"
        err += "the file located at #{path}\n" if path
        err += "#{yaml}"
      end

      # Error message describing a general error took happened
      # while parsing the YAML.
      #
      # @param [String] yaml
      #        Offending YAML
      #
      # @param [Pathname] path
      #        The (optional) offending path
      #
      # @return [String] The Error Message
      #
      def yaml_parsing_error_msg(yaml, path = nil)
        err = 'ERROR: Parsing unable to continue due '
        err += "to parsing error:\n"
        err += "contained in the file located at #{path}\n" if path
        err += "#{yaml}"
      end

      #-----------------------------------------------------------------------#

      private

      # @!group Array Sorting

      # Sorts an array using another one as a sort hint. All the values of the
      # hint which appear in the array will be returned respecting the order in
      # the hint. If any other key is present in the original array they are
      # sorted using the {#sorted_array} method.
      #
      # @param  [Array] array
      #         The array which needs to be sorted.
      #
      # @param  [Array] sort_hint
      #         The array which should be used to sort the keys.
      #
      # @return [Array] The sorted Array.
      #
      def sorted_array_with_hint(array, sort_hint)
        if sort_hint
          hinted = sort_hint & array
          remaining = array - sort_hint
          hinted + sorted_array(remaining)
        else
          sorted_array(array)
        end
      end

      # Sorts an array according to the string representation of it values.
      # This method allows to sort arrays which contains strings or hashes.
      #
      # @note   If the value contained in the array is another Array or a Hash
      #         the first value of the collection is used for sorting, as this
      #         method is more useful, for arrays which contains a collection
      #         composed by one object.
      #
      # @todo   This stuff is here only because the Lockfile intermixes strings
      #         and hashes for the `PODS` key. The Lockfile should be more
      #         consistent.
      #
      # @return [Array] The sorted array.
      #
      def sorted_array(array)
        array.sort do |x, y|
          x_string = sorting_string(x)
          y_string = sorting_string(y)
          x_string <=> y_string
        end
      end

      # Returns the string representation of a value useful for sorting.
      #
      # @param  [String, Symbol, Array, Hash] value
      #         The value which needs to be sorted
      #
      # @return [String] A string useful to compare the value with other ones.
      #
      def sorting_string(value)
        return '' unless value
        case value
        when String then value.downcase
        when Symbol then sorting_string(value.to_s)
        when Array  then sorting_string(value.first)
        when Hash   then value.keys.map { |key| key.to_s.downcase }.sort.first
        end
      end
    end
  end
end
