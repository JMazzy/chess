require_relative './chess_piece.rb'

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

  def controlled_squares
    up_right = []
    down_left = []
    up_left = []
    down_right = []
    (row+1).upto(7) do |row_num|
      (col+1).upto(7) do |col_num|
        if move_ok?(row_num,col_num)
          up_right << [row_num,col_num]
        end
      end

      (col-1).downto(0) do |col_num|
        if move_ok?(row_num,col_num)
          up_left << [row_num,col_num]
        end
      end
    end

    (row-1).downto(0) do |row_num|
      (col+1).upto(7) do |col_num|
        if move_ok?(row_num,col_num)
          down_right << [row_num,col_num]
        end
      end

      (col-1).downto(0) do |col_num|
        if move_ok?(row_num,col_num)
          down_left << [row_num,col_num]
        end
      end
    end

    [up_right,down_right,down_left,up_left]
  end
end
