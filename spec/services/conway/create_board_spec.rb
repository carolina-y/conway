require 'rails_helper'

RSpec.describe Conway::CreateBoard do
  describe '#call' do
    let(:params) do
      {
        state: state
      }
    end

    let(:state) { [[3, 2], [2, 2], [1, 2]] }

    context 'with valid input' do
      it 'creates a new board' do
        expect { service_result }.to change { Board.count }.by(1)
        expect(service_result.board_cells.count).to eq(state.size)
        expect(service_result.board_cells.order(:x, :y).map do |cell| [cell.x, cell.y] end).to eq(state.to_a.sort)
      end
    end

    context 'with invalid input' do
      let(:state) { 'invalid' }

      it 'raises an error for invalid initial state' do
        expect { service_result }.to raise_error(described_class::ValidationError, 'State must be an array of arrays')
      end
    end
  end
end
