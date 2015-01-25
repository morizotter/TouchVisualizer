# encoding: utf-8

module CLAide
  class Command
    # Loads a command instances from arguments.
    #
    module Parser
      # @param  [Array, ARGV] argv
      #         A list of (remaining) parameters.
      #
      # @return [Command] An instance of the command class that was matched by
      #         going through the arguments in the parameters and drilling down
      #         command classes.
      #
      def self.parse(command, argv)
        argv = ARGV.coherce(argv)
        cmd = argv.arguments.first
        if cmd && subcommand = command.find_subcommand(cmd)
          argv.shift_argument
          parse(subcommand, argv)
        elsif command.abstract_command? && command.default_subcommand
          load_default_subcommand(command, argv)
        else
          command.new(argv)
        end
      end

      # @param  [Array, ARGV] argv
      #         A list of (remaining) parameters.#
      #
      # @return [Command] Returns the default subcommand initialized with the
      #         given arguments.
      #
      def self.load_default_subcommand(command, argv)
        default_subcommand = command.default_subcommand
        subcommand = command.find_subcommand(default_subcommand)
        unless subcommand
          raise 'Unable to find the default subcommand ' \
            "`#{default_subcommand}` for command `#{self}`."
        end
        result = parse(subcommand, argv)
        result.invoked_as_default = true
        result
      end
    end
  end
end
