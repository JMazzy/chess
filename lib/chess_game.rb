require_relative './chess_board.rb'

class ChessGame
  attr_accessor :chess_board, :current_player, :selecting, :moving

  def initialize
    self.chess_board = ChessBoard.new(:standard)
    self.current_player = :white
    self.selecting = false
    self.moving = false
  end

  def handle_selection(selection)
    if chess_board.select(current_player,selection)
      # turn selecting off
      self.selecting = false
      # turn moving on
      self.moving = true
    else
      # if selection not valid
      puts "invalid selection"
    end
  end

  def handle_moving(move)
    # complete the move
    if chess_board.move(current_player,move)
      # if move is valid
      # moving off
      self.moving = false
      self.selecting = true

      puts chess_board.last_move_string

      # switch players
      switch_player
    else
      puts "invalid move"
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