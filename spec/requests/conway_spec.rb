require 'rails_helper'

RSpec.describe "Conway's Game of Life", type: :request do
  def sort_state(state)
    state.sort_by { |cell| [cell[0], cell[1]] }
  end

  describe 'Idempotency key' do
    let(:params) do
      {
        state: state,
        width: 50,
        height: 50
      }
    end
    context 'with an invalid idempotency key' do
      let(:state) { [[1, 2], [2, 2], [3, 2]] }
      let(:idempotency_key) { '0' * 101 }

      it 'errors with unprocessable content' do
        post boards_path, params: params.to_json, headers: { 'Idempotency-Key' => idempotency_key, 'Content-Type': 'application/json' }

        expect(response).to have_http_status(:unprocessable_content)
        expect(Board.count).to eq(0)
      end
    end
  end

  describe 'POST /boards' do
    let(:params) do
      {
        state: state,
        width: width,
        height: height
      }
    end
    let(:width) { 50 }
    let(:height) { 50 }

    context 'with an idempotency key' do
      let(:state) { [[1, 2], [2, 2], [3, 2]] }
      let(:idempotency_key) { SecureRandom.uuid }

      it 'creates the board and returns a new board ID' do
        post boards_path, params: params.to_json, headers: { 'Idempotency-Key' => idempotency_key, 'Content-Type': 'application/json' }

        expect(response).to have_http_status(:created)
        expect(json_response['id']).to be_a(Integer)
        expect(Board.count).to eq(1)
      end
    end

    context 'with an idempotency key, querying twice' do
      let(:state) { [[1, 2], [2, 2], [3, 2]] }
      let(:idempotency_key) { SecureRandom.uuid }

      it 'creates the board and returns a new board ID' do
        post boards_path, params: params.to_json, headers: { 'Idempotency-Key' => idempotency_key, 'Content-Type': 'application/json' }
        post boards_path, params: params.to_json, headers: { 'Idempotency-Key' => idempotency_key, 'Content-Type': 'application/json' }

        expect(response).to have_http_status(:created)
        expect(json_response['id']).to be_a(Integer)
        expect(Board.count).to eq(1)
      end
    end

    context 'with valid state' do
      let(:state) { [[1, 2], [2, 2], [3, 2]] }

      it 'creates the board and returns the board ID' do
        post boards_path, params: params.to_json, headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:success)
        expect(json_response['id']).to be_a(Integer)
      end
    end

    context 'with an invalid state' do
      let(:state) { [[1, 2], ['invalid', 2], [3, 2]] }

      it 'returns an error when the state is invalid' do
        post boards_path, params: params.to_json, headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['error']).to eq('Cell coordinates must be integers')
      end
    end

    context 'with a state comprised of non-unique arrays' do
      let(:state) { [[1, 2], [1, 2], [2, 2]] }

      it 'returns an error when the state is invalid' do
        post boards_path, params: params.to_json, headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['error']).to eq('State must be an array of unique arrays')
      end
    end
  end

  describe 'POST /boards/:id/next_round' do
    context 'with a valid board' do
      let(:board) { create(:board, :infinite_loop) }

      it 'progresses the board to the next round' do
        post next_round_board_path(board)

        expect(sort_state(json_response['state'])).to eq(sort_state([[2, 1], [2, 2], [2, 3]]))
        expect(board.reload.board_cells.map do |cell| [cell.x, cell.y] end).to include([2, 1], [2, 2], [2, 3])
        expect(response).to have_http_status(:success)
      end
    end

    context 'when trying to advance an invalid board'do
      it 'returns a 404 error' do
        post next_round_board_path(id: 9999)

        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to include(/Couldn't find Board with 'id'=/)
      end
    end

    context 'when the board is empty' do
      let(:board) { create(:board) }

      it 'still returns an empty state' do
        post next_round_board_path(board)

        expect(json_response['state']).to eq([])
        expect(response).to have_http_status(:success)
      end
    end

    context 'with only one element' do
      let(:board) { create(:board, :with_single_element) }

      it 'returns an empty state' do
        post next_round_board_path(board)

        expect(json_response['state']).to eq([])
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST /boards/:id/progress' do
    let!(:board) { create(:board, :finishable) }

    it 'finalizes the board' do
      post progress_board_path(board)

      expect(response).to have_http_status(:success)
      expect(json_response['state']).to eq([])
    end

    context 'when the board is not concluded' do
      let!(:board) { create(:board, :infinite_loop) }

      it 'returns an error' do
        post progress_board_path(board)

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['error']).to eq("Board is not concluded after #{Board::MAX_ROUNDS} rounds")
      end
    end

    context 'when the board can be concluded' do
      let!(:board) { create(:board, :with_square) }

      it 'finalizes the board successfully' do
        post progress_board_path(board)

        expect(response).to have_http_status(:success)
        expect(sort_state(json_response['state'])).to eq(sort_state([[1, 1], [1, 2], [2, 1], [2, 2]]))
      end
    end
  end

  describe 'GET /boards/:id/remaining_states' do
    context 'with a board that cannot be concluded' do
      let(:board) { create(:board, :infinite_loop) }

      it 'returns the remaining rounds count' do
        get remaining_rounds_board_path(board)

        expect(response).to have_http_status(:success)
        expect(json_response['remaining_rounds']).to eq(-1)
      end
    end

    context 'with a board that can be concluded' do
      let(:board) { create(:board, :with_square) }

      it 'returns the remaining rounds count' do
        get remaining_rounds_board_path(board)

        expect(response).to have_http_status(:success)
        expect(json_response['remaining_rounds']).to eq(0)
      end
    end
  end
end
