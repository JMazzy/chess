
# A data structure representing a chess board

# # 0 1 2 3 4 5 6 7
# 7 # # # # # # # #
# 6 # # # # # # # #
# 5 # # # # # # # #
# 4 # # # # # # # #
# 3 # # # # # # # #
# 2 # # # # # # # #
# 1 # # # # # # # #
# 0 # # # # # # # #

require_relative './pawn.rb'
require_relative './king.rb'
require_relative './queen.rb'
require_relative './bishop.rb'
require_relative './knight.rb'
require_relative './rook.rb'

class ChessBoard

  attr_accessor :board, :captured_pieces

  def initialize

    @num_rows = 8
    @num_columns = 8

    self.board = []
    (0...@num_rows).each do |row|
      self.board[row] = []
      (0...@num_columns).each do |col|
        self.board[row][col] = nil
      end
    end

    self.captured_pieces = { white: [], black: [] }
  end

  def fill
    pieces = [Rook,Knight,Bishop,Queen,King,Bishop,Knight,Rook]

    (0..7).each do |col|
      set_piece(1,col,:white,Pawn)
      set_piece(6,col,:black,Pawn)
      set_piece(0,col,:white,pieces[col])
      set_piece(7,col,:black,pieces[col])
    end

    board
  end

  def each
    board.each do |row|
      row.each do |square|
        yield square
      end
    end
  end

  def square(row,col)
    board[row][col]
  end

  def set_piece(row,col,team,piece_class)
    self.board[row][col] = piece_class.new(team,row,col)
  end

  def capture_piece(row,col)
    piece = board[row][col].dup
    self.captured_pieces[piece.team] << piece
    board[row][col] = nil
  end

  def move_piece(from_row,from_col,to_row,to_col)
    board[to_row][to_col] = board[from_row][from_col].dup
    board[to_row][to_col].move(to_row,to_col)
    board[from_row][from_col] = nil
  end

  def piece_exists?(row,col)
    if in_bounds?(row,col)
      !!board[row][col]
    else
      false
    end
  end

  def piece_class(row,col)
    board[row][col].class
  end

  def piece_team(row,col)
    board[row][col].team
  end

  def in_bounds?(row,col)
    if row >= 0 && row < @num_rows && col >= 0 && col < @num_columns
      true
    else
      false
    end
  end
end
