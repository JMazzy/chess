#!/usr/bin/env ruby

require 'colorize'

require_relative './chess_game.rb'

class Chess

  attr_accessor :game

  def initialize
    self.game = ChessGame.new
  end

  def ask_selection
    puts "It is #{game.current_player.to_s.capitalize}'s turn."
    print "Select piece to move: "
    select_string = gets.chomp
    if select_string.match(/\w\d/) || select_string[0..2] == "0-0" || select_string == "resign"
      return select_string
    else
      ask_selection
    end
  end

  def ask_move
    print "Move #{game.board.piece_class(game.selected[0],game.selected[1])} to: "
    move_string = gets.chomp
    if move_string.match(/\w\d/) || move_string[0..2] == "0-0" || move_string == "resign"
      return move_string
    else
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

  #
  def draw(board)

    board_print = board.board.reverse

    board_string = "  a  b  c  d  e  f  g  h \n"

    board_print.each_index do |row|
      board_string << ( 8 - row ).to_s
      board_print[row].each_index do |col|
        if col % 2 == 0
          if row % 2 == 0
            tile_color = :light_blue
          else
            tile_color = :blue
          end
        else
          if row % 2 == 0
            tile_color = :blue
          else
            tile_color = :light_blue
          end
        end

        square = board_print[row][col]
        if square
          piece_color = square.team

          if game.selected == [ 7 - row, col ]
            tile_color = :yellow
          end

          if square.class == Pawn
            piece_string = " \u265F "
          elsif square.class == King
            piece_string = " \u265A "
          elsif square.class == Queen
            piece_string = " \u265B "
          elsif square.class == Bishop
            piece_string = " \u265D "
          elsif square.class == Knight
            piece_string = " \u265E "
          elsif square.class == Rook
            piece_string = " \u265C "
          end
        else
          piece_color = :white
          piece_string = "   "
        end

        board_string << piece_string.encode('utf-8').colorize( color: piece_color, background: tile_color )
      end
      board_string << ( 8 - row ).to_s
      board_string << "\n"
    end
    board_string << "  a  b  c  d  e  f  g  h  "

    # print out the string
    puts board_string

    # print out the most recent messages
    puts game.messages.last
  end

  def game_loop
    loop do
      update
      draw(game.board)
      if game.game_state == :white_win ||
        game.game_state == :black_win ||
        game.game_state == :draw
        break
      end
    end
    return 0
  end
end

chess = Chess.new
chess.game_loop
