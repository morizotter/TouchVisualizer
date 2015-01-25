# encoding: utf-8

require 'claide/command/shell_completion_helper/zsh_completion_generator'

module CLAide
  class Command
    module ShellCompletionHelper
      # Returns the completion template generated for the given command for the
      # given shell. If the shell is not provided it will be inferred by the
      # environment.
      #
      def self.completion_template(command, shell = nil)
        shell ||= ENV['SHELL'].split('/').last
        case shell
        when 'zsh'
          ZSHCompletionGenerator.generate(command)
        else
          raise Help, "Auto-completion generator for `#{shell}` shell not" \
            ' implemented.'
        end
      end

      # Indents the lines of the given string except the first one to the given
      # level. Uses two spaces per each level.
      #
      # @param  [String] string
      #         The string to indent.
      #
      # @param  [Fixnum] indentation
      #         The indentation amount.
      #
      # @return [String] An indented string.
      #
      def self.indent(string, indentation)
        string.gsub("\n", "\n#{' ' * indentation * 2}")
      end
    end
  end
end
