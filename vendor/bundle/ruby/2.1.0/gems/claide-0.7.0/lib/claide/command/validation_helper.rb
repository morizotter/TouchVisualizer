# encoding: utf-8

module CLAide
  class Command
    module ValidationHelper
      # @return [String] Returns a message including a suggestion for the given
      #         unrecognized arguments.
      #
      # @param  [Array<String>] arguments
      #         The unrecognized arguments.
      #
      # @param  [Class] command_class
      #         The class of the command which encountered the unrecognized
      #         arguments.
      #
      def self.argument_suggestion(arguments, command_class)
        string = arguments.first
        type = ARGV::Parser.argument_type(string)
        list = suggestion_list(command_class, type)
        suggestion = ValidationHelper.suggestion(string, list)
        suggestion_message(suggestion, type, string)
      end

      # @return [Array<String>] The list of the valid arguments for a command
      #         according to the type of the argument.
      #
      # @param  [Command] command_class
      #         The class of the command for which the list of arguments is
      #         needed.
      #
      # @param  [Symbol] type
      #         The type of the argument.
      #
      def self.suggestion_list(command_class, type)
        case type
        when :option, :flag
          command_class.options.map(&:first)
        when :arg
          command_class.subcommands_for_command_lookup.map(&:command)
        end
      end

      # Returns a suggestion for a string from a list of possible elements.
      #
      # @return [String] string
      #         The string for which the suggestion is needed.
      #
      # @param  [Array<String>] list
      #         The list of the valid elements
      #
      def self.suggestion(string, list)
        sorted = list.sort_by do |element|
          Helper.levenshtein_distance(string, element)
        end
        sorted.first
      end

      # @return [String] Returns a message including a suggestion for the given
      #         suggestion.
      #
      # @param  [String, Nil] suggestion
      #         The suggestion.
      #
      # @param  [Symbol] type
      #         The type of the suggestion.
      #
      # @param  [String] string
      #         The unrecognized string.
      #
      def self.suggestion_message(suggestion, type, string)
        string_type = type == :arg ? 'command' : 'option'
        if suggestion
          pretty_suggestion = prettify_validation_suggestion(suggestion, type)
          "Unknown #{string_type}: `#{string}`\n" \
            "Did you mean: #{pretty_suggestion}"
        else
          "Unknown #{string_type}: `#{string}`"
        end
      end

      # Prettifies the given validation suggestion according to the type.
      #
      # @param  [String] suggestion
      #         The suggestion to prettify.
      #
      # @param  [Type] type
      #         The type of the suggestion: either `:command` or `:option`.
      #
      # @return [String] A handsome suggestion.
      #
      def self.prettify_validation_suggestion(suggestion, type)
        case type
        when :option, :flag
          suggestion = "#{suggestion}"
          suggestion.ansi.blue
        when :arg
          suggestion.ansi.green
        end
      end
    end
  end
end
