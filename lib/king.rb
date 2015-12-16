require_relative './chess_piece.rb'

class King < ChessPiece
  def move_ok?( new_row, new_col, move_type=:normal )
    if move_type == :normal || move_type == :capture
      col_move = (col - new_col).abs
      row_move = (row - new_row).abs

      if !( col_move == 0 && row_move == 0 ) && ( col_move <= 1 && row_move <= 1 )
        true
      else
        false
      end
    elsif first_move && move_type == :castle_ks
      true
    elsif first_move && move_type == :castle_qs
      true
    else
      false
    end
  end

  def controlled_squares
    up_right = []
    down_left = []
    up_left = []
    down_right = []
    up = []
    down = []
    left = []
    right = []

    up_right << [row+1,col+1]
    up_left << [row+1,col-1]
    down_right << [row-1,col+1]
    down_left << [row-1,col-1]
    up << [row+1,col]
    down << [row-1,col]
    right << [row,col+1]
    left << [row,col-1]

    [up_right,down_right,down_left,up_left,up,down,left,right]
  end
end
