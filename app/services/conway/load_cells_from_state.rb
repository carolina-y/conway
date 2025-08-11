class Conway::LoadCellsFromState
  class EmptyBoardError < StandardError; end

  class Cell
    attr_accessor :x, :y, :alive

    def initialize(x, y, alive = false)
      @x = x
      @y = y
      @alive = alive
    end
  end

  def initialize(state: state)
    @state = state
  end

  def call
    load_board_cells
    draw_board
    return_cells
  rescue EmptyBoardError
    []
  end

  private

  attr_reader :state
  attr_accessor :min_x, :min_y, :max_x, :max_y, :board_cells, :cells

  def load_board_cells
    raise EmptyBoardError if state.count.zero?

    self.min_x = nil
    self.min_y = nil
    self.max_x = nil
    self.max_y = nil
    self.cells = []

    self.board_cells = state.map do |cell|
      self.min_x = cell[0] if min_x.nil?
      self.min_y = cell[1] if min_y.nil?
      self.max_x = cell[0] if max_x.nil?
      self.max_y = cell[1] if max_y.nil?

      self.min_x = cell[0] if cell[0] < min_x
      self.min_y = cell[1] if cell[1] < min_y
      self.max_x = cell[0] if cell[0] > max_x
      self.max_y = cell[1] if cell[1] > max_y

      [cell[0], cell[1]]
    end

    self.min_x = 1 if min_x <= 0
    self.min_y = 1 if min_y <= 0
    self.max_x = Board::MAX_DIMENSIONS - 1 if max_x >= Board::MAX_DIMENSIONS
    self.max_y = Board::MAX_DIMENSIONS - 1 if max_y >= Board::MAX_DIMENSIONS
  end

  def draw_board
    (min_y - 1..max_y + 1).each do |y|
      (min_x - 1..max_x + 1).each do |x|
        cell_alive = board_cells.find { |c| c[0] == x && c[1] == y }

        cells << Cell.new(x, y, cell_alive.present?)
      end
    end
  end

  def return_cells
    cells
  end
end
