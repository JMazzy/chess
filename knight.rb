require './chess_piece'

class Knight < ChessPiece

  def initialize( team, row, col )
    self.team = team
    self.col = col
    self.row = row
  end

  def move_ok?( new_row, new_col )
    col_move = (col - new_col).abs
    row_move = (row - new_row).abs

    puts col_move
    puts row_move

    if ( col_move == 1 and row_move == 2 ) or ( col_move == 2 and row_move == 1 )
      true
    else
      false
    end
  end
end
