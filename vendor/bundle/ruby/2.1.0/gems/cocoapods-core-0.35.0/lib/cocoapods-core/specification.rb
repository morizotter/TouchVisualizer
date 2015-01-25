require 'cocoapods-core/specification/consumer'
require 'cocoapods-core/specification/dsl'
require 'cocoapods-core/specification/linter'
require 'cocoapods-core/specification/root_attribute_accessors'
require 'cocoapods-core/specification/set'
require 'cocoapods-core/specification/json'

module Pod
  # The Specification provides a DSL to describe a Pod. A pod is defined as a
  # library originating from a source. A specification can support detailed
  # attributes for modules of code  through subspecs.
  #
  # Usually it is stored in files with `podspec` extension.
  #
  class Specification
    include Pod::Specification::DSL
    include Pod::Specification::DSL::Deprecations
    include Pod::Specification::RootAttributesAccessors
    include Pod::Specification::JSONSupport

    # @return [Specification] the parent of the specification unless the
    #         specification is a root.
    #
    attr_reader :parent

    # @param  [Specification] parent @see parent
    #
    # @param  [String] name
    #         the name of the specification.
    #
    def initialize(parent = nil, name = nil)
      @attributes_hash = {}
      @subspecs = []
      @consumers = {}
      @parent = parent
      attributes_hash['name'] = name

      yield self if block_given?
    end

    # @return [Hash] the hash that stores the information of the attributes of
    #         the specification.
    #
    attr_accessor :attributes_hash

    # @return [Array<Specification>] The subspecs of the specification.
    #
    attr_accessor :subspecs

    # Checks if a specification is equal to the given one according its name
    # and to its version.
    #
    # @param  [Specification] other
    #         the specification to compare with.
    #
    # @todo   Not sure if comparing only the name and the version is the way to
    #         go. This is used by the installer to group specifications by root
    #         spec.
    #
    # @return [Bool] Whether the specifications are equal.
    #
    def ==(other)
      # TODO
      # self.class === other &&
      #   attributes_hash == other.attributes_hash &&
      #   subspecs == other.subspecs &&
      to_s == other.to_s
    end

    # @see ==
    #
    def eql?(other)
      self == other
    end

    # Return the hash value for this specification according to its attributes
    # hash.
    #
    # @note   This function must have the property that a.eql?(b) implies
    #         a.hash == b.hash.
    #
    # @note   This method is used by the Hash class.
    #
    # @return [Fixnum] The hash value.
    #
    def hash
      to_s.hash
    end

    # @return [String] A string suitable for representing the specification in
    #         clients.
    #
    def to_s
      if name && !version.version.empty?
        "#{name} (#{version})"
      elsif name
        name
      else
        'No-name'
      end
    end

    # @return [String] A string suitable for debugging.
    #
    def inspect
      "#<#{self.class.name} name=#{name.inspect}>"
    end

    # @param    [String] string_representation
    #           the string that describes a {Specification} generated from
    #           {Specification#to_s}.
    #
    # @example  Input examples
    #
    #           "libPusher (1.0)"
    #           "libPusher (HEAD based on 1.0)"
    #           "RestKit/JSON (1.0)"
    #
    # @return   [Array<String, Version>] the name and the version of a
    #           pod.
    #
    def self.name_and_version_from_string(string_representation)
      match_data = string_representation.match(/\A((?:\s?[^\s(])+)(?: \((.+)\))?\Z/)
      unless match_data
        raise Informative, 'Invalid string representation for a ' \
          "specification: `#{string_representation}`. " \
          'The string representation should include the name and ' \
          'optionally the version of the Pod.'
      end
      name = match_data[1]
      vers = Version.new(match_data[2])
      [name, vers]
    end

    # Returns the root name of a specification.
    #
    # @param  [String] the name of a specification or of a subspec.
    #
    # @return [String] the root name
    #
    def self.root_name(full_name)
      full_name.split('/').first
    end

    #-------------------------------------------------------------------------#

    public

    # @!group Hierarchy

    # @return [Specification] The root specification or itself if it is root.
    #
    def root
      parent ? parent.root : self
    end

    # @return [Bool] whether the specification is root.
    #
    def root?
      parent.nil?
    end

    # @return [Bool] whether the specification is a subspec.
    #
    def subspec?
      !parent.nil?
    end

    #-------------------------------------------------------------------------#

    public

    # @!group Dependencies & Subspecs

    # @return [Array<Specifications>] the recursive list of all the subspecs of
    #         a specification.
    #
    def recursive_subspecs
      mapper = lambda do |spec|
        spec.subspecs.map do |subspec|
          [subspec, *mapper.call(subspec)]
        end.flatten
      end
      mapper.call(self)
    end

    # Returns the subspec with the given name or the receiver if the name is
    # nil or equal to the name of the receiver.
    #
    # @param    [String] relative_name
    #           the relative name of the subspecs starting from the receiver
    #           including the name of the receiver.
    #
    # @param    [Boolean] raise_if_missing
    #           whether an exception should be raised if no specification named
    #           `relative_name` is found.
    #
    # @example  Retrieving a subspec
    #
    #           s.subspec_by_name('Pod/subspec').name #=> 'subspec'
    #
    # @return   [Specification] the subspec with the given name or self.
    #
    def subspec_by_name(relative_name, raise_if_missing = true)
      if relative_name.nil? || relative_name == base_name
        self
      else
        remainder = relative_name[base_name.size + 1..-1]
        subspec_name = remainder.split('/').shift
        subspec = subspecs.find { |s| s.base_name == subspec_name }
        unless subspec
          if raise_if_missing
            raise Informative, 'Unable to find a specification named ' \
              "`#{relative_name}` in `#{name} (#{version})`."
          else
            return nil
          end
        end
        subspec.subspec_by_name(remainder)
      end
    end

    # @return [Array] the name of the default subspecs if provided.
    #
    def default_subspecs
      # TODO: remove singular form and update the JSON specs.
      Array(attributes_hash['default_subspecs'] || attributes_hash['default_subspec'])
    end

    # Returns the dependencies on subspecs.
    #
    # @note   A specification has a dependency on either the
    #         {#default_subspecs} or each of its children subspecs that are
    #         compatible with its platform.
    #
    # @return [Array<Dependency>] the dependencies on subspecs.
    #
    def subspec_dependencies(platform = nil)
      if default_subspecs.empty?
        specs = subspecs.compact
      else
        specs = default_subspecs.map do |subspec_name|
          root.subspec_by_name("#{name}/#{subspec_name}")
        end
      end
      if platform
        specs = specs.select { |s| s.supported_on_platform?(platform) }
      end
      specs.map { |s| Dependency.new(s.name, version) }
    end

    # Returns the dependencies on other Pods or subspecs of other Pods.
    #
    # @param  [Bool] all_platforms
    #         whether the dependencies should be returned for all platforms
    #         instead of the active one.
    #
    # @note   External dependencies are inherited by subspecs
    #
    # @return [Array<Dependency>] the dependencies on other Pods.
    #
    def dependencies(platform = nil)
      if platform
        consumer(platform).dependencies || []
      else
        available_platforms.map do |spec_platform|
          consumer(spec_platform).dependencies
        end.flatten.uniq
      end
    end

    # @return [Array<Dependency>] all the dependencies of the specification.
    #
    def all_dependencies(platform = nil)
      dependencies(platform) + subspec_dependencies(platform)
    end

    # Returns a consumer to access the multi-platform attributes.
    #
    # @param  [String, Symbol, Platform] platform
    #         he platform of the consumer
    #
    # @return [Specification::Consumer] the consumer for the given platform
    #
    def consumer(platform)
      platform = platform.to_sym
      @consumers[platform] ||= Consumer.new(self, platform)
    end

    #-------------------------------------------------------------------------#

    public

    # @!group DSL helpers

    # @return [Bool] whether the specification should use a directory as it
    #         source.
    #
    def local?
      return true if source[:path]
      return true if source[:local]
      false
    end

    # @return     [Bool] whether the specification is supported in the given
    #             platform.
    #
    # @overload   supported_on_platform?(platform)
    #
    #   @param    [Platform] platform
    #             the platform which is checked for support.
    #
    # @overload   supported_on_platform?(symbolic_name, deployment_target)
    #
    #   @param    [Symbol] symbolic_name
    #             the name of the platform which is checked for support.
    #
    #   @param    [String] deployment_target
    #             the deployment target which is checked for support.
    #
    def supported_on_platform?(*platform)
      platform = Platform.new(*platform)
      available_platforms.any? { |available| platform.supports?(available) }
    end

    # @return [Array<Platform>] The platforms that the Pod is supported on.
    #
    # @note   If no platform is specified, this method returns all known
    #         platforms.
    #
    def available_platforms
      names = supported_platform_names
      names = PLATFORMS if names.empty?
      names.map { |name| Platform.new(name, deployment_target(name)) }
    end

    # Returns the deployment target for the specified platform.
    #
    # @param  [String] platform_name
    #         the symbolic name of the platform.
    #
    # @return [String] the deployment target
    # @return [Nil] if not deployment target was specified for the platform.
    #
    def deployment_target(platform_name)
      result = platform_hash[platform_name.to_s]
      result ||= parent.deployment_target(platform_name) if parent
      result
    end

    protected

    # @return [Array[Symbol]] the symbolic name of the platform in which the
    #         specification is supported.
    #
    # @return [Nil] if the specification is supported on all the known
    #         platforms.
    #
    def supported_platform_names
      result = platform_hash.keys
      if result.empty? && parent
        result = parent.supported_platform_names
      end
      result
    end

    # @return [Hash] the normalized hash which represents the platform
    #         information.
    #
    def platform_hash
      case value = attributes_hash['platforms']
      when String
        { value => nil }
      when Array
        result = {}
        value.each do |a_value|
          result[a_value] = nil
        end
        result
      when Hash
        value
      else
        {}
      end
    end

    public

    #-------------------------------------------------------------------------#

    # @!group DSL attribute writers

    # Sets the value for the attribute with the given name.
    #
    # @param  [Symbol] name
    #         the name of the attribute.
    #
    # @param  [Object] value
    #         the value to store.
    #
    # @param  [Symbol] platform.
    #         If provided the attribute is stored only for the given platform.
    #
    # @note   If the provides value is Hash the keys are converted to a string.
    #
    # @return void
    #
    def store_attribute(name, value, platform_name = nil)
      name = name.to_s
      value = convert_keys_to_string(value) if value.is_a?(Hash)
      if platform_name
        platform_name = platform_name.to_s
        attributes_hash[platform_name] ||= {}
        attributes_hash[platform_name][name] = value
      else
        attributes_hash[name] = value
      end
    end

    # Defines the setters methods for the attributes providing support for the
    # Ruby DSL.
    #
    DSL.attributes.values.each do |a|
      define_method(a.writer_name) do |value|
        store_attribute(a.name, value)
      end

      if a.writer_singular_form
        alias_method(a.writer_singular_form, a.writer_name)
      end
    end

    private

    # Converts the keys of the given hash to a string.
    #
    # @param  [Object] value
    #         the value that needs to be stripped from the Symbols.
    #
    # @return [Hash] the hash with the strings instead of the keys.
    #
    def convert_keys_to_string(value)
      return unless value
      result = {}
      value.each do |key, subvalue|
        subvalue = convert_keys_to_string(subvalue) if subvalue.is_a?(Hash)
        result[key.to_s] = subvalue
      end
      result
    end

    #-------------------------------------------------------------------------#

    public

    # @!group File representation

    # @return [String] The SHA1 digest of the file in which the specification
    #         is defined.
    #
    # @return [Nil] If the specification is not defined in a file.
    #
    def checksum
      require 'digest'
      unless defined_in_file.nil?
        checksum = Digest::SHA1.hexdigest(File.read(defined_in_file))
        checksum = checksum.encode('UTF-8') if checksum.respond_to?(:encode)
        checksum
      end
    end

    # @return [String] the path where the specification is defined, if loaded
    #         from a file.
    #
    def defined_in_file
      root? ? @defined_in_file : root.defined_in_file
    end

    # Loads a specification form the given path.
    #
    # @param  [Pathname, String] path
    #         the path of the `podspec` file.
    #
    # @param  [String] subspec_name
    #         the name of the specification that should be returned. If it is
    #         nil returns the root specification.
    #
    # @raise  If the file doesn't return a Pods::Specification after
    #         evaluation.
    #
    # @return [Specification] the specification
    #
    def self.from_file(path, subspec_name = nil)
      path = Pathname.new(path)
      unless path.exist?
        raise Informative, "No podspec exists at path `#{path}`."
      end

      string = File.open(path, 'r:utf-8') { |f| f.read }
      # Work around for Rubinius incomplete encoding in 1.9 mode
      if string.respond_to?(:encoding) && string.encoding.name != 'UTF-8'
        string.encode!('UTF-8')
      end

      from_string(string, path, subspec_name)
    end

    # Loads a specification with the given string.
    #
    # @param  [String] spec_contents
    #         A string describing a specification.
    #
    # @param  [Pathname, String] path @see from_file
    # @param  [String] subspec_name @see from_file
    #
    # @return [Specification] the specification
    #
    def self.from_string(spec_contents, path, subspec_name = nil)
      path = Pathname.new(path)
      case path.extname
      when '.podspec'
        spec = ::Pod._eval_podspec(spec_contents, path)
        unless spec.is_a?(Specification)
          raise Informative, "Invalid podspec file at path `#{path}`."
        end
      when '.json'
        spec = Specification.from_json(spec_contents)
      else
        raise Informative, "Unsupported specification format `#{path.extname}`."
      end

      spec.defined_in_file = path
      spec.subspec_by_name(subspec_name)
    end

    # Sets the path of the `podspec` file used to load the specification.
    #
    # @param  [String] file
    #         the `podspec` file.
    #
    # @return [void]
    #
    # @visibility private
    #
    def defined_in_file=(file)
      unless root?
        raise StandardError, 'Defined in file can be set only for root specs.'
      end
      @defined_in_file = file
    end
  end

  #---------------------------------------------------------------------------#

  # @visibility private
  #
  # Evaluates the given string in the namespace of the Pod module.
  #
  # @param  [String] string
  #         The string containing the Ruby description of the Object to
  #         evaluate.
  #
  # @param  [Pathname] path
  #         The path where the object to evaluate is stored.
  #
  # @return [Object] it can return any object but, is expected to be called on
  #         `podspec` files that should return a #{Specification}.
  #
  #
  def self._eval_podspec(string, path)
    # rubocop:disable Eval
    eval(string, nil, path.to_s)
    # rubocop:enable Eval
  rescue => e
    message = "Invalid `#{path.basename}` file: #{e.message}"
    raise DSLError.new(message, path, e.backtrace)
  end
end
