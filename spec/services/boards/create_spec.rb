require 'rails_helper'

RSpec.describe Boards::Create do
  describe '#call' do
    let(:params) do
      {
        state: state,
        width: width,
        height: height
      }
    end
    let(:width) { 50 }
    let(:height) { 50 }
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

    context 'with an invalid width' do
      let(:width) { 101 }

      it 'raises an error for invalid initial state' do
        expect { service_result }.to raise_error(described_class::ValidationError, /Width must be less than or equal to/)
      end
    end

    context 'with an invalid height' do
      let(:height) { 101 }

      it 'raises an error for invalid initial state' do
        expect { service_result }.to raise_error(described_class::ValidationError, /Height must be less than or equal to/)
      end
    end

    context 'with an invalid state height' do
      let(:state) { [[3, 200], [2, 2], [1, 2]] }

      it 'raises an error for invalid initial state' do
        expect { service_result }.to raise_error(described_class::ValidationError, /Y must be less than or equal to/)
      end
    end
  end
end
