require 'cocoapods-core/podfile/dsl'
require 'cocoapods-core/podfile/target_definition'

module Pod
  # The Podfile is a specification that describes the dependencies of the
  # targets of an Xcode project.
  #
  # It supports its own DSL and generally is stored in files named
  # `CocoaPods.podfile` or `Podfile`.
  #
  # The Podfile creates a hierarchy of target definitions that that store the
  # information of necessary to generate the CocoaPods libraries.
  #
  class Podfile
    # @!group DSL support

    include Pod::Podfile::DSL

    #-------------------------------------------------------------------------#

    class StandardError < ::StandardError; end

    #-------------------------------------------------------------------------#

    # @return [Pathname] the path where the podfile was loaded from. It is nil
    #         if the podfile was generated programmatically.
    #
    attr_accessor :defined_in_file

    # @param    [Pathname] defined_in_file
    #           the path of the podfile.
    #
    # @param    [Proc] block
    #           an optional block that configures the podfile through the DSL.
    #
    # @example  Creating a Podfile.
    #
    #           platform :ios, "6.0"
    #           target :my_app do
    #             pod "AFNetworking", "~> 1.0"
    #           end
    #
    def initialize(defined_in_file = nil, internal_hash = {}, &block)
      self.defined_in_file = defined_in_file
      @internal_hash = internal_hash
      if block
        default_target_def = TargetDefinition.new('Pods', self)
        default_target_def.link_with_first_target = true
        @root_target_definitions = [default_target_def]
        @current_target_definition = default_target_def
        instance_eval(&block)
      else
        @root_target_definitions = []
      end
    end

    # @return [String] a string useful to represent the Podfile in a message
    #         presented to the user.
    #
    def to_s
      'Podfile'
    end

    #-------------------------------------------------------------------------#

    public

    # @!group Working with a podfile

    # @return [Hash{Symbol,String => TargetDefinition}] the target definitions
    #         of the podfile stored by their name.
    #
    def target_definitions
      Hash[target_definition_list.map { |td| [td.name, td] }]
    end

    def target_definition_list
      root_target_definitions.map { |td| [td, td.recursive_children] }.flatten
    end

    # @return [Array<TargetDefinition>] The root target definition.
    #
    attr_accessor :root_target_definitions

    # @return [Array<Dependency>] the dependencies of the all the target
    #         definitions.
    #
    def dependencies
      target_definition_list.map(&:dependencies).flatten.uniq
    end

    #-------------------------------------------------------------------------#

    public

    # @!group Attributes

    # @return [Array<String>] The name of the sources.
    #
    def sources
      get_hash_value('sources') || []
    end

    # @return [String] the path of the workspace if specified by the user.
    #
    def workspace_path
      path = get_hash_value('workspace')
      if path
        if File.extname(path) == '.xcworkspace'
          path
        else
          "#{path}.xcworkspace"
        end
      end
    end

    # @return [Bool] whether the podfile should generate a BridgeSupport
    #         metadata document.
    #
    def generate_bridge_support?
      get_hash_value('generate_bridge_support')
    end

    # @return [Bool] whether the -fobjc-arc flag should be added to the
    #         OTHER_LD_FLAGS.
    #
    def set_arc_compatibility_flag?
      get_hash_value('set_arc_compatibility_flag')
    end

    #-------------------------------------------------------------------------#

    public

    # @!group Hooks

    # Calls the pre install callback if defined.
    #
    # @param  [Pod::Installer] installer
    #         the installer that is performing the installation.
    #
    # @return [Bool] whether a pre install callback was specified and it was
    #         called.
    #
    def pre_install!(installer)
      if @pre_install_callback
        @pre_install_callback.call(installer)
        true
      else
        false
      end
    end

    # Calls the post install callback if defined.
    #
    # @param  [Pod::Installer] installer
    #         the installer that is performing the installation.
    #
    # @return [Bool] whether a post install callback was specified and it was
    #         called.
    #
    def post_install!(installer)
      if @post_install_callback
        @post_install_callback.call(installer)
        true
      else
        false
      end
    end

    #-------------------------------------------------------------------------#

    public

    # @!group Representations

    # @return [Array] The keys used by the hash representation of the Podfile.
    #
    HASH_KEYS = %w(
      target_definitions
      workspace
      sources
      generate_bridge_support
      set_arc_compatibility_flag
    ).freeze

    # @return [Hash] The hash representation of the Podfile.
    #
    def to_hash
      hash = {}
      hash['target_definitions'] = root_target_definitions.map(&:to_hash)
      hash.merge!(internal_hash)
      hash
    end

    # @return [String] The YAML representation of the Podfile.
    #
    def to_yaml
      to_hash.to_yaml
    end

    # @!group Class methods
    #-------------------------------------------------------------------------#

    # Initializes a podfile from the file with the given path.
    #
    # @param  [Pathname] path
    #         the path from where the podfile should be loaded.
    #
    # @return [Podfile] the generated podfile.
    #
    def self.from_file(path)
      path = Pathname.new(path)
      unless path.exist?
        raise Informative, "No Podfile exists at path `#{path}`."
      end

      case path.extname
      when '', '.podfile'
        Podfile.from_ruby(path)
      when '.yaml'
        Podfile.from_yaml(path)
      else
        raise Informative, "Unsupported Podfile format `#{path}`."
      end
    end

    # Configures a new Podfile from the given ruby string.
    #
    # @param  [String] string
    #         The ruby string which will configure the podfile with the DSL.
    #
    # @param  [Pathname] path
    #         The path from which the Podfile is loaded.
    #
    # @return [Podfile] the new Podfile
    #
    def self.from_ruby(path)
      string = File.open(path, 'r:utf-8') { |f| f.read }
      # Work around for Rubinius incomplete encoding in 1.9 mode
      if string.respond_to?(:encoding) && string.encoding.name != 'UTF-8'
        string.encode!('UTF-8')
      end
      podfile = Podfile.new(path) do
        begin
          # rubocop:disable Eval
          eval(string, nil, path.to_s)
          # rubocop:enable Eval
        rescue => e
          message = "Invalid `#{path.basename}` file: #{e.message}"
          raise DSLError.new(message, path, e.backtrace)
        end
      end
      podfile
    end

    # Configures a new Podfile from the given YAML representation.
    #
    # @param  [String] yaml
    #         The YAML encoded hash which contains the information of the
    #         Podfile.
    #
    # @param  [Pathname] path
    #         The path from which the Podfile is loaded.
    #
    # @return [Podfile] the new Podfile
    #
    def self.from_yaml(path)
      string = File.open(path, 'r:utf-8') { |f| f.read }
      # Work around for Rubinius incomplete encoding in 1.9 mode
      if string.respond_to?(:encoding) && string.encoding.name != 'UTF-8'
        string.encode!('UTF-8')
      end
      hash = YAMLHelper.load_string(string)
      from_hash(hash, path)
    end

    # Configures a new Podfile from the given hash.
    #
    # @param  [Hash] hash
    #         The hash which contains the information of the Podfile.
    #
    # @param  [Pathname] path
    #         The path from which the Podfile is loaded.
    #
    # @return [Podfile] the new Podfile
    #
    def self.from_hash(hash, path = nil)
      internal_hash = hash.dup
      target_definitions = internal_hash.delete('target_definitions') || []
      podfile = Podfile.new(path, internal_hash)
      target_definitions.each do |definition_hash|
        definition = TargetDefinition.from_hash(definition_hash, podfile)
        podfile.root_target_definitions << definition
      end
      podfile
    end

    #-------------------------------------------------------------------------#

    private

    # @!group Private helpers

    # @return [Hash] The hash which store the attributes of the Podfile.
    #
    attr_accessor :internal_hash

    # Set a value in the internal hash of the Podfile for the given key.
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

    # Returns the value for the given key in the internal hash of the Podfile.
    #
    # @param  [String] key
    #         The key for which the value is needed.
    #
    # @raise  If the key is not recognized.
    #
    # @return [Object] The value for the key.
    #
    def get_hash_value(key)
      unless HASH_KEYS.include?(key)
        raise StandardError, "Unsupported hash key `#{key}`"
      end
      internal_hash[key]
    end

    # @return [TargetDefinition] The current target definition to which the DSL
    #         commands apply.
    #
    attr_accessor :current_target_definition

    public

    # @!group Deprecations
    #-------------------------------------------------------------------------#

    # @deprecated Deprecated in favour of the more succinct {#pod}. Remove for
    #             CocoaPods 1.0.
    #
    def dependency(name = nil, *requirements, &block)
      CoreUI.warn "[DEPRECATED] `dependency' is deprecated (use `pod')"
      pod(name, *requirements, &block)
    end

    #-------------------------------------------------------------------------#
  end
end
