# encoding: utf-8

require 'claide/command/banner/prettifier'

module CLAide
  class Command
    # Creates the formatted banner to present as help of the provided command
    # class.
    #
    class Banner
      # @return [Class] The command for which the banner should be created.
      #
      attr_accessor :command

      # @param [Class] command @see command
      #
      def initialize(command)
        @command = command
      end

      # @return [String] The banner for the command.
      #
      def formatted_banner
        sections = [
          ['Usage',    formatted_usage_description],
          ['Commands', formatted_subcommand_summaries],
          ['Options',  formatted_options_description],
        ]
        banner = sections.map do |(title, body)|
          [prettify_title("#{title}:"), body] unless body.empty?
        end.compact.join("\n\n")
        banner
      end

      private

      # @!group Banner sections
      #-----------------------------------------------------------------------#

      # @return [String] The indentation of the text.
      #
      TEXT_INDENT = 6

      # @return [Fixnum] The maximum width of the text.
      #
      MAX_WIDTH = TEXT_INDENT + 80

      # @return [Fixnum] The minimum between a name and its description.
      #
      DESCRIPTION_SPACES = 3

      # @return [Fixnum] The minimum between a name and its description.
      #
      SUBCOMMAND_BULLET_SIZE = 2

      # @return [String] The section describing the usage of the command.
      #
      def formatted_usage_description
        message = command.description || command.summary || ''
        message = Helper.format_markdown(message, TEXT_INDENT, MAX_WIDTH)
        message = prettify_message(command, message)
        "#{signature}\n\n#{message}"
      end

      # @return [String] The signature of the command.
      #
      def signature
        full_command = command.full_command
        sub_command = signature_sub_command
        arguments = signature_arguments
        result = prettify_signature(full_command, sub_command, arguments)
        result.insert(0, '$ ')
        result.insert(0, ' ' * (TEXT_INDENT - '$ '.size))
      end

      # @return [String] The subcommand indicator of the signature.
      #
      def signature_sub_command
        return '[COMMAND]' if command.default_subcommand
        return 'COMMAND' if command.subcommands.any?
      end

      # @return [String] The arguments of the signature.
      #
      def signature_arguments
        command.arguments.map do |arg|
          names = arg.names.join('|')
          names.concat(' ' + Argument::ELLIPSIS) if arg.repeatable?
          arg.required? ? names : "[#{names}]"
        end.join(' ')
      end

      # @return [String] The section describing the subcommands of the command.
      #
      # @note   The plus sign emphasizes the that the subcommands are added to
      #         the command. The square brackets conveys a sense of direction
      #         and indicates the gravitational force towards the default
      #         command.
      #
      def formatted_subcommand_summaries
        subcommands = subcommands_for_banner
        subcommands.map do |subcommand|
          name = subcommand.command
          bullet = (name == command.default_subcommand) ? '>' : '+'
          name = "#{bullet} #{name}"
          pretty_name = prettify_subcommand(name)
          entry_description(pretty_name, subcommand.summary, name.size)
        end.join("\n")
      end

      # @return [String] The section describing the options of the command.
      #
      def formatted_options_description
        options = command.options
        options.map do |name, description|
          pretty_name = prettify_option_name(name)
          entry_description(pretty_name, description, name.size)
        end.join("\n")
      end

      # @return [String] The line describing a single entry (subcommand or
      #         option).
      #
      def entry_description(name, description, name_width)
        max_name_width = compute_max_name_width
        desc_start = max_name_width + (TEXT_INDENT - 2) + DESCRIPTION_SPACES
        result = ' ' * (TEXT_INDENT - 2)
        result << name
        result << ' ' * DESCRIPTION_SPACES
        result << ' ' * (max_name_width - name_width)
        result << Helper.wrap_with_indent(description, desc_start, MAX_WIDTH)
      end

      # @!group Overrides
      #-----------------------------------------------------------------------#

      # @return [String] A decorated title.
      #
      def prettify_title(title)
        Prettifier.prettify_title(title)
      end

      # @return [String] A decorated textual representation of the command.
      #
      def prettify_signature(command, subcommand, argument)
        Prettifier.prettify_signature(command, subcommand, argument)
      end

      # @return [String] A decorated command description.
      #
      def prettify_message(command, message)
        Prettifier.prettify_message(command, message)
      end

      # @return [String] A decorated textual representation of the subcommand
      #         name.
      #
      def prettify_subcommand(name)
        Prettifier.prettify_subcommand(name)
      end

      # @return [String] A decorated textual representation of the option name.
      #
      #
      def prettify_option_name(name)
        Prettifier.prettify_option_name(name)
      end

      # @!group Private helpers
      #-----------------------------------------------------------------------#

      # @return [Array<String>] The list of the subcommands to use in the
      #         banner.
      #
      def subcommands_for_banner
        command.subcommands_for_command_lookup.reject do |subcommand|
          subcommand.summary.nil?
        end.sort_by(&:command)
      end

      # @return [Fixnum] The width of the largest command name or of the
      #         largest option name. Used to align all the descriptions.
      #
      def compute_max_name_width
        widths = []
        widths << command.options.map { |option| option.first.size }
        widths << subcommands_for_banner.map do |cmd|
          cmd.command.size + SUBCOMMAND_BULLET_SIZE
        end.max
        widths.flatten.compact.max || 1
      end
    end
  end
end
