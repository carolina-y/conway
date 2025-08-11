class Boards::Create
  class ValidationError < StandardError; end

  def initialize(state:, width:, height:)
    @state = state
    @width = width
    @height = height
  end

  def call
    validate_input
    create_board
    create_board_cells
    return_board
  end

  private

  attr_reader :state, :width, :height
  attr_accessor :board

  def create_board
    self.board = Board.create!(round: 1, width: width, height: height)
  rescue ActiveRecord::RecordInvalid => e
    raise ValidationError, e.message
  end

  def create_board_cells
    state.each do |cell|
      x, y = cell
      board.board_cells.create!(x: x, y: y)
    end
  rescue ActiveRecord::RecordInvalid => e
    raise ValidationError, e.message
  end

  def return_board
    board
  end

  def validate_input
    raise ValidationError, "State must be an array of arrays" unless state.is_a?(Array) && state.all? { |row| row.is_a?(Array) }
    raise ValidationError, "State must be an array of unique arrays" unless state.is_a?(Array) && state.uniq.length == state.length
    raise ValidationError, "State needs at least one cell" if state.empty?

    state.each do |cell|
      raise ValidationError, "Cell must be an array of two integers" unless cell.is_a?(Array) && cell.size == 2
      raise ValidationError, "Cell coordinates must be integers" unless cell.all? { |coord| coord.is_a?(Integer) }
    end
  end
end
