
# The CocoaPods namespace
#
module Pod
  class Command
    # The pod try command.
    #
    class Try < Command
      self.summary = 'Try a Pod!'

      self.description = <<-DESC
          Downloads the Pod with the given `NAME` (or Git `URL`), install its
          dependencies if needed and opens its demo project. If a Git URL is
          provided the head of the repo is used.
      DESC

      self.arguments = [CLAide::Argument.new(%w(NAME URL), true)]

      def self.options
        [
          ['--no-repo-update', 'Skip running `pod repo update` before install'],
        ].concat(super)
      end

      def initialize(argv)
        config.skip_repo_update = !argv.flag?('repo-update', !config.skip_repo_update)
        @name = argv.shift_argument
        super
      end

      def validate!
        super
        help! 'A Pod name or URL is required.' unless @name
      end

      def run
        ensure_master_spec_repo_exists!
        sandbox = Sandbox.new(TRY_TMP_DIR)
        if git_url?(@name)
          spec = spec_with_url(@name)
          sandbox.store_pre_downloaded_pod(spec.name)
        else
          update_specs_repos
          spec = spec_with_name(@name)
        end

        UI.title "Trying #{spec.name}" do
          pod_dir = install_pod(spec, sandbox)
          proj = pick_demo_project(pod_dir)
          file = install_podfile(proj)
          if file
            open_project(file)
          else
            UI.puts "Unable to locate a project for #{spec.name}"
          end
        end
      end

      public

      # Helpers
      #-----------------------------------------------------------------------#

      # @return [Pathname]
      #
      TRY_TMP_DIR = Pathname.new('/tmp/CocoaPods/Try')

      # Returns the specification of the last version of the Pod with the given
      # name.
      #
      # @param  [String] name
      #         The name of the pod.
      #
      # @return [Specification] The specification.
      #
      def spec_with_name(name)
        set = SourcesManager.search(Dependency.new(name))
        if set
          set.specification.root
        else
          raise Informative, "Unable to find a specification for `#{name}`"
        end
      end

      # Returns the specification found in the given Git repository URL by
      # downloading the repository.
      #
      # @param  [String] url
      #         The URL for the pod Git repository.
      #
      # @return [Specification] The specification.
      #
      def spec_with_url(url)
        name = url.split('/').last
        name = name.chomp('.git') if name.end_with?('.git')

        target_dir = TRY_TMP_DIR + name
        target_dir.rmtree if target_dir.exist?

        downloader = Pod::Downloader.for_target(target_dir,  :git => url)
        downloader.download

        spec_file = target_dir + "#{name}.podspec"
        Pod::Specification.from_file(spec_file)
      end

      # Installs the specification in the given directory.
      #
      # @param  [Specification] The specification of the Pod.
      # @param  [Pathname] The directory of the sandbox where to install the
      #         Pod.
      #
      # @return [Pathname] The path where the Pod was installed
      #
      def install_pod(spec, sandbox)
        specs = { :ios => spec, :osx => spec }
        installer = Installer::PodSourceInstaller.new(sandbox, specs)
        installer.install!
        sandbox.root + spec.name
      end

      # Picks a project or workspace suitable for the demo purposes in the
      # given directory.
      #
      # To decide the project simple heuristics are used according to the name,
      # if no project is found this method raises and `Informative` otherwise
      # if more than one project is found the choice is presented to the user.
      #
      # @param  [#to_s] dir
      #         The path where to look for projects.
      #
      # @return [String] The path of the project.
      #
      def pick_demo_project(dir)
        projs = projects_in_dir(dir)
        if projs.count == 0
          raise Informative, 'Unable to find any project in the source files' \
            " of the Pod: `#{dir}`"
        elsif projs.count == 1
          projs.first
        elsif (workspaces = projs.grep(/(demo|example|sample).*\.xcworkspace$/i)).count == 1
          workspaces.first
        elsif (projects = projs.grep(/demo|example|sample/i)).count == 1
          projects.first
        else
          message = 'Which project would you like to open'
          selection_array = projs.map do |p|
            Pathname.new(p).relative_path_from(dir).to_s
          end
          index = choose_from_array(selection_array, message)
          projs[index]
        end
      end

      # Performs a CocoaPods installation for the given project if Podfile is
      # found.  Shells out to avoid issues with the config of the process
      # running the try command.
      #
      # @return [String] proj
      #         The path of the project.
      #
      # @return [String] The path of the file to open, in other words the
      #         workspace of the installation or the given project.
      #
      def install_podfile(proj)
        return unless proj
        dirname = Pathname.new(proj).dirname
        podfile_path = dirname + 'Podfile'
        if podfile_path.exist?
          Dir.chdir(dirname) do
            perform_cocoapods_installation

            podfile = Pod::Podfile.from_file(podfile_path)

            if podfile.workspace_path
              File.expand_path(podfile.workspace_path)
            else
              proj.chomp(File.extname(proj.to_s)) + '.xcworkspace'
            end
          end
        else
          proj
        end
      end

      public

      # Private Helpers
      #-----------------------------------------------------------------------#

      # @return [void] Updates the specs repo unless disabled by the config.
      #
      def update_specs_repos
        return if config.skip_repo_update?
        UI.section 'Updating spec repositories' do
          SourcesManager.update
        end
      end

      # Opens the project at the given path.
      #
      # @return [String] path
      #         The path of the project.
      #
      # @return [void]
      #
      def open_project(path)
        UI.puts "Opening '#{path}'"
        `open "#{path}"`
      end

      # Presents a choice among the elements of an array to the user.
      #
      # @param  [Array<#to_s>] array
      #         The list of the elements among which the user should make his
      #         choice.
      #
      # @param  [String] message
      #         The message to display to the user.
      #
      # @return [Fixnum] The index of the chosen array item.
      #
      # @todo   This method was duplicated from the spec subcommands
      #
      def choose_from_array(array, message)
        array.each_with_index do |item, index|
          UI.puts "#{ index + 1 }: #{ item }"
        end
        UI.puts "#{message} [1-#{array.count}]?"
        index = STDIN.gets.chomp.to_i - 1
        if index < 0 || index > array.count
          raise Informative, "#{ index + 1 } is invalid [1-#{array.count}]"
        else
          index
        end
      end

      # @return [void] Performs a CocoaPods installation in the working
      #         directory.
      #
      def perform_cocoapods_installation
        UI.puts `pod install`
      end

      # @return [Bool] Wether the given string is the name of a Pod or an URL
      #         for a Git repo.
      #
      def git_url?(name)
        prefixes = ['https://', 'http://']
        prefixes.any? { |prefix| name.start_with?(prefix) }
      end

      # @return [Array<String>] The list of the workspaces and projects in a
      #         given directory excluding The Pods project and the projects
      #         that have a sister workspace.
      #
      def projects_in_dir(dir)
        glob_match = Dir.glob("#{dir}/**/*.xc{odeproj,workspace}")
        glob_match = glob_match.reject do |p|
          next true if p.include?('Pods.xcodeproj')
          next true if p.end_with?('.xcodeproj/project.xcworkspace')
          sister_workspace = p.chomp(File.extname(p.to_s)) + '.xcworkspace'
          p.end_with?('.xcodeproj') && glob_match.include?(sister_workspace)
        end
      end

      #-------------------------------------------------------------------#
    end
  end
end
