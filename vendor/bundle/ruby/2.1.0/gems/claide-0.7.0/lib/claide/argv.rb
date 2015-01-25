# encoding: utf-8

require 'claide/argv/parser'

module CLAide
  # This class is responsible for parsing the parameters specified by the user,
  # accessing individual parameters, and keep state by removing handled
  # parameters.
  #
  class ARGV
    # @return [ARGV] Coherces an object to the ARGV class if needed.
    #
    # @param  [Object] argv
    #         The object which should be converted to the ARGV class.
    #
    def self.coherce(argv)
      if argv.is_a?(ARGV)
        argv
      else
        ARGV.new(argv)
      end
    end

    # @param [Array<#to_s>] argv
    #        A list of parameters.
    #
    def initialize(argv)
      @entries = Parser.parse(argv)
    end

    # @return [Boolean] Whether or not there are any remaining unhandled
    #         parameters.
    #
    def empty?
      @entries.empty?
    end

    # @return [Array<String>] A list of the remaining unhandled parameters, in
    #         the same format a user specifies it in.
    #
    # @example
    #
    #   argv = CLAide::ARGV.new(['tea', '--no-milk', '--sweetner=honey'])
    #   argv.shift_argument # => 'tea'
    #   argv.remainder      # => ['--no-milk', '--sweetner=honey']
    #
    def remainder
      @entries.map do |type, (key, value)|
        case type
        when :arg
          key
        when :flag
          "--#{'no-' if value == false}#{key}"
        when :option
          "--#{key}=#{value}"
        end
      end
    end

    # @return [Hash] A hash that consists of the remaining flags and options
    #         and their values.
    #
    # @example
    #
    #   argv = CLAide::ARGV.new(['tea', '--no-milk', '--sweetner=honey'])
    #   argv.options # => { 'milk' => false, 'sweetner' => 'honey' }
    #
    def options
      options = {}
      @entries.each do |type, (key, value)|
        options[key] = value unless type == :arg
      end
      options
    end

    # @return [Array<String>] A list of the remaining arguments.
    #
    # @example
    #
    #   argv = CLAide::ARGV.new(['tea', 'white', '--no-milk', 'biscuit'])
    #   argv.shift_argument # => 'tea'
    #   argv.arguments      # => ['white', 'biscuit']
    #
    def arguments
      @entries.map { |type, value| value if type == :arg }.compact
    end

    # @return [Array<String>] A list of the remaining arguments.
    #
    # @note   This version also removes the arguments from the remaining
    #         parameters.
    #
    # @example
    #
    #   argv = CLAide::ARGV.new(['tea', 'white', '--no-milk', 'biscuit'])
    #   argv.arguments  # => ['tea', 'white', 'biscuit']
    #   argv.arguments! # => ['tea', 'white', 'biscuit']
    #   argv.arguments  # => []
    #
    def arguments!
      arguments = []
      while arg = shift_argument
        arguments << arg
      end
      arguments
    end

    # @return [String] The first argument in the remaining parameters.
    #
    # @note   This will remove the argument from the remaining parameters.
    #
    # @example
    #
    #   argv = CLAide::ARGV.new(['tea', 'white'])
    #   argv.shift_argument # => 'tea'
    #   argv.arguments      # => ['white']
    #
    def shift_argument
      if index = @entries.find_index { |type, _| type == :arg }
        entry = @entries[index]
        @entries.delete_at(index)
        entry.last
      end
    end

    # @return [Boolean, nil] Returns `true` if the flag by the specified `name`
    #         is among the remaining parameters and is not negated.
    #
    # @param  [String] name
    #         The name of the flag to look for among the remaining parameters.
    #
    # @param  [Boolean] default
    #         The value that is returned in case the flag is not among the
    #         remaining parameters.
    #
    # @note   This will remove the flag from the remaining parameters.
    #
    # @example
    #
    #   argv = CLAide::ARGV.new(['tea', '--no-milk', '--sweetner=honey'])
    #   argv.flag?('milk')       # => false
    #   argv.flag?('milk')       # => nil
    #   argv.flag?('milk', true) # => true
    #   argv.remainder           # => ['tea', '--sweetner=honey']
    #
    def flag?(name, default = nil)
      delete_entry(:flag, name, default)
    end

    # @return [String, nil] Returns the value of the option by the specified
    #         `name` is among the remaining parameters.
    #
    # @param  [String] name
    #         The name of the option to look for among the remaining
    #         parameters.
    #
    # @param  [String] default
    #         The value that is returned in case the option is not among the
    #         remaining parameters.
    #
    # @note   This will remove the option from the remaining parameters.
    #
    # @example
    #
    #   argv = CLAide::ARGV.new(['tea', '--no-milk', '--sweetner=honey'])
    #   argv.option('sweetner')          # => 'honey'
    #   argv.option('sweetner')          # => nil
    #   argv.option('sweetner', 'sugar') # => 'sugar'
    #   argv.remainder                   # => ['tea', '--no-milk']
    #
    def option(name, default = nil)
      delete_entry(:option, name, default)
    end

    private

    # @return [Array<Array<Symbol, String, Array>>] A list of tuples for each
    #         non consumed parameter, where the first entry is the `type` and
    #         the second entry the actual parsed parameter.
    #
    attr_reader :entries

    # @return [Bool, String, Nil] Removes an entry from the entries list and
    #         returns its value or the default value if the entry was not
    #         present.
    #
    # @param  [Symbol] requested_type
    #         The type of the entry.
    #
    # @param  [String] requested_key
    #         The key of the entry.
    #
    # @param  [Bool, String, Nil] default
    #         The value which should be returned if the entry is not present.
    #
    def delete_entry(requested_type, requested_key, default)
      result = nil
      @entries.delete_if do |type, (key, value)|
        if requested_key == key && requested_type == type
          result = value
          true
        end
      end
      result.nil? ? default : result
    end
  end
end
