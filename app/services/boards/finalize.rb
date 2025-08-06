class Boards::Finalize
  class UnconcludedBoardError < StandardError; end

  def initialize(board:)
    @board = board
  end

  def call
    run_board
    return_stats_and_state
  end

  private

  attr_reader :board
  attr_accessor :current_round, :state

  def run_board
    self.current_round = board.round
    self.state = Boards::GetState.new(board: board).call

    while current_round < ::Board::MAX_ROUNDS
      last_state = state.dup

      self.state = Conway::AdvanceState.new(state: state).call

      return [] if state.empty?
      return state if last_state.sort == state.sort

      self.current_round += 1
    end

    raise UnconcludedBoardError
  end

  def return_stats_and_state
    {
      rounds: current_round,
      state: state
    }
  end
end
