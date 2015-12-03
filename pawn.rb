require './chess_piece'

class Pawn < ChessPiece

  def initialize( team, row, col )
    self.team = team
    self.col = col
    self.row = row
  end

  def move_ok?( new_col, new_row, move_type=:normal )
    col_move = new_col - col
    row_move = new_row - row

    # Case statement to account for different move types
    case move_type
    when :normal
      if col_move == 0 and row_move == 1
        return true
      end
    when :first
      if col_move == 0 and row_move == 2
        return true
      end
    when :capture
      if ( col_move == 1 and row_move == 1 ) or ( col_move == 1 and row_move == 1 )
        return true
      end
    end

    return false
  end
end