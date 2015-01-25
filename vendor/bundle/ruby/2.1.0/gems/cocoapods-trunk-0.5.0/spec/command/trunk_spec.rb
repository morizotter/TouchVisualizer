require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Trunk do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w(        trunk        )).should.be.instance_of Command::Trunk
      end
    end
  end
end
