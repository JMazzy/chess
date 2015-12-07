require_relative './chess_piece.rb'

class Knight < ChessPiece

  def initialize( team, row, col )
    super
  end

  def move_ok?( new_row, new_col, move_type=:normal )
    col_move = (col - new_col).abs
    row_move = (row - new_row).abs

    if ( col_move == 1 and row_move == 2 ) or ( col_move == 2 and row_move == 1 )
      true
    else
      false
    end
  end
end