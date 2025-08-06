class BoardCell < ApplicationRecord
  belongs_to :board

  validates :x, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :y, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
