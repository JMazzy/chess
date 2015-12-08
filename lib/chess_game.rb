require_relative './chess_board.rb'

class ChessGame
  attr_accessor :board, :current_player, :selecting, :moving

  def initialize
    self.board = ChessBoard.new(:standard)
    self.current_player = :white
    self.selecting = false
    self.moving = false
  end

  def handle_selection(selection)
    if board.select(current_player,selection)
      # turn selecting off
      self.selecting = false
      # turn moving on
      self.moving = true
    end
  end

  def handle_moving(move)
    # complete the move
    if board.move(current_player,move)
      # if move is valid
      # moving off
      self.moving = false
      self.selecting = true

      # switch players
      switch_player
    else
      revert
    end
  end

  def revert
    self.selecting = false
    self.moving = false
  end

  def update
    if selecting == moving
      self.selecting = true
      self.moving = false
    end
  end

  def switch_player
    if current_player == :white
      self.current_player = :black
    else
      self.current_player = :white
    end
  end
end
