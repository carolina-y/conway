class BoardsController < ApplicationController
  before_action :find_board, only: [:next, :progress]

  def create
    Conway::CreateBoard.new(create_board_params).call
  rescue Conway::CreateBoard::ValidationError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def next
    Conway::NextRound.new(board: @board).call
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

  def create_board_params
    params.require(:board).permit(:width, :height, :initial_state)
  end
end
