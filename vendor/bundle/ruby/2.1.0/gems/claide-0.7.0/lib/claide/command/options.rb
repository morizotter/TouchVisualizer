# encoding: utf-8

module CLAide
  class Command
    # Provides support for the default options.
    #
    module Options
      # @return [Array<Array<String, String>>] The default options for a root
      #         command implemented by CLAide.
      #
      DEFAULT_ROOT_OPTIONS = [
        ['--completion-script', 'Print the auto-completion script'],
        ['--version',           'Show the version of the tool'],
      ]

      # @return [Array<Array<String, String>>] The default options implemented
      #         by CLAide.
      #
      DEFAULT_OPTIONS = [
        ['--verbose', 'Show more debugging information'],
        ['--no-ansi', 'Show output without ANSI codes'],
        ['--help',    'Show help banner of specified command'],
      ]

      # @return [Array<Array<String, String>>] The list of the default
      #         options for the given command.
      #
      # @param  [Class] command_class
      #         The command class for which the options are needed.
      #
      def self.default_options(command_class)
        if command_class.root_command?
          Options::DEFAULT_ROOT_OPTIONS + Options::DEFAULT_OPTIONS
        else
          Options::DEFAULT_OPTIONS
        end
      end

      # Handles root commands options if appropriate.
      #
      # @param  [Command] command
      #         The invoked command.
      #
      # @param  [ARGV] argv
      #         The parameters of the command.
      #
      # @return [Bool] Whether any root command option was handled.
      #
      def self.handle_root_option(command, argv)
        argv = ARGV.coherce(argv)
        return false unless command.class.root_command?
        if argv.flag?('version')
          print_version(command)
          return true
        elsif argv.flag?('completion-script')
          print_completion_template(command)
          return true
        end
        false
      end

      # Prints the version of the command optionally including plugins.
      #
      # @param  [Command] command
      #         The invoked command.
      #
      def self.print_version(command)
        puts command.class.version
        if command.verbose?
          PluginsHelper.specifications.each do |spec|
            puts "#{spec.name}: #{spec.version}"
          end
        end
      end

      # Prints an auto-completion script according to the user shell.
      #
      # @param  [Command] command
      #         The invoked command.#
      #
      def self.print_completion_template(command)
        puts ShellCompletionHelper.completion_template(command.class)
      end
    end
  end
end
