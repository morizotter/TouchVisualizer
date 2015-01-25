module CLAide
  class Command
    module ShellCompletionHelper
      # Generates a completion script for the Z shell.
      #
      module ZSHCompletionGenerator
        # @return [String] The completion script.
        #
        # @param  [Class] command
        #         The command to generate the script for.
        #
        # rubocop:disable MethodLength
        def self.generate(command)
          result = <<-DOC.strip_margin('|')
            |#compdef #{command.command}
            |# setopt XTRACE VERBOSE
            |# vim: ft=zsh sw=2 ts=2 et
            |
            |local -a _subcommands
            |local -a _options
            |
            |#{case_statement_fragment(command)}
          DOC

          post_process(result)
        end
        # rubocop:enable MethodLength

        # Returns a case statement for a given command with the given nesting
        # level.
        #
        # @param  [Class] command
        #         The command to generate the fragment for.
        #
        # @param  [Fixnum] nest_level
        #         The nesting level to detect the index of the words array.
        #
        # @return [String] the case statement fragment.
        #
        # @example
        #   case "$words[2]" in
        #     spec-file)
        #       [..snip..]
        #     ;;
        #     *) # bin
        #       _subcommands=(
        #         "spec-file:"
        #       )
        #       _describe -t commands "bin subcommands" _subcommands
        #       _options=(
        #         "--completion-script:Print the auto-completion script"
        #         "--help:Show help banner of specified command"
        #         "--verbose:Show more debugging information"
        #         "--version:Show the version of the tool"
        #       )
        #       _describe -t options "bin options" _options
        #     ;;
        #   esac
        #
        # rubocop:disable MethodLength
        def self.case_statement_fragment(command, nest_level = 0)
          entries = case_statement_entries_fragment(command, nest_level + 1)
          subcommands = subcommands_fragment(command)
          options = options_fragment(command)

          result = <<-DOC.strip_margin('|')
            |case "$words[#{nest_level + 2}]" in
            |  #{ShellCompletionHelper.indent(entries, 1)}
            |  *) # #{command.full_command}
            |    #{ShellCompletionHelper.indent(subcommands, 2)}
            |    #{ShellCompletionHelper.indent(options, 2)}
            |  ;;
            |esac
          DOC
          result.gsub(/\n *\n/, "\n").chomp
        end
        # rubocop:enable MethodLength

        # Returns a case statement for a given command with the given nesting
        # level.
        #
        # @param  [Class] command
        #         The command to generate the fragment for.
        #
        # @param  [Fixnum] nest_level
        #         The nesting level to detect the index of the words array.
        #
        # @return [String] the case statement fragment.
        #
        # @example
        #   repo)
        #     case "$words[5]" in
        #       *) # bin spec-file lint
        #         _options=(
        #           "--help:Show help banner of specified command"
        #           "--only-errors:Skip warnings"
        #           "--verbose:Show more debugging information"
        #         )
        #         _describe -t options "bin spec-file lint options" _options
        #       ;;
        #     esac
        #   ;;
        #
        def self.case_statement_entries_fragment(command, nest_level)
          subcommands = command.subcommands_for_command_lookup
          subcommands.sort_by(&:name).map do |subcommand|
            subcase = case_statement_fragment(subcommand, nest_level)
            <<-DOC.strip_margin('|')
              |#{subcommand.command})
              |  #{ShellCompletionHelper.indent(subcase, 1)}
              |;;
            DOC
          end.join("\n")
        end

        # Returns the fragment of the subcommands array.
        #
        # @param  [Class] command
        #         The command to generate the fragment for.
        #
        # @return [String] The fragment.
        #
        def self.subcommands_fragment(command)
          subcommands = command.subcommands_for_command_lookup
          list = subcommands.sort_by(&:name).map do |subcommand|
            "\"#{subcommand.command}:#{subcommand.summary}\""
          end
          describe_fragment(command, 'subcommands', 'commands', list)
        end

        # Returns the fragment of the options array.
        #
        # @param  [Class] command
        #         The command to generate the fragment for.
        #
        # @return [String] The fragment.
        #
        def self.options_fragment(command)
          list = command.options.sort_by(&:first).map do |option|
            "\"#{option[0]}:#{option[1]}\""
          end
          describe_fragment(command, 'options', 'options', list)
        end

        # Returns the fragment for a list of completions and the ZSH
        # `_describe` function.
        #
        # @param  [Class] command
        #         The command to generate the fragment for.
        #
        # @param  [String] name
        #         The name of the list.
        #
        # @param  [Class] tag
        #         The ZSH tag to use (e.g. command or option).
        #
        # @param  [Array<String>] list
        #         The list of the entries.
        #
        # @return [String] The fragment.
        #
        def self.describe_fragment(command, name, tag, list)
          if list && !list.empty?
            <<-DOC.strip_margin('|')
              |_#{name}=(
              |  #{ShellCompletionHelper.indent(list.join("\n"), 1)}
              |)
              |_describe -t #{tag} "#{command.full_command} #{name}" _#{name}
            DOC
          else
            ''
          end
        end

        # Post processes a script to remove any artifact and escape any needed
        # character.
        #
        # @param  [String] string
        #         The string to post process.
        #
        # @return [String] The post processed script.
        #
        def self.post_process(string)
          string.gsub!(/\n *\n/, "\n\n")
          string.gsub!(/`/, '\\\`')
          string
        end
      end
    end
  end
end
