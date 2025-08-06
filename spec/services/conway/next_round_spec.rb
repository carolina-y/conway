RSpec.describe Conway::NextRound do
  describe '#call' do
    let(:board) do
      Conway::CreateBoard.new(state: initial_state).call
    end
    let(:initial_state) { [[2, 1], [2, 2], [2, 3]] }
    let(:next_state) { [[1, 2], [2, 2], [3, 2]] }

    it 'calculates the next round of the board' do
      result_cells = Conway::NextRound.new(board: board).call

      expect(result_cells).to include(*next_state)
    end
  end
end
