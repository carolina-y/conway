class Conway::NextRound
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
  attr_accessor :cells, :next_round_cells

  def load_state
    self.cells = Conway::LoadState.new(board_state).call
  end

  def board_state
    board.board_cells.map do |cell|
      [cell.x, cell.y]
    end
  end

  def return_next_round
    next_round_cells.select(&:alive).map do |cell|
      [cell.x, cell.y]
    end
  end

  def save_state
    ActiveRecord::Base.transaction do
      board.increment!(:round)
      board.board_cells.delete_all

      next_round_cells.each do |cell|
        board.board_cells.create!(x: cell.x, y: cell.y)
      end
    end
  end

  def calculate_next_round
    self.next_round_cells = []

    alive_cells = cells.select(&:alive).map do |cell|
      [cell.x, cell.y]
    end

    cells.each do |cell|
      alive_neighbors = count_alive_neighbors(cell)

      current_cell = cell.dup

      if cell.alive
        current_cell.alive = alive_neighbors == 2 || alive_neighbors == 3
      else
        current_cell.alive = alive_neighbors == 3
      end

      next_round_cells << current_cell
    end
  end

  def count_alive_neighbors(cell)
    neighbors = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1], [1, 0], [1, 1]
    ]

    neighbor_count = 0
    neighbors.each do |dx, dy|
      neighbor_x = cell.x + dx
      neighbor_y = cell.y + dy
      neighbor_count += 1 if cells.any? { |c| c.x == neighbor_x && c.y == neighbor_y && c.alive }
    end

    neighbor_count
  end
end
