require './chess_piece'

class Bishop < ChessPiece

  def initialize( team, row, col )
    self.team = team
    self.col = col
    self.row = row
  end

  def move_ok?( new_row, new_col )
    col_move = (col - new_col).abs
    row_move = (row - new_row).abs

    if col_move == row_move
      true
    else
      false
    end
  end
end
