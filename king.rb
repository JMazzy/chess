require './chess_piece'

class King < ChessPiece

  def initialize( team, row, col )
    self.team = team
    self.col = col
    self.row = row
  end

  def move_ok?( new_row, new_col )
    col_move = (col - new_col).abs
    row_move = (row - new_row).abs

    if !( col_move == 0 and row_move == 0 ) and ( col_move <= 1 and row_move <= 1 )
      true
    else
      false
    end
  end
end