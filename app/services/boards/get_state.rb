class Boards::GetState
  def initialize(board:)
    @board = board
  end

  def call
    return_board_state
  end

  private

  attr_reader :board

  def return_board_state
    board.board_cells.select(:x, :y).map do |cell|
      [cell.x, cell.y]
    end
  end
end
