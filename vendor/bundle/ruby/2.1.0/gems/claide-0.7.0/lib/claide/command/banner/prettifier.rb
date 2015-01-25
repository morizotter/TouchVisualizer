# encoding: utf-8

module CLAide
  class Command
    class Banner
      # Implements the default logic to prettify the Banner.
      #
      module Prettifier
        # @return [String] A decorated title.
        #
        def self.prettify_title(title)
          title.ansi.underline
        end

        # @return [String] A decorated textual representation of the command.
        #
        def self.prettify_signature(command, subcommand, argument)
          components = [
            [command, :green],
            [subcommand, :green],
            [argument, :magenta],
          ]
          components.reduce('') do |memo, (string, ansi_key)|
            next memo if !string || string.empty?
            memo << ' ' << string.ansi.apply(ansi_key)
          end.lstrip
        end

        # @return [String] A decorated command description.
        #
        def self.prettify_message(command, message)
          message = message.dup
          command.arguments.each do |arg|
            arg.names.each do |name|
              message.gsub!("`#{name.gsub(/\.{3}$/, '')}`", '\0'.ansi.magenta)
            end
          end
          command.options.each do |(name, _description)|
            message.gsub!("`#{name}`", '\0'.ansi.blue)
          end
          message
        end

        # @return [String] A decorated textual representation of the subcommand
        #         name.
        #
        def self.prettify_subcommand(name)
          name.chomp.ansi.green
        end

        # @return [String] A decorated textual representation of the option
        #         name.
        #
        #
        def self.prettify_option_name(name)
          name.chomp.ansi.blue
        end
      end
    end
  end
end
