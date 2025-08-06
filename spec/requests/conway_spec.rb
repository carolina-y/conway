RSpec.describe "Conway's Game of Life", type: :request do
  describe 'POST /boards' do
    describe 'with valid state' do
      let(:state) { [[1, 2], [2, 2], [3, 2]] }

      it 'creates the board and returns the board ID' do
        post boards_path, params: { state: state }.to_json, headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:success)
        expect(json_response['id']).to be_a(Integer)
      end
    end

    describe 'with an invalid state' do
      let(:invalid_state) { [[1, 2], ['invalid', 2], [3, 2]] }

      it 'returns an error when the state is invalid' do
        post boards_path, params: { state: invalid_state }.to_json, headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Cell coordinates must be integers')
      end
    end
  end

  describe 'POST /boards/:id/next_round' do
    let!(:board) { Conway::CreateBoard.new(state: [[1, 2], [2, 2], [3, 2]]).call }

    it 'progresses the board to the next round' do
      post next_round_board_path(board)

      expect(json_response['state']).to include([2, 1], [2, 2], [2, 3])
      expect(board.reload.board_cells.map do |cell| [cell.x, cell.y] end).to include([2, 1], [2, 2], [2, 3])
      expect(response).to have_http_status(:success)
    end
  end
end
