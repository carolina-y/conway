FactoryBot.define do
  factory :board do
    width { 50 }
    height { 50 }
    round { 1 }

    trait :with_square do
      after(:create) do |board|
        create(:board_cell, board: board, x: 1, y: 1)
        create(:board_cell, board: board, x: 1, y: 2)
        create(:board_cell, board: board, x: 2, y: 1)
        create(:board_cell, board: board, x: 2, y: 2)
      end
    end

    trait :with_single_element do
      after(:create) do |board|
        create(:board_cell, board: board, x: 1, y: 1)
      end
    end

    trait :finishable do
      after(:create) do |board|
        create(:board_cell, board: board, x: 1, y: 2)
        create(:board_cell, board: board, x: 2, y: 2)
      end
    end

    trait :infinite_loop do
      after(:create) do |board|
        create(:board_cell, board: board, x: 1, y: 2)
        create(:board_cell, board: board, x: 2, y: 2)
        create(:board_cell, board: board, x: 3, y: 2)
      end
    end

    trait :left_corner_test do
      after(:create) do |board|
        create(:board_cell, board: board, x: 0, y: 0)
        create(:board_cell, board: board, x: 0, y: 1)
        create(:board_cell, board: board, x: 0, y: 2)
      end
    end

    trait :right_corner_test do
      after(:create) do |board|
        create(:board_cell, board: board, x: Board::MAX_DIMENSIONS, y: 0)
        create(:board_cell, board: board, x: Board::MAX_DIMENSIONS, y: 1)
        create(:board_cell, board: board, x: Board::MAX_DIMENSIONS, y: 2)
      end
    end

    trait :top_test do
      after(:create) do |board|
        create(:board_cell, board: board, x: 0, y: Board::MAX_DIMENSIONS)
        create(:board_cell, board: board, x: 1, y: Board::MAX_DIMENSIONS)
        create(:board_cell, board: board, x: 2, y: Board::MAX_DIMENSIONS)
      end
    end

    trait :bottom_test do
      after(:create) do |board|
        create(:board_cell, board: board, x: 0, y: 0)
        create(:board_cell, board: board, x: 1, y: 0)
        create(:board_cell, board: board, x: 2, y: 0)
      end
    end
  end
end
