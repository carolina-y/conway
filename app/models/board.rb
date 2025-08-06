class Board < ApplicationRecord
  MAX_ROUNDS = 100

  has_many :board_cells, dependent: :destroy
end
