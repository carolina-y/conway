class Board < ApplicationRecord
  MAX_DIMENSIONS = 99
  MAX_ROUNDS = 100

  has_many :board_cells, dependent: :destroy

  validates :height, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_DIMENSIONS }
  validates :width, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_DIMENSIONS }
end
