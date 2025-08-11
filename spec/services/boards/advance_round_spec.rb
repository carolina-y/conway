RSpec.describe Boards::AdvanceRound do
  describe '#call' do
    let(:params) do
      {
        board: board
      }
    end
    let(:board) { create(:board, :infinite_loop) }
    let(:next_state) { [[2, 1], [2, 2], [2, 3]] }

    it 'calculates the next round of the board' do
      expect(service_result).to include(*next_state)
    end
  end
end
