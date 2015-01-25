# encoding: utf-8

module CLAide
  class Command
    # Handles plugin related logic logic for the `Command` class.
    #
    # Plugins are loaded the first time a command run and are identified by the
    # prefix specified in the command class. Plugins must adopt the following
    # conventions:
    #
    # - Support being loaded by a file located under the
    # `lib/#{plugin_prefix}_plugin` relative path.
    # - Be stored in a folder named after the plugin.
    #
    class PluginsHelper
      class << self
        # @return [Array<Pathname>] The list of the root directories of the
        #         loaded plugins.
        #
        attr_reader :plugin_paths
      end

      # @return [Array<String>] Loads plugins via RubyGems looking for files
      #         named after the `PLUGIN_PREFIX_plugin` and returns the paths of
      #         the gems loaded successfully. Plugins are required safely.
      #
      def self.load_plugins(plugin_prefix)
        return if plugin_paths
        paths = PluginsHelper.plugin_load_paths(plugin_prefix)
        plugin_paths = []
        paths.each do |path|
          if PluginsHelper.safe_require(path.to_s)
            plugin_paths << Pathname(path + './../../').cleanpath
          end
        end

        @plugin_paths = plugin_paths
      end

      # @return [Array<Specification>] The RubyGems specifications for the
      #         loaded plugins.
      #
      def self.specifications
        PluginsHelper.plugin_paths.map do |path|
          specification(path)
        end.compact
      end

      # @return [Array<Specification>] The RubyGems specifications for the
      #         plugin with the given root path.
      #
      # @param  [#to_s] path
      #         The root path of the plugin.
      #
      def self.specification(path)
        glob = Dir.glob("#{path}/*.gemspec")
        spec = Gem::Specification.load(glob.first) if glob.count == 1
        unless spec
          warn '[!] Unable to load a specification for the plugin ' \
            "`#{path}`".ansi.yellow
        end
        spec
      end

      # @return [Array<String>] The list of the plugins whose root path appears
      #         in the backtrace of an exception.
      #
      # @param  [Exception] exception
      #         The exception to analyze.
      #
      def self.plugins_involved_in_exception(exception)
        paths = plugin_paths.select do |plugin_path|
          exception.backtrace.any? { |line| line.include?(plugin_path.to_s) }
        end
        paths.map { |path| path.to_s.split('/').last }
      end

      # Returns the paths of the files to require to load the available
      # plugins.
      #
      # @return [Array] The found plugins load paths.
      #
      def self.plugin_load_paths(plugin_prefix)
        if plugin_prefix && !plugin_prefix.empty?
          pattern = "#{plugin_prefix}_plugin"
          if Gem.respond_to? :find_latest_files
            Gem.find_latest_files(pattern)
          else
            Gem.find_files(pattern)
          end
        else
          []
        end
      end

      # Loads the given path. If any exception occurs it is catched and an
      # informative message is printed.
      #
      # @param  [String] path
      #         The path to load
      #
      # rubocop:disable RescueException
      def self.safe_require(path)
        require path
        true
      rescue Exception => exception
        message = "\n---------------------------------------------"
        message << "\nError loading the plugin with path `#{path}`.\n"
        message << "\n#{exception.class} - #{exception.message}"
        message << "\n#{exception.backtrace.join("\n")}"
        message << "\n---------------------------------------------\n"
        puts message.ansi.yellow
        false
      end
      # rubocop:enable RescueException
    end
  end
end
