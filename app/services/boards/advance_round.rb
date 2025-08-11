class Boards::AdvanceRound
  def initialize(board:)
    @board = board
  end

  def call
    load_state
    calculate_next_round
    save_state
    return_next_round
  end

  private

  attr_reader :board
  attr_accessor :state, :next_round_state

  def load_state
    self.state = board_state
  end

  def board_state
    board.board_cells.map do |cell|
      [cell.x, cell.y]
    end
  end

  def return_next_round
    next_round_state
  end

  def save_state
    ActiveRecord::Base.transaction do
      board.increment!(:round)
      board.save!
      board.board_cells.delete_all

      next_round_state.each do |cell|
        board.board_cells.create!(x: cell[0], y: cell[1])
      end
    end
  end

  def calculate_next_round
    self.next_round_state = Conway::AdvanceState.new(state: state).call
  end
end
