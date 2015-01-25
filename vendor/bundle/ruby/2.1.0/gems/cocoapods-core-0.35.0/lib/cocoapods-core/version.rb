module Pod
  # The Version class stores information about the version of a
  # {Specification}.
  #
  # It is based on the RubyGems class adapted to support head information.
  #
  # ### From RubyGems:
  #
  # The Version class processes string versions into comparable
  # values. A version string should normally be a series of numbers
  # separated by periods. Each part (digits separated by periods) is
  # considered its own number, and these are used for sorting. So for
  # instance, 3.10 sorts higher than 3.2 because ten is greater than
  # two.
  #
  # If any part contains letters (currently only a-z are supported) then
  # that version is considered prerelease. Versions with a prerelease
  # part in the Nth part sort less than versions with N-1
  # parts. Prerelease parts are sorted alphabetically using the normal
  # Ruby string sorting rules. If a prerelease part contains both
  # letters and numbers, it will be broken into multiple parts to
  # provide expected sort behavior (1.0.a10 becomes 1.0.a.10, and is
  # greater than 1.0.a9).
  #
  # Prereleases sort between real releases (newest to oldest):
  #
  # 1. 1.0
  # 2. 1.0.b1
  # 3. 1.0.a.2
  # 4. 0.9
  #
  class Version < Pod::Vendor::Gem::Version
    # Override the constants defined by the superclass to add Semantic
    # Versioning prerelease support (with a dash). E.g.: 1.0.0-alpha1
    #
    # For more info, see: http://semver.org
    #
    VERSION_PATTERN = '[0-9]+(\.[0-9a-zA-Z\-]+)*'
    ANCHORED_VERSION_PATTERN = /\A\s*(#{VERSION_PATTERN})*\s*\z/

    # @return [Bool] whether the version represents the `head` of repository.
    #
    attr_accessor :head
    alias_method :head?, :head

    # @param  [String,Version] version
    #         A string representing a version, or another version.
    #
    # @todo   The `from` part of the regular expression should be remove in
    #         CocoaPods 1.0.0.
    #
    def initialize(version)
      if version.is_a?(Version) && version.head?
        version = version.version
        @head = true
      elsif version.is_a?(String) && version =~ /HEAD (based on|from) (.*)/
        version = Regexp.last_match[2]
        @head = true
      end
      super(version)
    end

    # An instance that represents version 0.
    #
    ZERO = new('0')

    # @return [String] a string representation that indicates if the version is
    #         head.
    #
    # @note   The raw version string is still accessible with the {#version}
    #         method.
    #
    # @todo   Adding the head information to the string representation creates
    #         issues (see Dependency#requirement).
    #
    def to_s
      head? ? "HEAD based on #{super}" : super
    end

    # @return [String] a string representation suitable for debugging.
    #
    def inspect
      "<#{self.class} version=#{version}>"
    end

    # @return [Boolean] indicates whether or not the version is a prerelease.
    #
    # @note   Prerelease Pods can contain a hyphen and/or a letter (conforms to
    #         Semantic Versioning instead of RubyGems).
    #
    #         For more info, see: http://semver.org
    #
    def prerelease?
      @prerelease ||= @version =~ /[a-zA-Z\-]/
    end

    # @return [Bool] Whether a string representation is correct.
    #
    def self.correct?(version)
      version.to_s =~ ANCHORED_VERSION_PATTERN
    end

    #-------------------------------------------------------------------------#

    # @!group Semantic Versioning

    SEMVER_PATTERN = '[0-9]+(\.[0-9]+(\.[0-9]+(-[0-9A-Za-z\-\.]+)?)?)?'
    ANCHORED_SEMANTIC_VERSION_PATTERN = /\A\s*(#{SEMVER_PATTERN})*\s*\z/

    # @return [Bool] Whether the version conforms to the Semantic Versioning
    #         specification (2.0.0-rc.1).
    #
    # @note   This comparison is lenient.
    #
    # @note   It doesn't support build identifiers.
    #
    def semantic?
      version.to_s =~ ANCHORED_SEMANTIC_VERSION_PATTERN
    end

    # @return [Fixnum] The semver major identifier.
    #
    def major
      segments[0]
    end

    # @return [Fixnum] The semver minor identifier.
    #
    def minor
      segments[1] || 0
    end

    # @return [Fixnum] The semver patch identifier.
    #
    def patch
      segments[2] || 0
    end

    #-------------------------------------------------------------------------#
  end
end
