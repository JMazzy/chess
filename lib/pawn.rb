require_relative './chess_piece.rb'

class Pawn < ChessPiece

  attr_accessor :first_move

  def initialize( team, row, col )
    super
    self.first_move = true
  end

  def move_ok?( new_row, new_col, move_type=:normal )
    # Unlike the other pieces, the pawn DOES NOT use absolute value for these
    col_move = new_col - col
    row_move = new_row - row

    # Switch sign if black team (for black "forward" is negative)
    if team == :black
      row_move = -row_move
    end

    # Check if move type is normal or capture
    if move_type == :normal
      if first_move
        if col_move == 0 && (1..2).include?(row_move)
          true
        else
          puts "Illegal move for pawn"
          false
        end
      elsif col_move == 0 && row_move == 1
        true
      else
        puts "Can only move two spaces on the first move"
        false
      end
    elsif move_type == :capture
      if col_move.abs == 1 && row_move == 1
        true
      else
        puts "Illegal move for pawn"
        false
      end
    else
      puts "Bad move type"
      false
    end
  end

  # Method called by the board when the piece is moved
  def move(row,col)
    if first_move
      self.first_move = false
    end

    super
  end
end