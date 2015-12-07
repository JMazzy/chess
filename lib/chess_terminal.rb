#!/usr/bin/env ruby

require_relative './chess_game.rb'

class Chess

  attr_accessor :game

  def initialize
    self.game = ChessGame.new
  end

  def ask_selection
    puts "It is #{game.current_player.to_s.capitalize}'s turn."
    print "Select piece to move: "
    select_string = gets.chomp.downcase
    if select_string.match(/\w\d/) || select_string[0..2] == "0-0"
      return select_string
    else
      puts "Selection must be in the form 'a1'"
      ask_selection
    end
  end

  def ask_move
    print "Move #{game.chess_board.board[game.chess_board.selected[0]][game.chess_board.selected[1]].class} to: "
    move_string = gets.chomp.downcase
    if move_string.match(/\w\d/)
      return move_string
    else
      puts "Move must be in the form 'a1'"
      ask_move
    end
  end

  def update
    if game.selecting
      # if selecting, ask the player for a selection
      selection = ask_selection
      game.handle_selection(selection)
    elsif game.moving
      # if moving, ask for a move
      move = ask_move
      print "Confirm move? (y/n): "
      confirmation = gets[0].downcase
      if confirmation == "y"
        game.handle_moving(move)
      else
        game.revert
      end
    end
    game.update
  end

  def draw
    print game.chess_board.board_state
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
