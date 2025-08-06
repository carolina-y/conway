class BoardsController < ApplicationController
  before_action :find_board, only: [:next_round, :progress, :remaining_rounds]

  def create
    board = Conway::CreateBoard.new(state: params[:state]).call

    render json: { id: board.id }, status: :created
  rescue Conway::CreateBoard::ValidationError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def next_round
    state = Conway::NextRound.new(board: @board).call

    render json: { state: state }
  end

  def progress
    Conway::FinalizeBoard.new(board: @board).call
  rescue Conway::UnconcludedBoardError
    render json: {
      error: "Board is not concluded after #{Board.MAX_ROUNDS} rounds"
    }, status: :unprocessable_entity
  end

  def remaining_rounds
    render json: {
      remaining_rounds: Conway::RemainingRoundCount.new(board: @board).call
    }
  end

  private

  def find_board
    @board = Board.find(params[:id])
  end
end
