#!/usr/bin/env ruby

require './chess_board.rb'

class Chess

  attr_accessor :current_player, :selecting, :moving

  def initialize
    @chess_board = ChessBoard.new
    print @chess_board.board_state
    self.current_player = :white
    self.selecting = false
    self.moving = false
  end

  def ask_selection
    print "#{current_player.to_s.capitalize} select piece to move: "
    gets.chomp
  end

  def ask_move
    print "#{current_player.to_s.capitalize} choose where you want to move: "
    gets.chomp
  end

  def switch_player
    if current_player == :white
      self.current_player = :black
    else
      self.current_player = :white
    end
  end

  def handle_selection
    # if neither selecting or moving, set selecting to true
    if !selecting && !moving
      self.selecting = true
    end

    if selecting
      # if selecting, ask the player for a selection
      selection = ask_selection

      if @chess_board.select_ok?(selection)
        # if the selection is valid, 
        # select that piece
        @chess_board.select(selection)
        # turn selecting off 
        self.selecting = false
        # turn moving on
        self.moving = true
      else
        # if selection not valid
        puts "invalid selection"
      end
    end
  end

  def handle_moving
    if moving
      # if moving, ask for a move
      move = ask_move

      if @chess_board.move_ok?(move)
        # if move is valid
        #ask for confirmation
        puts "Confirm move? (y/n)"
        confirmation = gets[0].downcase
        if confirmation == "y"
        #if yes or anything else starting with y:
          # complete the move
          @chess_board.move(move)
          # moving off
          self.moving = false
          # switch players
          switch_player
        else
        # if no (or anything not starting with y)
          # revert to selecting on
          self.selecting = true
          # moving off
          self.moving = false
        end
      elsif
      # if move is not valid
        # revert to selecting on
        self.selecting = true
        # moving off
        self.moving = false
        @chess_board.unselect
      end
    end
  end

  def update
    handle_selection
    handle_moving
  end

  def draw
    print @chess_board.board_state
  end

  def game_loop
    loop do
      update
      draw
    end
  end
end

chess = Chess.new
chess.game_loop
