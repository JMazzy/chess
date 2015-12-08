require_relative './chess_piece.rb'

class Pawn < ChessPiece

  def initialize( team, row, col )
    super
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
          # illegal move for pawn
          false
        end
      elsif col_move == 0 && row_move == 1
        true
      else
        # illegal move for pawn
        false
      end
    elsif move_type == :capture
      if col_move.abs == 1 && row_move == 1
        true
      else
        # illegal move for pawn capture
        false
      end
    elsif move_type == :passant
      #NEED TO IMPLEMENT EN PASSANT MOVES
    elsif move_type.to_s[0..6] == "promote"
      if col_move == 0 && row_move == 1
        if team == :black && new_row == 0
          true
        elsif team == :white && new_row == 7
          true
        else
          # it isn't really a promotion and should have failed already...
          false
        end
      else
        # illegal move for pawn
        false
      end
    else
      # the move type isn't accepted
      false
    end
  end

  # Method called by the board when the piece is moved
  def move(row,col)
    super
  end
end
