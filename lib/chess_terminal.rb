#!/usr/bin/env ruby

require_relative './chess_board.rb'

class Chess

  attr_accessor :current_player, :selecting, :moving

  def initialize
    @chess_board = ChessBoard.new(:standard)
    print @chess_board.board_state
    self.current_player = :white
    self.selecting = false
    self.moving = false
  end

  def ask_selection
    puts "It is #{current_player.to_s.capitalize}'s turn."
    print "Select piece to move: "
    select_string = gets.chomp.downcase
    if select_string.match(/\w\d/)
      return select_string
    else
      puts "Selection must be in the form 'a1'"
      ask_selection
    end
  end

  def ask_move
    print "Move #{@chess_board.board[@chess_board.selected[0]][@chess_board.selected[1]].class} to : "
    move_string = gets.chomp.downcase
    if move_string.match(/\w\d/)
      return move_string
    else
      puts "Move must be in the form 'a1'"
      ask_move
    end
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

      if @chess_board.select(current_player,selection)
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

      puts "Confirm move? (y/n)"
      confirmation = gets[0].downcase
      if confirmation == "y"
      #if yes or anything else starting with y:
      
        # complete the move
        if @chess_board.move(current_player,move)
          # if move is valid
          #ask for confirmation
        elsif
        # if move is not valid
          # revert to selecting on
          self.selecting = true
          # moving off
          self.moving = false
          @chess_board.unselect
        end

        # moving off
        self.moving = false
        # switch players
        switch_player
      else
      # if no (or anything not starting with y):
        # revert to selecting on
        self.selecting = true
        # moving off
        self.moving = false
      end

      
    end
  end

  def update
    handle_selection
    print @chess_board.board_state
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
