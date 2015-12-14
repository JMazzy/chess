require_relative './chess_piece.rb'

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

  def controlled_squares
    up_right = []
    down_left = []
    up_left = []
    down_right = []
    up = []
    down = []
    left = []
    right = []
    (row+1).upto(7) do |row_num|
      (col+1).upto(7) do |col_num|
          up_right << [row_num,col_num]
      end

      (col-1).downto(0) do |col_num|
        up_left << [row_num,col_num]
      end
    end

    (row-1).downto(0) do |row_num|
      (col+1).upto(7) do |col_num|
        down_right << [row_num,col_num]
      end

      (col-1).downto(0) do |col_num|
        down_left << [row_num,col_num]
      end
    end

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

    [up_right,down_right,down_left,up_left,up,down,left,right]
  end
end
