require 'colorize'

require_relative './pawn.rb'
require_relative './king.rb'
require_relative './queen.rb'
require_relative './bishop.rb'
require_relative './knight.rb'
require_relative './rook.rb'

class ChessBoard

  #game states are :playing, :check, :checkmate

  attr_accessor :board,
                :captured_pieces,
                :selected,
                :game_state,
                :messages

  def empty_board
    self.board =  [ [nil,nil,nil,nil,nil,nil,nil,nil],
                    [nil,nil,nil,nil,nil,nil,nil,nil],
                    [nil,nil,nil,nil,nil,nil,nil,nil],
                    [nil,nil,nil,nil,nil,nil,nil,nil],
                    [nil,nil,nil,nil,nil,nil,nil,nil],
                    [nil,nil,nil,nil,nil,nil,nil,nil],
                    [nil,nil,nil,nil,nil,nil,nil,nil],
                    [nil,nil,nil,nil,nil,nil,nil,nil] ]
  end

  def standard_board
    empty_board

    pieces =  [
                King.new(:white, 0,4), Queen.new(:white, 0,3), King.new(:black, 7,4), Queen.new(:black, 7,3),
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
  end

  def initialize(board_type=:standard)
    if board_type == "standard" || board_type == :standard
      standard_board
    elsif board_type == "blank" || board_type == :blank
      empty_board
    end

    self.selected = nil

    self.game_state = :playing

    self.captured_pieces = { white: [], black: [] }

    self.messages = ["It's on!"]
  end

  def board_square(coord_string)
    if coords = chess_coords_to_indices( coord_string )
      row = coords[0]
      col = coords[1]

      board[row][col]
    end
  end

  def set_piece(team, coord_string, piece_class)
    if coords = chess_coords_to_indices( coord_string )
      row = coords[0]
      col = coords[1]

      board[row][col] = piece_class.new(team,row,col)
      return true
    else
      return false
    end
  end

  def select_ok?( player, coord_string )
    if coords = chess_coords_to_indices( coord_string )
      row = coords[0]
      col = coords[1]
      if col >= 0 && col < 8 && row >=0 && row < 8
        if board[row][col]
          # Make sure the piece belongs to the current player
          if board[row][col].team == player
            messages << "SELECTION: #{player.to_s.capitalize} selected #{board[row][col].class} at #{indices_to_chess_coords(row,col)}"
            true
          else
            messages << "ERROR: Cannot select opponent's piece!"
            false
          end
        else
          messages << "ERROR: No piece on that square!"
          false
        end
      else
        messages << "ERROR: Selection is off the board!"
        false
      end
    else
      messages << "ERROR: Invalid selection!"
      false
    end
  end

  def select( player, coord_string )
    if select_ok?(player, coord_string)
      unselect
      coords = chess_coords_to_indices( coord_string )
      self.selected = coords
      true
    else
      false
    end
  end

  def unselect
    if selected
      self.selected = nil
    end
  end

  # Takes a standard chess coordinate string and returns array indices
  def chess_coords_to_indices( coord_string )
    if m = coord_string.match(/(\w)(\d)/)
      col = m[1]
      row = m[2]

      columns = { a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7 }

      if ('a'..'h').include?(col) && (1..8).include?(row.to_i)
        [ row.to_i - 1, columns[col.to_sym] ]
      else
        false
      end
    else
      false
    end
  end

  def indices_to_chess_coords( row, col )
    columns = ['a','b','c','d','e','f','g','h']

    "#{columns[col]}#{row+1}"
  end

  def path_clear?(from_row, from_col, to_row, to_col)

    # Check for pieces on intervening squares
    # The single step corresponding to the move (magnitude one, same sign)
    row_step = to_row <=> from_row
    col_step = to_col <=> from_col

    temp_row = from_row + row_step
    temp_col = from_col + col_step

    until temp_row == to_row && temp_col == to_col
      if (0..7).include?(temp_row) && (0..7).include?(temp_col)

        # if a piece is there
        if board[temp_row][temp_col]
          return false
        end

        temp_row += row_step
        temp_col += col_step
      else
        return false
      end
    end

    return true
  end

  def castle_ok?( move_type, to_row )
    if move_type == :castle_ks
      rook = board[to_row][7]
    elsif move_type == :castle_qs
      rook = board[to_row][0]
    end

    if rook.class == Rook && rook.first_move
      return true
    else
      return false
    end
  end

  def move_ok?( from_row, from_col, to_row, to_col, move_type=:normal )
    #Make sure the move is in the bounds of the board
    if to_col >= 0 && to_col < 8 && to_row >=0 && to_row < 8

      from_piece = board[from_row][from_col]

      # Knights (only) are allowed to jump over other pieces
      if from_piece.class == Knight || move_type.to_s[0..5] == "castle" || path_clear?(from_row,from_col,to_row, to_col)

        # If the move is legal for the moving piece
        if from_piece.move_ok?(to_row,to_col,move_type)

          if move_type.to_s[0..5] == "castle"
            return castle_ok?(move_type,to_row)
          else
            return true
          end

        else # If it is an illegal move
          messages << "ERROR: Illegal move for piece."
          return false
        end
      else
        messages << "ERROR: That piece can't jump over other pieces."
        return false
      end
    else
      messages << "ERROR: That move is out of bounds!"
      return false
    end
  end

  def find_move_type( player, coord_string )
    from_row = selected[0]
    from_col = selected[1]
    from_square = board[from_row][from_col]

    if coords = chess_coords_to_indices( coord_string )
      to_row = coords[0]
      to_col = coords[1]
      to_square = board[to_row][to_col]

      if to_square
        if to_square.team != player
          :capture
        else
          messages << "ERROR: You cannot capture your own piece!"
          :illegal
        end
      elsif from_square.class == Pawn
        if player == :white && from_row == 6 && to_row == 7
          :promote
        elsif player == :black && from_row == 1 && to_row == 0
          :promote
        else
          :normal
        end
      else
        :normal
      end
    elsif coord_string == "0-0"
      :castle_ks
    elsif coord_string == "0-0-0"
      :castle_qs
    else
      :illegal
      messages << "ERROR: Bad move input!"
    end
  end

  def move( player, coord_string )
    from_row = selected[0]
    from_col = selected[1]

    move_type = find_move_type(player,coord_string)

    if move_type == :illegal
      false
    end

    if move_type.to_s[0..5] == "castle"
      if move_type == :castle_ks
        to_col = 6
      elsif move_type == :castle_qs
        to_col = 2
      end

      if player == :white
        to_row = 0
      else
        to_row = 7
      end
    else
      coords = chess_coords_to_indices( coord_string )
      to_row = coords[0]
      to_col = coords[1]
    end

    if move_ok?( from_row, from_col, to_row, to_col, move_type )
      # convert the coordinates to array indices
      if move_type == :normal
        normal_move(player, coord_string, from_row, from_col, to_row, to_col)
      elsif move_type == :capture
        normal_move(player, coord_string, from_row, from_col, to_row, to_col)
      elsif move_type == :castle_ks || move_type == :castle_qs
        castle_move(player,coord_string)
      elsif move_type == :promote_move

      end
      unselect
      true
    else
      false
    end
  end

  def normal_move(player, coord_string, from_row, from_col, to_row, to_col)
    from_piece = board[from_row][from_col].dup

    # get the captured piece (nil if no capture)
    captured_piece = board[to_row][to_col]
    if captured_piece # if the square is occupied (not nil)
      # stick the piece in the captured pile of its team
      captured_pieces[captured_piece.team] << captured_piece
      move_phrase = "captured #{captured_piece.class} at #{coord_string}"
    else
      move_phrase = "to #{coord_string}"
    end

    # call the move method on the piece (varies by piece)
    from_piece.move(to_row,to_col)

    # actually move the piece, leaving a blank square
    board[to_row][to_col] = from_piece
    board[from_row][from_col] = nil

    messages << "MOVE: #{player.capitalize} #{from_piece.class} #{move_phrase}"
  end

  def castle_move(player, coord_string)
    if coord_string == "0-0"
      to_col = 6
      rook_from_col = 7
      rook_to_col = 5
      side = "king"
    elsif coord_string == "0-0-0"
      to_col = 2
      rook_from_col = 0
      rook_to_col = 3
      side = "queen"
    end

    if player == :white
      row = 0
    else
      row = 7
    end

    from_col = 4

    from_piece = board[row][from_col].dup

    from_piece.move(row,to_col)

    board[row][to_col] = from_piece
    board[row][from_col] = nil

    rook = board[row][rook_from_col].dup

    board[row][rook_to_col] = rook
    board[row][rook_from_col] = nil

    messages << "MOVE: #{player.capitalize} castled #{side}side"
  end

  def promote_move

  end
end
