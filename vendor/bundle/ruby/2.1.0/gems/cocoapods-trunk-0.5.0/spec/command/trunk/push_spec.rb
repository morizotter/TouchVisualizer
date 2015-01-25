require File.expand_path('../../../spec_helper', __FILE__)
require 'tmpdir'

module Pod
  describe Command::Trunk::Push do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w(        trunk push        )).should.be.instance_of Command::Trunk::Push
      end
    end

    it "should error if we don't have a token" do
      Netrc.any_instance.stubs(:[]).returns(nil)
      command = Command.parse(%w( trunk push ))
      exception = lambda { command.validate! }.should.raise CLAide::Help
      exception.message.should.include 'register a session'
    end

    describe 'PATH' do
      before do
        UI.output = ''
      end
      it 'defaults to the current directory' do
        # Disable the podspec finding algorithm so we can check the raw path
        Command::Trunk::Push.any_instance.stubs(:find_podspec_file) { |path| path }
        command = Command.parse(%w(        trunk push        ))
        command.instance_eval { @path }.should == '.'
      end

      def found_podspec_among_files(files)
        # Create a temp directory with the dummy `files` in it
        Dir.mktmpdir do |dir|
          files.each do |filename|
            path = Pathname(dir) + filename
            File.open(path, 'w') {}
          end
          # Execute `pod trunk push` with this dir as parameter
          command = Command.parse(%w(          trunk push          ) + [dir])
          path = command.instance_eval { @path }
          return File.basename(path) if path
        end
      end

      it 'should find the only JSON podspec in a given directory' do
        files = %w(foo bar.podspec.json baz)
        found_podspec_among_files(files).should == files[1]
      end

      it 'should find the only Ruby podspec in a given directory' do
        files = %w(foo bar.podspec baz)
        found_podspec_among_files(files).should == files[1]
      end

      it 'should warn when no podspec found in a given directory' do
        files = %w(foo bar baz)
        found_podspec_among_files(files).should.nil?
        UI.output.should.match /No podspec found in directory/
      end

      it 'should warn when multiple podspecs found in a given directory' do
        files = %w(foo bar.podspec bar.podspec.json baz)
        found_podspec_among_files(files).should.nil?
        UI.output.should.match /Multiple podspec files in directory/
      end
    end
  end
end
