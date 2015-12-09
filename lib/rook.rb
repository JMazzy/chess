require_relative './chess_piece.rb'

class Rook < ChessPiece

  def initialize( team, row, col )
    super
  end

  def move_ok?( new_row, new_col, move_type=:normal )
    col_move = (col - new_col).abs
    row_move = (row - new_row).abs

    if ( col_move == 0 && row_move != 0 ) || ( col_move != 0 && row_move == 0 )
      true
    else
      false
    end
  end

  def controlled_squares
    up = []
    down = []
    left = []
    right = []
    (row+1).upto(7) do |num|
      up << [num,col]
    end

    (row-1).downto(0) do |num|
      down << [num,col]
    end

    (col+1).upto(7) do |num|
      right << [row,num]
    end

    (col-1).downto(0) do |num|
      left << [row,num]
    end

    [up,down,left,right]
  end
end
