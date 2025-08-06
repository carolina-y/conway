class Conway::LoadStateFromCells
  def initialize(cells:)
    @cells = cells
  end

  def call
    @cells.select(&:alive).map do |cell|
      [cell.x, cell.y]
    end
  end
end
