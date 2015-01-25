module Pod
  class Podfile
    # The TargetDefinition stores the information of a CocoaPods static
    # library. The target definition can be linked with one or more targets of
    # the user project.
    #
    # Target definitions can be nested and by default inherit the dependencies
    # of the parent.
    #
    class TargetDefinition
      # @return [TargetDefinition, Podfile] the parent target definition or the
      #         Podfile if the receiver is root.
      #
      attr_reader :parent

      # @param  [String, Symbol]
      #         name @see name
      #
      # @param  [TargetDefinition] parent
      #         @see parent
      #
      # @option options [Bool] :exclusive
      #         @see exclusive?
      #
      def initialize(name, parent, internal_hash = nil)
        @internal_hash = internal_hash || {}
        @parent = parent
        @children = []

        unless internal_hash
          self.name = name
        end
        if parent.is_a?(TargetDefinition)
          parent.children << self
        end
      end

      # @return [Array<TargetDefinition>] the children target definitions.
      #
      attr_reader :children

      # @return [Array<TargetDefinition>] the targets definition descending
      #         from this one.
      #
      def recursive_children
        (children + children.map(&:recursive_children)).flatten
      end

      # @return [Bool] Whether the target definition is root.
      #
      def root?
        parent.is_a?(Podfile) || parent.nil?
      end

      # @return [TargetDefinition] The root target definition.
      #
      def root
        if root?
          self
        else
          parent.root
        end
      end

      # @return [Podfile] The podfile that contains the specification for this
      #         target definition.
      #
      def podfile
        root.parent
      end

      # @return [Array<Dependency>] The list of the dependencies of the target
      #         definition including the inherited ones.
      #
      def dependencies
        if exclusive? || parent.nil?
          non_inherited_dependencies
        else
          non_inherited_dependencies + parent.dependencies
        end
      end

      # @return [Array] The list of the dependencies of the target definition,
      #         excluding inherited ones.
      #
      def non_inherited_dependencies
        pod_dependencies.concat(podspec_dependencies)
      end

      # @return [Bool] Whether the target definition has at least one
      #         dependency, excluding inherited ones.
      #
      def empty?
        non_inherited_dependencies.empty?
      end

      # @return [String] The label of the target definition according to its
      #         name.
      #
      def label
        if root? && name == 'Pods'
          'Pods'
        elsif exclusive? || parent.nil?
          "Pods-#{name}"
        else
          "#{parent.label}-#{name}"
        end
      end

      alias_method :to_s, :label

      # @return [String] A string representation suitable for debug.
      #
      def inspect
        "#<#{self.class} label=#{label}>"
      end

      #-----------------------------------------------------------------------#

      public

      # @!group Attributes

      # @return [String] the path of the project this target definition should
      #         link with.
      #
      def name
        get_hash_value('name')
      end

      # Sets the path of the user project this target definition should link
      # with.
      #
      # @param  [String] path
      #         The path of the project.
      #
      # @return [void]
      #
      def name=(name)
        set_hash_value('name', name)
      end

      #--------------------------------------#

      # Returns whether the target definition should inherit the dependencies
      # of the parent.
      #
      # @note   A target is always `exclusive` if it is root.
      #
      # @note   A target is always `exclusive` if the `platform` does
      #         not match the parent's `platform`.
      #
      # @return [Bool] whether is exclusive.
      #
      def exclusive?
        if root?
          true
        elsif get_hash_value('exclusive')
          true
        else
          platform && parent && parent.platform != platform
        end
      end

      # Sets whether the target definition is exclusive.
      #
      # @param  [Bool] flag
      #         Whether the definition is exclusive.
      #
      # @return [void]
      #
      def exclusive=(flag)
        set_hash_value('exclusive', flag)
      end

      #--------------------------------------#

      # @return [Array<String>] The list of the names of the Xcode targets with
      #         which this target definition should be linked with.
      #
      def link_with
        value = get_hash_value('link_with')
        value unless value.nil? || value.empty?
      end

      # Sets the client targets that should be integrated by this definition.
      #
      # @param  [Array<String>] targets
      #         The list of the targets names.
      #
      # @return [void]
      #
      def link_with=(targets)
        set_hash_value('link_with', Array(targets).map(&:to_s))
      end

      #--------------------------------------#

      # Returns whether the target definition should link with the first target
      # of the project.
      #
      # @note   This option is ignored if {link_with} is set.
      #
      # @return [Bool] whether is exclusive.
      #
      def link_with_first_target?
        get_hash_value('link_with_first_target') unless link_with
      end

      # Sets whether the target definition should link with the first target of
      # the project.
      #
      # @note   This option is ignored if {link_with} is set.
      #
      # @param  [Bool] flag
      #         Whether the definition should link with the first target.
      #
      # @return [void]
      #
      def link_with_first_target=(flag)
        set_hash_value('link_with_first_target', flag)
      end

      #--------------------------------------#

      # @return [String] the path of the project this target definition should
      #         link with.
      #
      def user_project_path
        path = get_hash_value('user_project_path')
        if path
          File.extname(path) == '.xcodeproj' ? path : "#{path}.xcodeproj"
        else
          parent.user_project_path unless root?
        end
      end

      # Sets the path of the user project this target definition should link
      # with.
      #
      # @param  [String] path
      #         The path of the project.
      #
      # @return [void]
      #
      def user_project_path=(path)
        set_hash_value('user_project_path', path)
      end

      #--------------------------------------#

      # @return [Hash{String => symbol}] A hash where the keys are the name of
      #         the build configurations and the values a symbol that
      #         represents their type (`:debug` or `:release`).
      #
      def build_configurations
        if root?
          get_hash_value('build_configurations')
        else
          get_hash_value('build_configurations') || parent.build_configurations
        end
      end

      # Sets the build configurations for this target.
      #
      # @return [Hash{String => Symbol}] hash
      #         A hash where the keys are the name of the build configurations
      #         and the values the type.
      #
      # @return [void]
      #
      def build_configurations=(hash)
        set_hash_value('build_configurations', hash) unless hash.empty?
      end

      #--------------------------------------#

      # @return [Bool] whether the target definition should inhibit warnings
      #         for a single pod. If inhibit_all_warnings is true, it will
      #         return true for any asked pod.
      #
      def inhibits_warnings_for_pod?(pod_name)
        if inhibit_warnings_hash['all']
          true
        elsif !root? && parent.inhibits_warnings_for_pod?(pod_name)
          true
        else
          inhibit_warnings_hash['for_pods'] ||= []
          inhibit_warnings_hash['for_pods'].include? pod_name
        end
      end

      # Sets whether the target definition should inhibit the warnings during
      # compilation for all pods.
      #
      # @param  [Bool] flag
      #         Whether the warnings should be suppressed.
      #
      # @return [void]
      #
      def inhibit_all_warnings=(flag)
        inhibit_warnings_hash['all'] = flag
      end

      # Inhibits warnings for a specific pod during compilation.
      #
      # @param  [String] pod name
      #         Whether the warnings should be suppressed.
      #
      # @return [void]
      #
      def inhibit_warnings_for_pod(pod_name)
        inhibit_warnings_hash['for_pods'] ||= []
        inhibit_warnings_hash['for_pods'] << pod_name
      end

      #--------------------------------------#

      # Whether a specific pod should be linked to the target when building for
      # a specific configuration. If a pod has not been explicitly whitelisted
      # for any configuration, it is implicitly whitelisted.
      #
      # @param  [String] pod_name
      #         The pod that we're querying about inclusion for in the given
      #         configuration.
      #
      # @param  [String] configuration_name
      #         The configuration that we're querying about inclusion of the
      #         pod in.
      #
      # @note   Build configurations are case compared case-insensitively in
      #         CocoaPods.
      #
      # @return [Bool] flag
      #         Whether the pod should be linked with the target
      #
      def pod_whitelisted_for_configuration?(pod_name, configuration_name)
        found = false
        configuration_pod_whitelist.each do |configuration, pods|
          if pods.include?(pod_name)
            found = true
            if configuration.downcase == configuration_name.to_s.downcase
              return true
            end
          end
        end
        !found
      end

      # Whitelists a pod for a specific configuration. If a pod is whitelisted
      # for any configuration, it will only be linked with the target in the
      # configuration(s) specified. If it is not whitelisted for any
      # configuration, it is implicitly included in all configurations.
      #
      # @param  [String] pod_name
      #         The pod that should be included in the given configuration.
      #
      # @param  [String, Symbol] configuration_name
      #         The configuration that the pod should be included in
      #
      # @note   Build configurations are stored as a String.
      #
      # @return [void]
      #
      def whitelist_pod_for_configuration(pod_name, configuration_name)
        configuration_name = configuration_name.to_s
        configuration_pod_whitelist[configuration_name] ||= []
        configuration_pod_whitelist[configuration_name] << pod_name
      end

      # @return [Array<String>] unique list of all configurations for which
      #         pods have been whitelisted.
      #
      def all_whitelisted_configurations
        configuration_pod_whitelist.keys.uniq
      end

      #--------------------------------------#

      # @return [Platform] the platform of the target definition.
      #
      # @note   If no deployment target has been specified a default value is
      #         provided.
      #
      def platform
        name_or_hash = get_hash_value('platform')
        if name_or_hash
          if name_or_hash.is_a?(Hash)
            name = name_or_hash.keys.first.to_sym
            target = name_or_hash.values.first
          else
            name = name_or_hash.to_sym
          end
          target ||= (name == :ios ? '4.3' : '10.6')
          Platform.new(name, target)
        else
          parent.platform unless root?
        end
      end

      # Sets the platform of the target definition.
      #
      # @param  [Symbol] name
      #         The name of the platform.
      #
      # @param  [String] target
      #         The deployment target of the platform.
      #
      # @raise  When the name of the platform is unsupported.
      #
      # @return [void]
      #
      def set_platform(name, target = nil)
        unless [:ios, :osx].include?(name)
          raise StandardError, "Unsupported platform `#{name}`. Platform " \
            'must be `:ios` or `:osx`.'
        end

        if target
          value = { name.to_s => target }
        else
          value = name.to_s
        end
        set_hash_value('platform', value)
      end

      #--------------------------------------#

      # Stores the dependency for a Pod with the given name.
      #
      # @param  [String] name
      #         The name of the Pod
      #
      # @param  [Array<String, Hash>] requirements
      #         The requirements and the options of the dependency.
      #
      # @note   The dependencies are stored as an array. To simplify the YAML
      #         representation if they have requirements they are represented
      #         as a Hash, otherwise only the String of the name is added to
      #         the array.
      #
      # @todo   This needs urgently a rename.
      #
      # @return [void]
      #
      def store_pod(name, *requirements)
        parse_inhibit_warnings(name, requirements)
        parse_configuration_whitelist(name, requirements)

        if requirements && !requirements.empty?
          pod = { name => requirements }
        else
          pod = name
        end

        get_hash_value('dependencies', []) << pod
      end

      #--------------------------------------#

      # Stores the podspec whose dependencies should be included by the
      # target.
      #
      # @param  [Hash] options
      #         The options used to find the podspec (either by name or by
      #         path). If nil the podspec is auto-detected (i.e. the first one
      #         in the folder of the Podfile)
      #
      # @note   The storage of this information is optimized for YAML
      #         readability.
      #
      # @todo   This needs urgently a rename.
      #
      # @return [void]
      #
      def store_podspec(options = nil)
        if options
          unless options.keys.all? { |key| [:name, :path].include?(key) }
            raise StandardError, 'Unrecognized options for the podspec ' \
              "method `#{options}`"
          end
          get_hash_value('podspecs', []) << options
        else
          get_hash_value('podspecs', []) << { :autodetect => true }
        end
      end

      #-----------------------------------------------------------------------#

      public

      # @!group Representations

      # @return [Array] The keys used by the hash representation of the
      #         target definition.
      #
      HASH_KEYS = %w(
        name
        platform
        podspecs
        exclusive
        link_with
        link_with_first_target
        inhibit_warnings
        user_project_path
        build_configurations
        dependencies
        children
        configuration_pod_whitelist
      ).freeze

      # @return [Hash] The hash representation of the target definition.
      #
      def to_hash
        hash = internal_hash.dup
        unless children.empty?
          hash['children'] = children.map(&:to_hash)
        end
        hash
      end

      # Configures a new target definition from the given hash.
      #
      # @param  [Hash] the hash which contains the information of the
      #         Podfile.
      #
      # @return [TargetDefinition] the new target definition
      #
      def self.from_hash(hash, parent)
        internal_hash = hash.dup
        children_hashes = internal_hash.delete('children') || []
        definition = TargetDefinition.new(nil, parent, internal_hash)
        children_hashes.each do |child_hash|
          TargetDefinition.from_hash(child_hash, definition)
        end
        definition
      end

      #-----------------------------------------------------------------------#

      private

      # @!group Private helpers

      # @return [Array<TargetDefinition>]
      #
      attr_writer :children

      # @return [Hash] The hash which store the attributes of the target
      #         definition.
      #
      attr_accessor :internal_hash

      # Set a value in the internal hash of the target definition for the given
      # key.
      #
      # @param  [String] key
      #         The key for which to store the value.
      #
      # @param  [Object] value
      #         The value to store.
      #
      # @raise  If the key is not recognized.
      #
      # @return [void]
      #
      def set_hash_value(key, value)
        unless HASH_KEYS.include?(key)
          raise StandardError, "Unsupported hash key `#{key}`"
        end
        internal_hash[key] = value
      end

      # Returns the value for the given key in the internal hash of the target
      # definition.
      #
      # @param  [String] key
      #         The key for which the value is needed.
      #
      # @param  [Object] base_value
      #         The value to set if they key is nil. Useful for collections.
      #
      # @raise  If the key is not recognized.
      #
      # @return [Object] The value for the key.
      #
      def get_hash_value(key, base_value = nil)
        unless HASH_KEYS.include?(key)
          raise StandardError, "Unsupported hash key `#{key}`"
        end
        internal_hash[key] ||= base_value
      end

      # Returns the inhibit_warnings hash pre-populated with default values.
      #
      # @return [Hash<String, Array>] Hash with :all key for inhibiting all
      #         warnings, and :for_pods key for inhibiting warnings per Pod.
      #
      def inhibit_warnings_hash
        get_hash_value('inhibit_warnings', {})
      end

      # Returns the configuration_pod_whitelist hash
      #
      # @return [Hash<String, Array>] Hash with configuration name as key,
      #         array of pod names to be linked in builds with that configuration
      #         as value.
      #
      def configuration_pod_whitelist
        get_hash_value('configuration_pod_whitelist', {})
      end

      # @return [Array<Dependency>] The dependencies specified by the user for
      #         this target definition.
      #
      def pod_dependencies
        pods = get_hash_value('dependencies') || []
        pods.map do |name_or_hash|
          if name_or_hash.is_a?(Hash)
            name = name_or_hash.keys.first
            requirements = name_or_hash.values.first
            Dependency.new(name, *requirements)
          else
            Dependency.new(name_or_hash)
          end
        end
      end

      # @return [Array<Dependency>] The dependencies inherited by the podspecs.
      #
      # @note   The podspec directive is intended include the dependencies of a
      #         spec in the project where it is developed. For this reason the
      #         spec, or any of it subspecs, cannot be included in the
      #         dependencies. Otherwise it would generate a chicken-and-egg
      #         problem.
      #
      def podspec_dependencies
        podspecs = get_hash_value('podspecs') || []
        podspecs.map do |options|
          file = podspec_path_from_options(options)
          spec = Specification.from_file(file)
          all_specs = [spec, *spec.recursive_subspecs]
          all_deps = all_specs.map { |s| s.dependencies(platform) }.flatten
          all_deps.reject { |dep| dep.root_name == spec.root.name }
        end.flatten.uniq
      end

      # The path of the podspec with the given options.
      #
      # @param  [Hash] options
      #         The options to use for finding the podspec. The supported keys
      #         are: `:name`, `:path`, `:autodetect`.
      #
      # @return [Pathname] The path.
      #
      def podspec_path_from_options(options)
        if path = options[:path]
          if File.extname(path) == '.podspec'
            path_with_ext = path
          else
            path_with_ext = "#{path}.podspec"
          end
          path_without_tilde = path_with_ext.gsub('~', ENV['HOME'])
          podfile.defined_in_file.dirname + path_without_tilde
        elsif name = options[:name]
          name = File.extname(name) == '.podspec' ? name : "#{name}.podspec"
          podfile.defined_in_file.dirname + name
        elsif options[:autodetect]
          glob_pattern = podfile.defined_in_file.dirname + '*.podspec'
          Pathname.glob(glob_pattern).first
        end
      end

      # Removes :inhibit_warnings from the requirements list, and adds
      # the pod's name into internal hash for disabling warnings.
      #
      # @param [String] pod name
      #
      # @param [Array] requirements
      #        If :inhibit_warnings is the only key in the hash, the hash
      #        should be destroyed because it confuses Gem::Dependency.
      #
      # @return [void]
      #
      def parse_inhibit_warnings(name, requirements)
        options = requirements.last
        return requirements unless options.is_a?(Hash)

        should_inhibit = options.delete(:inhibit_warnings)
        inhibit_warnings_for_pod(name) if should_inhibit

        requirements.pop if options.empty?
      end

      # Removes :configurations or :configuration from the requirements list,
      # and adds the pod's name into the internal hash for which pods should be
      # linked in which configuration only.
      #
      # @param [String] pod name
      #
      # @param [Array] requirements
      #        If :configurations is the only key in the hash, the hash
      #        should be destroyed because it confuses Gem::Dependency.
      #
      # @return [void]
      #
      def parse_configuration_whitelist(name, requirements)
        options = requirements.last
        return requirements unless options.is_a?(Hash)

        configurations = options.delete(:configurations)
        configurations ||= options.delete(:configuration)
        if configurations
          Array(configurations).each do |configuration|
            whitelist_pod_for_configuration(name, configuration)
          end
        end
        requirements.pop if options.empty?
      end

      #-----------------------------------------------------------------------#
    end
  end
end
