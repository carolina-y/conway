class BoardsController < ApplicationController
  before_action :find_board, only: [:next_round, :progress, :remaining_rounds]
  before_action :idempotency_read, only: [:create, :next_round]

  def create
    idempotency_read

    # Ideally, use dry-rb or similar to separate validation from the service.
    board = Boards::Create.new(
      state: params[:state],
      height: params[:height],
      width: params[:width]
    ).call

    idempotency_write(:created, { id: board.id })

    render json: { id: board.id }, status: :created
  rescue Boards::Create::ValidationError => e
    render json: { error: e.message }, status: :unprocessable_content
  end

  def next_round
    idempotency_read

    state = Boards::AdvanceRound.new(board: @board).call
    idempotency_write(:created, { state: state })

    render json: { state: state }, status: :created
  end

  def progress
    finalized_board_results = Boards::Finalize.new(board: @board).call

    render json: { state: finalized_board_results[:state] }
  rescue Boards::Finalize::UnconcludedBoardError
    render json: {
      error: "Board is not concluded after #{Board::MAX_ROUNDS} rounds"
    }, status: :unprocessable_content
  end

  def remaining_rounds
    finalized_board_results = Boards::Finalize.new(board: @board).call

    render json: {
      remaining_rounds: finalized_board_results[:rounds] - @board.round
    }
  rescue Boards::Finalize::UnconcludedBoardError
    render json: {
      remaining_rounds: -1
    }
  end

  private

  def find_board
    @board = Board.find(params[:id])
  end
end
