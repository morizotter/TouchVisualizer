module Pod
  # The Dependency allows to specify dependencies of a {Podfile} or a
  # {Specification} on a Pod. It stores the name of the dependency, version
  # requirements and external sources information.
  #
  # This class is based on the dependency class of RubyGems and mimics its
  # implementation with adjustments specific to CocoaPods. RubyGems is
  # available under the
  # [MIT license](https://github.com/rubygems/rubygems/blob/master/MIT.txt).
  #
  class Dependency
    # @return [String] The name of the Pod described by this dependency.
    #
    attr_accessor :name

    # @return [Hash{Symbol=>String}] a hash describing the external source
    #         where the pod should be fetched. The external source has to
    #         provide its own {Specification} file.
    #
    attr_accessor :external_source

    # @return [Bool] whether the dependency should use the podspec with the
    #         highest know version but force the downloader to checkout the
    #         `head` of the source repository.
    #
    attr_accessor :head
    alias_method :head?, :head

    # @overload   initialize(name, requirements)
    #
    #   @param    [String] name
    #             the name of the Pod.
    #
    #   @param    [Array, Version, String, Requirement] requirements
    #             an array specifying the version requirements of the
    #             dependency.
    #
    #   @example  Initialization with version requirements.
    #
    #             Dependency.new('AFNetworking')
    #             Dependency.new('AFNetworking', '~> 1.0')
    #             Dependency.new('AFNetworking', '>= 0.5', '< 0.7')
    #
    # @overload   initialize(name, external_source)
    #
    #   @param    [String] name
    #             the name of the Pod.
    #
    #   @param    [Hash] external_source
    #             a hash describing the external source.
    #
    #   @example  Initialization with an external source.
    #
    #             Dependency.new('libPusher', {:git     => 'example.com/repo.git'})
    #             Dependency.new('libPusher', {:path   => 'path/to/folder'})
    #             Dependency.new('libPusher', {:podspec => 'example.com/libPusher.podspec'})
    #
    # @overload   initialize(name, is_head)
    #
    #   @param    [String] name
    #             the name of the Pod.
    #
    #   @param    [Symbol] is_head
    #             a symbol that can be `:head` or nil.
    #
    #   @example  Initialization with the head option
    #
    #             Dependency.new('RestKit', :head)
    #
    def initialize(name = nil, *requirements)
      if requirements.last.is_a?(Hash)
        @external_source = requirements.pop
        unless requirements.empty?
          raise Informative, 'A dependency with an external source may not ' \
            "specify version requirements (#{name})."
        end

      elsif requirements.last == :head
        @head = true
        requirements.pop
        unless requirements.empty?
          raise Informative, 'A `:head` dependency may not specify version ' \
            "requirements (#{name})."
        end
      end

      if requirements.length == 1 && requirements.first.is_a?(Requirement)
        requirements = requirements.first
      end
      @name = name
      @requirement = Requirement.create(requirements)
    end

    # @return [Version] whether the dependency points to a specific version.
    #
    attr_accessor :specific_version

    # @return [Requirement] the requirement of this dependency (a set of
    #         one or more version restrictions).
    #
    # @todo   The specific version is stripped from head information because
    #         because its string representation would not parse. It would
    #         be better to add something like Version#display_string.
    #
    def requirement
      if specific_version
        Requirement.new(Version.new(specific_version.version))
      else
        @requirement
      end
    end

    # @return [Bool] whether the dependency points to a subspec.
    #
    def subspec_dependency?
      @name.include?('/')
    end

    # @return [Bool] whether the dependency points to an external source.
    #
    def external?
      !@external_source.nil?
    end

    # @return [Bool] whether the dependency points to a local path.
    #
    def local?
      if external_source
        external_source[:path] || external_source[:local]
      end
    end

    # Creates a new dependency with the name of the top level spec and the same
    # version requirements.
    #
    # @note   This is used by the {Specification::Set} class to merge
    #         dependencies and resolve the required version of a Pod regardless
    #         what particular specification (subspecs or top level) is
    #         required.
    #
    # @todo   This should not use `dup`. The `name` property should be an
    #         attr_reader.
    #
    # @return [Dependency] a dependency with the same versions requirements
    #         that is guaranteed to point to a top level specification.
    #
    def to_root_dependency
      dep = dup
      dep.name = root_name
      dep
    end

    # Returns the name of the Pod that the dependency is pointing to.
    #
    # @note   In case this is a dependency for a subspec, e.g.
    #         'RestKit/Networking', this returns 'RestKit', which is what the
    #         Pod::Source needs to know to retrieve the correct {Specification}
    #         from disk.
    #
    # @return [String] the name of the Pod.
    #
    def root_name
      subspec_dependency? ? @name.split('/').first : @name
    end

    # Checks if a dependency would be satisfied by the requirements of another
    # dependency.
    #
    # @param  [Dependency] other
    #         the other dependency.
    #
    # @note   This is used by the Lockfile to check if a stored dependency is
    #         still compatible with the Podfile.
    #
    # @return [Bool] whether the dependency is compatible with the given one.
    #
    def compatible?(other)
      return false unless name == other.name
      return false unless head? == other.head?
      return false unless external_source == other.external_source

      other.requirement.requirements.all? do | _operator, version |
        requirement.satisfied_by? Version.new(version)
      end
    end

    # @return [Bool] whether the dependency is equal to another taking into
    #         account the loaded specification, the head options and the
    #         external source.
    #
    def ==(other)
      self.class == other.class &&
        name == other.name &&
        requirement == other.requirement &&
        head? == other.head? &&
        external_source == other.external_source
    end
    alias_method :eql?, :==

    #  @return [Fixnum] The hash value based on the name and on the
    #  requirements.
    #
    def hash
      name.hash ^ requirement.hash
    end

    # @return [Fixnum] How the dependency should be sorted respect to another
    #         one according to its name.
    #
    def <=>(other)
      name <=> other.name
    end

    # Merges the version requirements of the dependency with another one.
    #
    # @param  [Dependency] other
    #         the other dependency to merge with.
    #
    # @note   If one of the decencies specifies an external source or is head,
    #         the resulting dependency preserves this attributes.
    #
    # @return [Dependency] a dependency (not necessary a new instance) that
    #         includes also the version requirements of the given one.
    #
    def merge(other)
      unless name == other.name
        raise ArgumentError, "#{self} and #{other} have different names"
      end
      default   = Requirement.default
      self_req  = requirement
      other_req = other.requirement

      if other_req == default
        dep = self.class.new(name, self_req)
      elsif self_req == default
        dep = self.class.new(name, other_req)
      else
        dep = self.class.new(name, self_req.as_list.concat(other_req.as_list))
      end

      dep.head = head? || other.head?
      if external_source || other.external_source
        self_external_source  = external_source || {}
        other_external_source = other.external_source || {}
        dep.external_source = self_external_source.merge(other_external_source)
      end
      dep
    end

    # Whether the dependency has any pre-release requirements
    #
    # @return [Bool] Whether the dependency has any pre-release requirements
    #
    def prerelease?
      @prerelease ||= requirement.requirements.
        any? { |r| Version.new(r[1].version).prerelease? }
    end

    # Checks whether the dependency would be satisfied by the specification
    # with the given name and version.
    #
    # @param  [String]
    #         The proposed name.
    #
    # @param  [String, Version] version
    #         The proposed version.
    #
    # @return [Bool] Whether the dependency is satisfied.
    #
    def match?(name, version)
      return false unless self.name == name
      return true if requirement.none?
      requirement.satisfied_by?(Version.new(version))
    end

    #-------------------------------------------------------------------------#

    # !@group String representation

    # Creates a string representation of the dependency suitable for
    # serialization and de-serialization without loss of information. The
    # string is also suitable for UI.
    #
    # @note     This representation is used by the {Lockfile}.
    #
    # @example  Output examples
    #
    #           "libPusher"
    #           "libPusher (= 1.0)"
    #           "libPusher (~> 1.0.1)"
    #           "libPusher (> 1.0, < 2.0)"
    #           "libPusher (HEAD)"
    #           "libPusher (from `www.example.com')"
    #           "libPusher (defined in Podfile)"
    #           "RestKit/JSON"
    #
    # @return   [String] the representation of the dependency.
    #
    def to_s
      version = ''
      if external?
        version << external_source_description(external_source)
      elsif head?
        version << 'HEAD'
      elsif requirement != Requirement.default
        version << requirement.to_s
      end
      result = @name.dup
      result << " (#{version})" unless version.empty?
      result
    end

    # Generates a dependency from its string representation.
    #
    # @param    [String] string
    #           The string that describes the dependency generated from
    #           {#to_s}.
    #
    # @note     The information about external sources is not completely
    #           serialized in the string representation and should be stored a
    #           part by clients that need to create a dependency equal to the
    #           original one.
    #
    # @return   [Dependency] the dependency described by the string.
    #
    def self.from_string(string)
      match_data = string.match(/(\S*)( (.*))?/)
      name = match_data[1]
      version = match_data[2]
      version = version.gsub(/[()]/, '') if version
      case version
      when nil || /from `(.*)(`|')/
        Dependency.new(name)
      when /HEAD/
        Dependency.new(name, :head)
      else
        version_requirements =  version.split(',') if version
        Dependency.new(name, version_requirements)
      end
    end

    # @return [String] a string representation suitable for debugging.
    #
    def inspect
      "<#{self.class} name=#{name} requirements=#{requirement} " \
        "external_source=#{external_source || 'nil'}>"
    end

    #--------------------------------------#

    private

    # Creates a string representation of the external source suitable for UI.
    #
    # @example  Output examples
    #
    #           "from `www.example.com/libPusher.git', tag `v0.0.1'"
    #           "from `www.example.com/libPusher.podspec'"
    #           "from `~/path/to/libPusher'"
    #
    # @todo     Improve the description for Mercurial and Subversion.
    #
    # @return   [String] the description of the external source.
    #
    def external_source_description(source)
      if source.key?(:git)
        desc =  "`#{source[:git]}`"
        desc << ", commit `#{source[:commit]}`" if source[:commit]
        desc << ", branch `#{source[:branch]}`" if source[:branch]
        desc << ", tag `#{source[:tag]}`"       if source[:tag]
      elsif source.key?(:hg)
        desc =  "`#{source[:hg]}`"
      elsif source.key?(:svn)
        desc =  "`#{source[:svn]}`"
      elsif source.key?(:podspec)
        desc = "`#{source[:podspec]}`"
      elsif source.key?(:path)
        desc = "`#{source[:path]}`"
      elsif source.key?(:local)
        desc = "`#{source[:local]}`"
      else
        desc = "`#{source}`"
      end
      "from #{desc}"
    end
  end
end
