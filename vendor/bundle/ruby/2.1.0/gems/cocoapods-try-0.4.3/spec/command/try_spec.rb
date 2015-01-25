require File.expand_path('../../spec_helper', __FILE__)

# The CocoaPods namespace
#
module Pod
  describe Command::Try do
    describe 'Try' do
      it 'registers it self' do
        Command.parse(%w(try)).should.be.instance_of Command::Try
      end

      it 'presents the help if no name is provided' do
        command = Pod::Command.parse(['try'])
        should.raise CLAide::Help do
          command.validate!
        end.message.should.match(/A Pod name or URL is required/)
      end

      it 'allows the user to try the Pod with the given name' do
        Config.instance.skip_repo_update = false
        command = Pod::Command.parse(%w(try ARAnalytics))
        Installer::PodSourceInstaller.any_instance.expects(:install!)
        command.expects(:update_specs_repos)
        command.expects(:pick_demo_project).returns('/tmp/Proj.xcodeproj')
        command.expects(:open_project).with('/tmp/Proj.xcodeproj')
        command.run
      end

      it 'allows the user to try the Pod with the given Git URL' do
        require 'cocoapods-downloader/git'
        Pod::Downloader::Git.any_instance.expects(:download)
        spec_file = '/tmp/CocoaPods/Try/ARAnalytics/ARAnalytics.podspec'
        stub_spec = stub(:name => 'ARAnalytics')
        Pod::Specification.stubs(:from_file).with(Pathname(spec_file)).returns(stub_spec)

        Config.instance.skip_repo_update = false
        command = Pod::Command.parse(['try', 'https://github.com/orta/ARAnalytics.git'])
        Installer::PodSourceInstaller.any_instance.expects(:install!)
        command.expects(:update_specs_repos).never
        command.expects(:pick_demo_project).returns('/tmp/Proj.xcodeproj')
        command.expects(:open_project).with('/tmp/Proj.xcodeproj')
        command.run
      end
    end

    describe 'Helpers' do
      before do
        @sut = Pod::Command.parse(['try'])
      end

      it 'returns the spec with the given name' do
        spec = @sut.spec_with_name('ARAnalytics')
        spec.name.should == 'ARAnalytics'
      end

      describe '#spec_at_url' do
        it 'returns a spec for an https git repo' do
          require 'cocoapods-downloader/git'
          Pod::Downloader::Git.any_instance.expects(:download)
          spec_file = '/tmp/CocoaPods/Try/ARAnalytics/ARAnalytics.podspec'
          stub_spec = stub
          Pod::Specification.stubs(:from_file).with(Pathname(spec_file)).returns(stub_spec)
          spec = @sut.spec_with_url('https://github.com/orta/ARAnalytics.git')
          spec.should == stub_spec
        end
      end

      it 'installs the pod' do
        Installer::PodSourceInstaller.any_instance.expects(:install!)
        spec = stub(:name => 'ARAnalytics')
        sandbox_root = Pathname.new('/tmp/CocoaPods/Try')
        sandbox = Sandbox.new(sandbox_root)
        path = @sut.install_pod(spec, sandbox)
        path.should == sandbox.root + 'ARAnalytics'
      end

      describe '#pick_demo_project' do
        it 'raises if no demo project could be found' do
          projects = []
          Dir.stubs(:glob).returns(projects)
          should.raise Informative do
            @sut.pick_demo_project(stub)
          end.message.should.match(/Unable to find any project/)
        end

        it 'picks a demo project' do
          projects = ['Demo.xcodeproj']
          Dir.stubs(:glob).returns(projects)
          path = @sut.pick_demo_project(stub)
          path.should == 'Demo.xcodeproj'
        end

        it 'is not case sensitive' do
          projects = ['demo.xcodeproj']
          Dir.stubs(:glob).returns(projects)
          path = @sut.pick_demo_project(stub)
          path.should == 'demo.xcodeproj'
        end

        it 'considers also projects named example' do
          projects = ['Example.xcodeproj']
          Dir.stubs(:glob).returns(projects)
          path = @sut.pick_demo_project(stub)
          path.should == 'Example.xcodeproj'
        end

        it 'returns the project if only one is found' do
          projects = ['Lib.xcodeproj']
          Dir.stubs(:glob).returns(projects)
          path = @sut.pick_demo_project(stub)
          path.should == 'Lib.xcodeproj'
        end

        it 'asks the user which project would like to open if not a single suitable one is found' do
          projects = ['Lib_1.xcodeproj', 'Lib_2.xcodeproj']
          Dir.stubs(:glob).returns(projects)
          @sut.stubs(:choose_from_array).returns(0)
          path = @sut.pick_demo_project(stub(:cleanpath => ''))
          path.should == 'Lib_1.xcodeproj'
        end

        it 'should prefer demo or example workspaces' do
          Dir.stubs(:glob).returns(['Project Demo.xcodeproj', 'Project Demo.xcworkspace'])
          path = @sut.pick_demo_project(stub(:cleanpath => ''))
          path.should == 'Project Demo.xcworkspace'
        end

        it 'should not show workspaces inside a project' do
          Dir.stubs(:glob).returns(['Project Demo.xcodeproj', 'Project Demo.xcodeproj/project.xcworkspace'])
          path = @sut.pick_demo_project(stub(:cleanpath => ''))
          path.should == 'Project Demo.xcodeproj'
        end

        it 'should prefer workspaces over projects with the same name' do
          Dir.stubs(:glob).returns(['Project Demo.xcodeproj', 'Project Demo.xcworkspace'])
          path = @sut.pick_demo_project(stub(:cleanpath => ''))
          path.should == 'Project Demo.xcworkspace'
        end
      end

      describe '#install_podfile' do
        it 'returns the original project if no Podfile could be found' do
          Pathname.any_instance.stubs(:exist?).returns(false)
          proj = '/tmp/Project.xcodeproj'
          path = @sut.install_podfile(proj)
          path.should == proj
        end

        it 'performs an installation and returns the path of the workspace' do
          Pathname.any_instance.stubs(:exist?).returns(true)
          proj = '/tmp/Project.xcodeproj'
          @sut.expects(:perform_cocoapods_installation)
          Podfile.stubs(:from_file).returns(stub(:workspace_path => '/tmp/Project.xcworkspace'))
          path = @sut.install_podfile(proj)
          path.should == '/tmp/Project.xcworkspace'
        end

        it 'returns the default workspace if one is not set' do
          Pathname.any_instance.stubs(:exist?).returns(true)
          proj = '/tmp/Project.xcodeproj'
          Podfile.stubs(:from_file).returns(stub(:workspace_path => nil))
          path = @sut.install_podfile(proj)
          path.should == '/tmp/Project.xcworkspace'
        end
      end
    end
  end
end
