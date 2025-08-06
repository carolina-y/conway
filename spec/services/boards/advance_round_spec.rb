RSpec.describe Boards::AdvanceRound do
  describe '#call' do
    let(:params) do
      {
        board: board
      }
    end
    let(:board) do
      Boards::Create.new(state: initial_state).call
    end
    let(:initial_state) { [[2, 1], [2, 2], [2, 3]] }
    let(:next_state) { [[1, 2], [2, 2], [3, 2]] }

    it 'calculates the next round of the board' do
      expect(service_result).to include(*next_state)
    end
  end
end
