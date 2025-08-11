class BoardCell < ApplicationRecord
  belongs_to :board

  validates :x, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: Board::MAX_DIMENSIONS }
  validates :y, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: Board::MAX_DIMENSIONS }
end
