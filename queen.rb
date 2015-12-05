require './chess_piece'

class Queen < ChessPiece

  def initialize( team, row, col )
    super
  end

  def move_ok?( new_row, new_col, move_type=:normal )
    col_move = (col - new_col).abs
    row_move = (row - new_row).abs

    if ( col_move == row_move ) || ( col_move == 0 && row_move != 0 ) || ( col_move != 0 && row_move == 0 )
      true
    else
      false
    end
  end
end
