module Pod
  class Podfile
    # The of the methods defined in this file and the order of the methods is
    # relevant for the documentation generated on
    # CocoaPods/cocoapods.github.com.

    # The Podfile is a specification that describes the dependencies of the
    # targets of one or more Xcode projects. The Podfile always creates an
    # implicit target, named `default`, which links to the first target of the
    # user project.
    #
    # A podfile can be very simple:
    #
    #     source 'https://github.com/CocoaPods/Specs.git'
    #     pod 'AFNetworking', '~> 1.0'
    #
    # An example of a more complex podfile can be:
    #
    #     source 'https://github.com/CocoaPods/Specs.git'
    #
    #     platform :ios, '6.0'
    #     inhibit_all_warnings!
    #
    #     xcodeproj 'MyProject'
    #
    #     pod 'ObjectiveSugar', '~> 0.5'
    #
    #     target :test do
    #       pod 'OCMock', '~> 2.0.1'
    #     end
    #
    #     post_install do |installer|
    #       installer.project.targets.each do |target|
    #         puts "#{target.name}"
    #       end
    #     end
    #
    module DSL
      # @!group Dependencies
      #   The Podfile specifies the dependencies of each user target.
      #
      #   * `pod` is the way to declare a specific dependency.
      #   * `podspec` provides an easy API for the creation of podspecs.
      #   * `target` allows you to scope your dependencies to specific
      #   targets in your Xcode projects.

      #-----------------------------------------------------------------------#

      # Specifies a dependency of the project.
      #
      # A dependency requirement is defined by the name of the Pod and
      # optionally a list of version requirements.
      #
      # When starting out with a project it is likely that you will want to use
      # the latest version of a Pod. If this is the case, simply omit the
      # version requirements.
      #
      #     pod 'SSZipArchive'
      #
      # Later on in the project you may want to freeze to a specific version of
      # a Pod, in which case you can specify that version number.
      #
      #     pod 'Objection', '0.9'
      #
      # Besides no version, or a specific one, it is also possible to use
      # operators:
      #
      # * `> 0.1`    Any version higher than 0.1.
      # * `>= 0.1`   Version 0.1 and any higher version.
      # * `< 0.1`    Any version lower than 0.1.
      # * `<= 0.1`   Version 0.1 and any lower version.
      # * `~> 0.1.2` Version 0.1.2 and the versions up to 0.2, not including 0.2.
      #              This operator works based on _the last component_ that you
      #              specify in your version requirement. The example is equal to
      #              `>= 0.1.2` combined with `< 0.2.0` and will always match the
      #              latest known version matching your requirements.
      #
      # A list of version requirements can be specified for even more fine
      # grained control.
      #
      # For more information, regarding versioning policy, see:
      #
      # * [Semantic Versioning](http://semver.org)
      # * [RubyGems Versioning Policies](http://docs.rubygems.org/read/chapter/7)
      #
      # Finally, instead of a version, you can specify the `:head` flag. This
      # will use the spec of the newest available version in your spec repo(s),
      # but force the download of the ‘bleeding edge’ version (HEAD). Use this
      # with caution, as the spec _might_ not be compatible anymore.
      #
      #     pod 'Objection', :head
      #
      # ------
      #
      # ### Build configurations
      #
      # *IMPORTANT*: the following syntax is tentative and might change without
      # notice in future. This feature is released in this state due to
      # the strong demand for it. You can use it but you might need to change
      # your Podfile to use future versions of CocoaPods. Anyway a clear and
      # simple upgrade path will be provided.
      #
      # By default dependencies are installed on all the build configurations
      # of the target. For debug purposes or for other reasons, they can be
      # enabled only on a given list of build configuration names.
      #
      #     pod 'PonyDebugger', :configurations => ['Release', 'App Store']
      #
      # Alternatively you can white-list only a single build configuration.
      #
      #     pod 'PonyDebugger', :configuration => ['Release']
      #
      # ------
      #
      # Dependencies can be obtained also from external sources.
      #
      #
      # ### Using the files from a local path.
      #
      #  If you wold like to use develop a Pod in tandem with its client
      #  project you can use the `path` option.
      #
      #     pod 'AFNetworking', :path => '~/Documents/AFNetworking'
      #
      #  Using this option CocoaPods will assume the given folder to be the
      #  root of the Pod and will link the files directly from there in the
      #  Pods project. This means that your edits will persist to CocoaPods
      #  installations.
      #
      #  The referenced folder can be a checkout of your your favorite SCM or
      #  even a git submodule of the current repo.
      #
      #  Note that the `podspec` of the Pod file is expected to be in the
      #  folder.
      #
      #
      # ### From a podspec in the root of a library repo.
      #
      # Sometimes you may want to use the bleeding edge version of a Pod. Or a
      # specific revision. If this is the case, you can specify that with your
      # pod declaration.
      #
      # To use the `master` branch of the repo:
      #
      #     pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git'
      #
      #
      # To use a different branch of the repo:
      #
      #     pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git', :branch => 'dev'
      #
      #
      # To use a tag of the repo:
      #
      #     pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git', :tag => '0.7.0'
      #
      #
      # Or specify a commit:
      #
      #     pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git', :commit => '082f8319af'
      #
      # It is important to note, though, that this means that the version will
      # have to satisfy any other dependencies on the Pod by other Pods.
      #
      # The `podspec` file is expected to be in the root of the repo, if this
      # library does not have a `podspec` file in its repo yet, you will have
      # to use one of the approaches outlined in the sections below.
      #
      #
      # ### From a podspec outside a spec repo, for a library without podspec.
      #
      # If a podspec is available from another source outside of the library’s
      # repo. Consider, for instance, a podspec available via HTTP:
      #
      #     pod 'JSONKit', :podspec => 'https://example.com/JSONKit.podspec'
      #
      #
      # @note       This method allow a nil name and the raises to be more
      #             informative.
      #
      # @note       Support for inline podspecs has been deprecated.
      #
      # @return     [void]
      #
      def pod(name = nil, *requirements, &block)
        if block
          raise StandardError, 'Inline specifications are deprecated. ' \
            'Please store the specification in a `podspec` file.'
        end

        unless name
          raise StandardError, 'A dependency requires a name.'
        end

        current_target_definition.store_pod(name, *requirements)
      end

      # Use the dependencies of a Pod defined in the given podspec file. If no
      # arguments are passed the first podspec in the root of the Podfile is
      # used. It is intended to be used by the project of a library. Note:
      # this does not include the sources derived from the podspec just the
      # CocoaPods infrastructure.
      #
      # @example
      #   podspec
      #
      # @example
      #   podspec :name => 'QuickDialog'
      #
      # @example
      #   podspec :path => '/Documents/PrettyKit/PrettyKit.podspec'
      #
      # @param    [Hash {Symbol=>String}] options
      #           the path where to load the {Specification}. If not provided
      #           the first podspec in the directory of the podfile is used.
      #
      # @option   options [String] :path
      #           the path of the podspec file
      #
      # @option   options [String] :name
      #           the name of the podspec
      #
      # @note     This method uses the dependencies declared by the for the
      #           platform of the target definition.
      #
      #
      # @note     This method requires that the Podfile has a non nil value for
      #           {#defined_in_file} unless the path option is used.
      #
      # @return   [void]
      #
      def podspec(options = nil)
        current_target_definition.store_podspec(options)
      end

      # Defines a new static library target and scopes dependencies defined
      # from the given block. The target will by default include the
      # dependencies defined outside of the block, unless the `:exclusive =>
      # true` option is
      # given.
      #
      # ---
      #
      # The Podfile creates a global target named `:default` which produces the
      # `libPods.a` file. This target is linked with the first target of user
      # project if not value is specified for the `link_with` attribute.
      #
      # @param    [Symbol, String] name
      #           the name of the target definition.
      #
      # @option   options [Bool] :exclusive
      #           whether the target should inherit the dependencies of its
      #           parent. by default targets are inclusive.
      #
      # @example  Defining a target
      #
      #           target :ZipApp do
      #             pod 'SSZipArchive'
      #           end
      #
      # @example  Defining an exclusive target
      #
      #           target :ZipApp do
      #             pod 'SSZipArchive'
      #             target :test, :exclusive => true do
      #               pod 'JSONKit'
      #             end
      #           end
      #
      # @return   [void]
      #
      def target(name, options = {})
        if options && !options.keys.all? { |key| [:exclusive].include?(key) }
          raise Informative, "Unsupported options `#{options}` for " \
            "target `#{name}`"
        end

        parent = current_target_definition
        definition = TargetDefinition.new(name, parent)
        definition.exclusive = true if options[:exclusive]
        self.current_target_definition = definition
        yield
      ensure
        self.current_target_definition = parent
      end

      #-----------------------------------------------------------------------#

      # @!group Target configuration
      #   These settings are used to control the  CocoaPods generated project.
      #
      #   This starts out simply with stating what `platform` you are working
      #   on. `xcodeproj` allows you to state specifically which project to
      #   link with.

      #-----------------------------------------------------------------------#

      # Specifies the platform for which a static library should be build.
      #
      # CocoaPods provides a default deployment target if one is not specified.
      # The current default values are `4.3` for iOS and `10.6` for OS X.
      #
      # If the deployment target requires it (iOS < `4.3`), `armv6`
      # architecture will be added to `ARCHS`.
      #
      # @param    [Symbol] name
      #           the name of platform, can be either `:osx` for OS X or `:ios`
      #           for iOS.
      #
      # @param    [String, Version] target
      #           The optional deployment.  If not provided a default value
      #           according to the platform name will be assigned.
      #
      # @example  Specifying the platform
      #
      #           platform :ios, "4.0"
      #           platform :ios
      #
      # @return   [void]
      #
      def platform(name, target = nil)
        # Support for deprecated options parameter
        target = target[:deployment_target] if target.is_a?(Hash)
        current_target_definition.set_platform(name, target)
      end

      # Specifies the Xcode project that contains the target that the Pods
      # library should be linked with.
      #
      # -----
      #
      # If no explicit project is specified, it will use the Xcode project of
      # the parent target. If none of the target definitions specify an
      # explicit project and there is only **one** project in the same
      # directory as the Podfile then that project will be used.
      #
      # It is possible also to specify whether the build settings of your
      # custom build configurations should be modeled after the release or
      # the debug presets. To do so you need to specify a hash where the name
      # of each build configuration is associated to either `:release` or
      # `:debug`.
      #
      # @param    [String] path
      #           the path of the project to link with
      #
      # @param    [Hash{String => symbol}] build_configurations
      #           a hash where the keys are the name of the build
      #           configurations in your Xcode project and the values are
      #           Symbols that specify if the configuration should be based on
      #           the `:debug` or `:release` configuration. If no explicit
      #           mapping is specified for a configuration in your project, it
      #           will default to `:release`.
      #
      # @example  Specifying the user project
      #
      #           # Look for target to link with in an Xcode project called
      #           # `MyProject.xcodeproj`.
      #           xcodeproj 'MyProject'
      #
      #           target :test do
      #             # This Pods library links with a target in another project.
      #             xcodeproj 'TestProject'
      #           end
      #
      # @example  Using custom build configurations
      #
      #           xcodeproj 'TestProject', 'Mac App Store' => :release, 'Test' => :debug
      #
      #
      # @return   [void]
      #
      def xcodeproj(path, build_configurations = {})
        current_target_definition.user_project_path = path
        current_target_definition.build_configurations = build_configurations
      end

      # Specifies the target(s) in the user’s project that this Pods library
      # should be linked in.
      #
      # -----
      #
      # If no explicit target is specified, then the Pods target will be linked
      # with the first target in your project. So if you only have one target
      # you do not need to specify the target to link with.
      #
      # @param    [String, Array<String>] targets
      #           the target or the targets to link with.
      #
      # @example  Link with a user project target
      #
      #           link_with 'MyApp'
      #
      # @example  Link with multiple user project targets
      #
      #           link_with 'MyApp', 'MyOtherApp'
      #
      # @return   [void]
      #
      def link_with(*targets)
        current_target_definition.link_with = targets.flatten
      end

      # Inhibits **all** the warnings from the CocoaPods libraries.
      #
      # ------
      #
      # This attribute is inherited by child target definitions.
      #
      # If you would like to inhibit warnings per Pod you can use the
      # following syntax:
      #
      #     pod 'SSZipArchive', :inhibit_warnings => true
      #
      def inhibit_all_warnings!
        current_target_definition.inhibit_all_warnings = true
      end

      #-----------------------------------------------------------------------#

      # @!group Workspace
      #
      #   This group list the options to configure workspace and to set global
      #   settings.

      #-----------------------------------------------------------------------#

      # Specifies the Xcode workspace that should contain all the projects.
      #
      # -----
      #
      # If no explicit Xcode workspace is specified and only **one** project
      # exists in the same directory as the Podfile, then the name of that
      # project is used as the workspace’s name.
      #
      # @param    [String] path
      #           path of the workspace.
      #
      # @example  Specifying a workspace
      #
      #           workspace 'MyWorkspace'
      #
      # @return   [void]
      #
      def workspace(path)
        set_hash_value('workspace', path.to_s)
      end

      # Specifies that a BridgeSupport metadata document should be generated
      # from the headers of all installed Pods.
      #
      # -----
      #
      # This is for scripting languages such as [MacRuby](http://macruby.org),
      # [Nu](http://programming.nu/index), and
      # [JSCocoa](http://inexdo.com/JSCocoa), which use it to bridge types,
      # functions, etc.
      #
      # @return   [void]
      #
      def generate_bridge_support!
        set_hash_value('generate_bridge_support', true)
      end

      # Specifies that the -fobjc-arc flag should be added to the
      # `OTHER_LD_FLAGS`.
      #
      # -----
      #
      # This is used as a workaround for a compiler bug with non-ARC projects
      # (see #142). This was originally done automatically but libtool as of
      # Xcode 4.3.2 no longer seems to support the `-fobjc-arc` flag. Therefore
      # it now has to be enabled explicitly using this method.
      #
      # Support for this method might be dropped in CocoaPods `1.0`.
      #
      # @return   [void]
      #
      def set_arc_compatibility_flag!
        set_hash_value('set_arc_compatibility_flag', true)
      end

      #-----------------------------------------------------------------------#

      # @!group Sources
      #
      #   The Podfile retrieves specs from a given list of sources (repos).
      #
      #   Sources are __global__ and they are not stored per target definition.

      #-----------------------------------------------------------------------#

      # Specifies the location of specs
      #
      # -----
      #
      # Use this method to specify sources. The order of the sources is
      # relevant. CocoaPods will use the highest version of a Pod of the first
      # source which includes the Pod (regardless whether other sources have a
      # higher version).
      #
      # @param    [String] source
      #           The URL of a specs repo.
      #
      # @example  Specifying to first use the artsy repo and then the
      #           CocoaPods Master Repo
      #
      #           source 'https://github.com/artsy/Specs.git'
      #           source 'https://github.com/CocoaPods/Specs.git'
      #
      # @return   [void]
      #
      def source(source)
        hash_sources = get_hash_value('sources') || []
        hash_sources << source
        set_hash_value('sources', hash_sources.uniq)
      end

      #-----------------------------------------------------------------------#

      # @!group Hooks
      #   The Podfile provides hooks that will be called during the
      #   installation process.
      #
      #   Hooks are __global__ and not stored per target definition.

      #-----------------------------------------------------------------------#

      # This hook allows you to make any changes to the Pods after they have
      # been downloaded but before they are installed.
      #
      # It receives the
      # [`Pod::Hooks::InstallerRepresentation`](http://rubydoc.info/gems/cocoapods/Pod/Hooks/InstallerRepresentation/)
      # as its only argument.
      #
      # @example  Defining a pre install hook in a Podfile.
      #
      #   pre_install do |installer_representation|
      #     # Do something fancy!
      #   end
      #
      #
      def pre_install(&block)
        @pre_install_callback = block
      end

      # This hook allows you to make any last changes to the generated Xcode
      # project before it is written to disk, or any other tasks you might want
      # to perform.
      #
      # It receives the
      # [`Pod::Hooks::InstallerRepresentation`](http://rubydoc.info/gems/cocoapods/Pod/Hooks/InstallerRepresentation/)
      # as its only argument.
      #
      # @example  Customizing the `OTHER_LDFLAGS` of all targets
      #
      #   post_install do |installer_representation|
      #     installer_representation.project.targets.each do |target|
      #       target.build_configurations.each do |config|
      #         config.build_settings['GCC_ENABLE_OBJC_GC'] = 'supported'
      #       end
      #     end
      #   end
      #
      # @return   [void]
      #
      def post_install(&block)
        @post_install_callback = block
      end
    end
  end
end
