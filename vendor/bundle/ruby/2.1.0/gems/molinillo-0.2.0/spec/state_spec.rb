require File.expand_path('../spec_helper', __FILE__)

module Molinillo
  describe ResolutionState do
    describe DependencyState do
      before do
        @state = DependencyState.new(
          'name',
          %w(requirement1 requirement2 requirement3),
          DependencyGraph.new,
          'requirement',
          %w(possibility1 possibility),
          0,
          {}
        )
      end

      it 'pops a possibility state' do
        possibility_state = @state.pop_possibility_state
        %w(name requirements activated requirement conflicts).each do |attr|
          possibility_state.send(attr).
            should.equal @state.send(attr)
        end
        possibility_state.is_a?(PossibilityState).
          should.be.true?
        possibility_state.depth.
          should.equal @state.depth + 1
        possibility_state.possibilities.
          should.equal %w(possibility)
      end
    end
  end
end
