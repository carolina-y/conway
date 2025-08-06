class Conway::AdvanceState
  def initialize(state:)
    @state = state
  end

  def call
    initialize_next_round_cells
    calculate_next_round
    return_next_round
  end

  private

  attr_reader :state
  attr_accessor :cells, :next_round_cells

  def initialize_next_round_cells
    self.next_round_cells = []
  end

  def calculate_next_round
    self.cells = Conway::LoadCellsFromState.new(state: state).call

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

  def return_next_round
    Conway::LoadStateFromCells.new(cells: next_round_cells).call
  end

  def count_alive_neighbors(cell)
    neighbors = [
      [-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]
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
