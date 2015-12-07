require_relative './chess_piece.rb'

class King < ChessPiece

  def initialize( team, row, col )
    super
  end

  def move_ok?( new_row, new_col, move_type=:normal )
    if move_type == :normal || move_type == :capture
      col_move = (col - new_col).abs
      row_move = (row - new_row).abs

      if !( col_move == 0 and row_move == 0 ) and ( col_move <= 1 and row_move <= 1 )
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
end