require './chess_piece'

class Bishop < ChessPiece

  def initialize( team, row, col )
    super
  end

  def move_ok?( new_row, new_col, move_type=:normal )
    col_move = (new_col - col).abs
    row_move = (new_row - row).abs

    if col_move == row_move
      true
    else
      false
    end
  end
end
