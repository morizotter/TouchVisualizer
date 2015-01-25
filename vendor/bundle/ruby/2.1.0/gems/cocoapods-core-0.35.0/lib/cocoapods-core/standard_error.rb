module Pod
  # Namespaces all the errors raised by CocoaPods.
  #
  class StandardError < ::StandardError; end

  #-------------------------------------------------------------------------#

  # Wraps an exception raised by a DSL file in order to show to the user the
  # contents of the line that raised the exception.
  #
  class DSLError < Informative
    # @return [String] the description that should be presented to the user.
    #
    attr_reader :description

    # @return [String] the path of the dsl file that raised the exception.
    #
    attr_reader :dsl_path

    # @return [Exception] the backtrace of the exception raised by the
    #         evaluation of the dsl file.
    #
    attr_reader :backtrace

    # @param [Exception] backtrace @see backtrace
    # @param [String]    dsl_path  @see dsl_path
    #
    def initialize(description, dsl_path, backtrace)
      @description = description
      @dsl_path    = dsl_path
      @backtrace   = backtrace
    end

    # The message of the exception reports the content of podspec for the
    # line that generated the original exception.
    #
    # @example Output
    #
    #   Invalid podspec at `RestKit.podspec` - undefined method
    #   `exclude_header_search_paths=' for #<Pod::Specification for
    #   `RestKit/Network (0.9.3)`>
    #
    #       from spec-repos/master/RestKit/0.9.3/RestKit.podspec:36
    #       -------------------------------------------
    #           # because it would break: #import <CoreData/CoreData.h>
    #    >      ns.exclude_header_search_paths = 'Code/RestKit.h'
    #         end
    #       -------------------------------------------
    #
    # @return [String] the message of the exception.
    #
    def message
      unless @message
        m = "\n[!] "
        m << description
        m << ". Updating CocoaPods might fix the issue.\n"
        m = m.red if m.respond_to?(:red)

        return m unless backtrace && dsl_path && File.exist?(dsl_path)

        trace_line = backtrace.find { |l| l.include?(dsl_path.to_s) }
        return m unless trace_line
        line_numer = trace_line.split(':')[1].to_i - 1
        return m unless line_numer
        lines      = File.readlines(dsl_path.to_s)
        indent     = ' #  '
        indicator  = indent.dup.gsub('#', '>')
        first_line = (line_numer.zero?)
        last_line  = (line_numer == (lines.count - 1))

        m << "\n"
        m << "#{indent}from #{trace_line.gsub(/:in.*$/, '')}\n"
        m << "#{indent}-------------------------------------------\n"
        m << "#{indent}#{    lines[line_numer - 1] }" unless first_line
        m << "#{indicator}#{ lines[line_numer] }"
        m << "#{indent}#{    lines[line_numer + 1] }" unless last_line
        m << "\n" unless m.end_with?("\n")
        m << "#{indent}-------------------------------------------\n"
        m << ''
        @message = m
      end
      @message
    end
  end
end
