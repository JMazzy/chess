require 'colorize'

require './pawn.rb'
require './king.rb'
require './queen.rb'
require './bishop.rb'
require './knight.rb'
require './rook.rb'

class ChessBoard

  attr_accessor :board, :off_board, :selected

  COL_NAMES = { a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7 }
  
  def initialize
    @board =  [ [nil,nil,nil,nil,nil,nil,nil,nil],
                [nil,nil,nil,nil,nil,nil,nil,nil],
                [nil,nil,nil,nil,nil,nil,nil,nil],
                [nil,nil,nil,nil,nil,nil,nil,nil],
                [nil,nil,nil,nil,nil,nil,nil,nil],
                [nil,nil,nil,nil,nil,nil,nil,nil],
                [nil,nil,nil,nil,nil,nil,nil,nil],
                [nil,nil,nil,nil,nil,nil,nil,nil] ]

    pieces =  [
                King.new(:white, 0,3), Queen.new(:white, 0,4), King.new(:black, 7,3), Queen.new(:black, 7,4),
                Bishop.new(:white, 0,2), Bishop.new(:white, 0,5), Bishop.new(:black, 7,2), Bishop.new(:black, 7,5),
                Knight.new(:white, 0,1), Knight.new(:white, 0,6), Knight.new(:black, 7,1), Knight.new(:black, 7,6),
                Rook.new(:white, 0,0), Rook.new(:white, 0,7), Rook.new(:black, 7,0), Rook.new(:black, 7,7)
              ]

    (0..7).each do |col|
      pieces << Pawn.new(:white, 1, col )
    end

    (0..7).each do |col|
      pieces << Pawn.new(:black, 6, col )
    end

    pieces.each do |piece|
      self.board[piece.row][piece.col] = piece
    end

    self.selected = nil

    @off_board = { white: [], black: [] }
  end

  # Generate a terminal output string representing the board
  def board_state
    board_print = board.reverse

    board_string = "  a  b  c  d  e  f  g  h \n"

    board_print.each_index do |row|
      board_string << ( 8 - row ).to_s
      board_print[row].each_index do |col|
        if col % 2 == 0
          if row % 2 == 0
            tile_color = :light_blue
          else
            tile_color = :blue
          end
        else
          if row % 2 == 0
            tile_color = :blue
          else
            tile_color = :light_blue
          end
        end

        square = board_print[row][col]
        if square
          piece_color = square.team

          if square.selected
            tile_color = :yellow
          end

          if square.class == Pawn
            piece_string = " \u265F "
          elsif square.class == King
            piece_string = " \u265A "
          elsif square.class == Queen
            piece_string = " \u265B "
          elsif square.class == Bishop
            piece_string = " \u265D "
          elsif square.class == Knight
            piece_string = " \u265E "
          elsif square.class == Rook
            piece_string = " \u265C "
          end
        else
          piece_color = :white
          piece_string = "   "
        end

        board_string << piece_string.encode('utf-8').colorize( color: piece_color, background: tile_color )
      end
      board_string << ( 8 - row ).to_s
      board_string << "\n"
    end
    board_string << "  a  b  c  d  e  f  g  h \n"
    #return the generated string
    board_string
  end

  def select_ok?( coord_string )
    if coords = chess_coords_to_indices( coord_string )
      row = coords[0]
      col = coords[1]
      if col >= 0 and col < 8 and row >=0 and row < 8
        if board[row][col]
          true
        else
          false
        end
      else
        false
      end
    else
      false
    end
  end

  def select( coord_string )
    unselect

    coords = chess_coords_to_indices( coord_string )
    row = coords[0]
    col = coords[1]
    
    self.selected = coords
    board[row][col].select
  end

  def unselect
    if selected
      col = selected[0]
      row = selected[1]
      board[row][col].unselect
      self.selected = nil
    end
  end

  # Takes a standard chess coordinate string and returns array indices
  def chess_coords_to_indices( coord_string )
    m = coord_string.match(/(\w)(\d)/)
    col = m[1]
    row = m[2]
    
    if ('a'..'h').include?(col) && (1..8).include?(row.to_i)
      [ row.to_i - 1, COL_NAMES[col.to_sym] ]
    else
      nil
    end
  end

  def move_ok?( coord_string )
    if coords = chess_coords_to_indices( coord_string )
      from_row = selected[0]
      from_col = selected[1]

      row = coords[0]
      col = coords[1]
      if col >= 0 and col < 8 and row >=0 and row < 8
        # if the space is empty (nil), the move is OK
        if !board[row][col]
          if board[from_row][from_col].move_ok?(row,col)
            true
          else
            puts "illegal move for piece"
            false
          end
        else
          puts "illegal destination"
          false
        end
      else
        puts "out of bounds!"
        false
      end
    end
  end

  def move( coord_string )
    from_row = selected[0]
    from_col = selected[1]
 
    coords = chess_coords_to_indices( coord_string )
    row = coords[0]
    col = coords[1]

    board[row][col] = board[from_row][from_col]
    board[from_row][from_col] = nil
    board[row][col].unselect
  end
end
