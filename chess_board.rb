require 'colorize'

require './pawn.rb'
require './king.rb'
require './queen.rb'
require './bishop.rb'
require './knight.rb'
require './rook.rb'

class ChessBoard

  attr_accessor :board, :captured_pieces, :selected

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

    self.captured_pieces = { white: [], black: [] }
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

          if selected == [ 7 - row, col ]
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

  def select_ok?( player, coord_string )
    if coords = chess_coords_to_indices( coord_string )
      row = coords[0]
      col = coords[1]
      if col >= 0 && col < 8 && row >=0 && row < 8
        if board[row][col]
          # Make sure the piece belongs to the current player
          if board[row][col].team == player
            true
          else
            puts "cannot select opponent's piece!"
            false
          end
        else
          puts "no piece on that square!"
          false
        end
      else
        puts "selection is off the board!"
        false
      end
    else
      puts "invalid selection"
      false
    end
  end

  def select( coord_string )
    unselect
    coords = chess_coords_to_indices( coord_string )
    self.selected = coords
  end

  def unselect
    if selected
      self.selected = nil
    end
  end

  # Takes a standard chess coordinate string and returns array indices
  def chess_coords_to_indices( coord_string )
    ###Needs to check for bad string (here or at the gets itself)
    m = coord_string.match(/(\w)(\d)/)
    col = m[1]
    row = m[2]
    
    if ('a'..'h').include?(col) && (1..8).include?(row.to_i)
      [ row.to_i - 1, COL_NAMES[col.to_sym] ]
    else
      nil
    end
  end

  def move_ok?( player, coord_string )
    if coords = chess_coords_to_indices( coord_string )
      to_row = coords[0]
      to_col = coords[1]

      #Make sure the move is in the bounds of the board
      if to_col >= 0 && to_col < 8 && to_row >=0 && to_row < 8
        from_row = selected[0]
        from_col = selected[1]

        from_piece = board[from_row][from_col]
        to_square = board[to_row][to_col]

        # the move type (default normal, could also be capture)
        move_type = :normal

        # Knights (only) are allowed to jump over other pieces
        unless from_piece.class == Knight 
          # Check for pieces on intervening squares

          # The single step corresponding to the move (magnitude one, same sign)
          row_step = to_row <=> from_row
          col_step = to_col <=> from_col

          temp_row = from_row + row_step
          temp_col = from_col + col_step
          until temp_row == to_row && temp_col == to_col
            # if a piece is there
            if board[temp_row][temp_col]
              puts "A piece is blocking."
              return false
            end

            temp_row += row_step
            temp_col += col_step
          end
        end

        # if square is occupied (not nil)
        if to_square 
          if from_piece.team != to_square.team
            # set the move type to capture
            move_type = :capture
          else
            puts "Illegal destination"
            return false
          end
        end

        # If the move is legal for the moving piece
        if from_piece.move_ok?(to_row,to_col,move_type)
          return true
        else
          puts "Illegal move for piece"
          return false
        end
      else
        puts "Out of bounds!"
        return false
      end
    end
  end

  def move( coord_string )
    # grab the "from" indices from selection data
    from_row = selected[0]
    from_col = selected[1]
    from_piece = board[from_row][from_col]

    # unselect once piece identified
    unselect
    
    # convert the coordinates to array indices
    coords = chess_coords_to_indices( coord_string )
    to_row = coords[0]
    to_col = coords[1]

    # get the captured piece (nil if no capture)
    captured_piece = board[to_row][to_col]
    if captured_piece # if the square is occupied (not nil)
      # stick the piece in the captured pile of its team
      captured_pieces[captured_piece.team] << captured_piece
    end

    # call the move method on the piece (varies by piece)
    from_piece.move(to_row,to_col)

    # actually move the piece, leaving a blank square
    board[to_row][to_col] = from_piece.dup
    board[from_row][from_col] = nil
  end
end
