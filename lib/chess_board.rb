require_relative './pawn.rb'
require_relative './king.rb'
require_relative './queen.rb'
require_relative './bishop.rb'
require_relative './knight.rb'
require_relative './rook.rb'
#   0 1 2 3 4 5 6 7
# 7                 8
# 6                 7
# 5                 6
# 4                 5
# 3                 4
# 2                 3
# 1                 2
# 0                 1
#   a b c d e f g h

class ChessBoard
  # game states are :playing, :check, :white_win, :black_win, :draw

  attr_accessor :board,
                :captured_pieces,
                :selected,
                :game_state,
                :messages

  def empty_board
    [ [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil]  ]
  end

  def standard_board
    board = empty_board

    pieces = [
      King.new(:white, 0, 4), Queen.new(:white, 0, 3), King.new(:black, 7, 4), Queen.new(:black, 7, 3),
      Bishop.new(:white, 0, 2), Bishop.new(:white, 0, 5), Bishop.new(:black, 7, 2), Bishop.new(:black, 7, 5),
      Knight.new(:white, 0, 1), Knight.new(:white, 0, 6), Knight.new(:black, 7, 1), Knight.new(:black, 7, 6),
      Rook.new(:white, 0, 0), Rook.new(:white, 0, 7), Rook.new(:black, 7, 0), Rook.new(:black, 7, 7)
    ]

    (0..7).each do |col|
      pieces << Pawn.new(:white, 1, col)
    end

    (0..7).each do |col|
      pieces << Pawn.new(:black, 6, col)
    end

    pieces.each do |piece|
      board[piece.row][piece.col] = piece
    end

    return board
  end

  def initialize(board_type = :standard)
    if board_type == 'standard' || board_type == :standard
      self.board = standard_board
    elsif board_type == 'blank' || board_type == :blank
      self.board = empty_board
    end

    self.selected = nil

    self.game_state = :playing

    self.captured_pieces = { white: [], black: [] }

    self.messages = ["BEGIN: It's on!"]
  end

  def board_square(coord_string)
    if coords = chess_coords_to_indices(coord_string)
      row = coords[0]
      col = coords[1]

      board[row][col]
    end
  end

  def set_piece(team, coord_string, piece_class)
    if coords = chess_coords_to_indices(coord_string)
      row = coords[0]
      col = coords[1]

      board[row][col] = piece_class.new(team, row, col)
      return true
    else
      return false
    end
  end

  def piece_exists?(row,col)
    if in_bounds?(row,col)
      !!board[row][col]
    else
      false
    end
  end

  def select_ok?(player, row, col)
    if in_bounds?(row,col)
      if piece_exists?(row,col)
        # Make sure the piece belongs to the current player
        if board[row][col].team == player
          messages << "SELECTION: #{player.to_s.capitalize} selected #{board[row][col].class} at #{indices_to_chess_coords(row, col)}"
          true
        else
          messages << "ERROR: Cannot select opponent's piece!"
          false
        end
      else
        messages << 'ERROR: No piece on that square!'
        false
      end
    else
      messages << 'ERROR: Selection is off the board!'
      false
    end
  end

  def select(player, coord_string)
    if coords = chess_coords_to_indices(coord_string)
      row = coords[0]
      col = coords[1]
      if select_ok?(player, row, col)
        unselect
        coords = chess_coords_to_indices(coord_string)
        self.selected = coords
        true
      else
        false
      end
    elsif coord_string == "resign"
      resign(player)
      false
    else
      messages << 'ERROR: Invalid selection!'
      false
    end

  end

  def unselect
    self.selected = nil if selected
  end

  # Takes a standard chess coordinate string and returns array indices
  def chess_coords_to_indices(coord_string)
    if m = coord_string.match(/(\w)(\d)/)
      col = m[1]
      row = m[2]

      columns = { a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7 }

      if ('a'..'h').include?(col) && (1..8).include?(row.to_i)
        [row.to_i - 1, columns[col.to_sym]]
      else
        false
      end
    else
      false
    end
  end

  def indices_to_chess_coords(row, col)
    columns = %w(a b c d e f g h)
    "#{columns[col]}#{row + 1}"
  end

  def path_clear?(from_row, from_col, to_row, to_col)
    # The path is always clear for knights
    if board[from_row][from_col].class == Knight
      return true
    else
      # Check for pieces on intervening squares
      # The single step corresponding to the move (-1, 0, 1)
      row_step = to_row <=> from_row
      col_step = to_col <=> from_col

      temp_row = from_row + row_step
      temp_col = from_col + col_step

      until temp_row == to_row && temp_col == to_col
        if (0..7).include?(temp_row) && (0..7).include?(temp_col)

          # if a piece is there
          if board[temp_row][temp_col]
            messages << "PATH_CLEAR_ERROR: Path blocked!"
            return false
          else
            temp_row += row_step
            temp_col += col_step
          end
        else
          messages << "PATH_CLEAR_ERROR: Path goes out of bounds!"
          return false
        end
      end

      # If no piece is encountered along the move path, return true
      return true
    end
  end

  # iterates through each square on the board, populating each piece's list of controlled squares
  def piece_control
    self.game_state = :playing
    board.each do |row|
      row.each do |square|
        if square
          square.pieces_in_range = []
          control = square.controlled_squares
          control.each do |direction|
            direction.each do |space|
              if space && space[0] && space[1] && in_bounds?(space[0],space[1])
                if piece = board[space[0]][space[1]]
                  team_marker = piece.team.to_s[0].upcase
                  if piece.class == Knight
                    piece_marker = "N"
                  else
                    piece_marker = piece.class.to_s[0]
                  end

                  if piece.class == King
                    self.game_state = :check
                  end
                  square_coordinates = indices_to_chess_coords(space[0],space[1])
                  square.pieces_in_range << "#{team_marker}#{piece_marker}#{square_coordinates}"
                  break
                end
              end
            end
          end
        end
      end
    end
  end

  def in_bounds?(row,col)
    if row >= 0 && row < 8 && col >= 0 && col < 8
      true
    else
      false
    end
  end

  def castle_type(player, coord_string)
    if player == :white
      row = 0
    else
      row = 7
    end

    if coord_string == '0-0'
      king = board[row][4]
      rook = board[row][7]
      if king.first_move && rook.first_move
        :castle_ks
      else
        :illegal
      end
    elsif coord_string == '0-0-0'
      king = board[row][4]
      rook = board[row][0]
      if king.first_move && rook.first_move
        :castle_qs
      else
        :illegal
      end
    else
      :illegal
    end
  end

  def find_move_type(player, coord_string)
    from_row = selected[0]
    from_col = selected[1]
    from_piece = board[from_row][from_col]

    if coords = chess_coords_to_indices(coord_string)
      to_row = coords[0]
      to_col = coords[1]
      to_square = board[to_row][to_col]

      # Make sure the move is in the bounds of the board
      if in_bounds?(to_row, to_col)

        # If the path is clear for that piece to move
        if path_clear?(from_row, from_col, to_row, to_col)

          # if square is occupied (not nil)
          if piece_exists?(to_row,to_col)
            if to_square.team != player
              :capture
            else
              messages << 'ERROR: You cannot capture your own piece!'
              :illegal
            end
          elsif from_piece.class == Pawn
            if ((player == :white && from_row == 4) ||
              (player == :black && from_row == 3)) &&
               board[from_row][to_col] && board[from_row][to_col].passantable
              :passant
            elsif (player == :white && from_row == 6 && to_row == 7) ||
                  (player == :black && from_row == 1 && to_row == 0)
              if m = coord_string.match(/(\w)(\d)(R|N|B|Q)/)
                case m[3]
                when 'R'
                  :promote_rook
                when 'N'
                  :promote_knight
                when 'K'
                  :promote_knight
                when 'B'
                  :promote_bishop
                when 'Q'
                  :promote_queen
                else
                  messages << 'ERROR: Not a valid promotion piece.'
                  :illegal
                end
              else
                messages << 'ERROR: Must choose a promotion piece.'
                :illegal
              end
            else
              # Not passant or promotion
              :normal
            end
          else
            # Not a pawn or a capture
            :normal
          end
        else
          messages << "ERROR: That piece can't jump over other pieces."
          :illegal
        end
      else
        messages << 'ERROR: That move is out of bounds!'
        :illegal
      end
    elsif coord_string.to_s[0..2] == '0-0'
      # Castling
      castle_type(player, coord_string)
    elsif coord_string == "resign"
      resign(player)
      false
    else
      messages << 'ERROR: Bad move input!'
      :illegal
    end
  end

  def move(player, coord_string)
    from_row = selected[0]
    from_col = selected[1]
    from_piece = board[from_row][from_col]

    move_type = find_move_type(player, coord_string)

    if move_type == :illegal
      return false
    elsif move_type.to_s[0..5] == 'castle'
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
      coords = chess_coords_to_indices(coord_string)
      to_row = coords[0]
      to_col = coords[1]
    end

    if from_piece.move_ok?(to_row, to_col, move_type)
      # convert the coordinates to array indices
      if move_type == :normal
        normal_move(player, coord_string, from_row, from_col, to_row, to_col)
      elsif move_type == :capture
        normal_move(player, coord_string, from_row, from_col, to_row, to_col)
      elsif move_type == :passant
        passant_move(player, from_row, from_col, to_row, to_col)
      elsif move_type == :castle_ks || move_type == :castle_qs
        castle_move(player, coord_string)
      elsif move_type.to_s[0..6] == 'promote'
        promote_move(player, to_col, move_type)
      end
      unselect
      true
    else
      # If it is an illegal move
      messages << 'ERROR: Illegal move for piece.'
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
    from_piece.move(to_row, to_col)

    # actually move the piece, leaving a blank square
    board[to_row][to_col] = from_piece
    board[from_row][from_col] = nil

    messages << "MOVE: #{player.capitalize} #{from_piece.class} #{move_phrase}"
  end

  def castle_move(player, coord_string)
    if coord_string == '0-0'
      to_col = 6
      rook_from_col = 7
      rook_to_col = 5
      side = 'king'
    elsif coord_string == '0-0-0'
      to_col = 2
      rook_from_col = 0
      rook_to_col = 3
      side = 'queen'
    end

    if player == :white
      row = 0
    else
      row = 7
    end

    from_col = 4

    from_piece = board[row][from_col].dup

    from_piece.move(row, to_col)

    board[row][to_col] = from_piece
    board[row][from_col] = nil

    rook = board[row][rook_from_col].dup

    board[row][rook_to_col] = rook
    board[row][rook_from_col] = nil

    messages << "MOVE: #{player.capitalize} castled #{side}side"
  end

  def promote_move(player, col, move_type)
    if player == :white
      from_row = 6
      to_row = 7
    else
      from_row = 1
      to_row = 0
    end

    if move_type == :promote_rook
      new_piece = Rook.new(player, to_row, col)
    elsif move_type == :promote_knight
      new_piece = Knight.new(player, to_row, col)
    elsif move_type == :promote_bishop
      new_piece = Bishop.new(player, to_row, col)
    elsif move_type == :promote_queen
      new_piece = Queen.new(player, to_row, col)
    end

    board[from_row][col] = nil
    board[to_row][col] = new_piece

    messages << "MOVE: #{player.capitalize} promoted Pawn to #{new_piece.class} at #{indices_to_chess_coords(to_row, col)}"
  end

  def passant_move(player, from_row, from_col, to_row, to_col)
    if player == :white
      from_row = 4
      to_row = 5
    else
      from_row = 3
      to_row = 2
    end

    # Piece which is moving
    from_piece = board[from_row][from_col].dup
    from_piece.move(to_row, to_col)

    # Piece which is being captured en passant
    captured_piece = board[from_row][to_col].dup
    captured_pieces[captured_piece.team] << captured_piece

    # Actually move the pieces
    board[from_row][from_col] = nil
    board[to_row][to_col] = from_piece
    board[from_row][to_col] = nil

    messages << "MOVE: #{player.capitalize} captured Pawn en passant"
  end

  def resign(player)
    messages << "RESIGNATION: The player with the #{player.capitalize} pieces has resigned!"

    if player == :white
      declare_victory(:black)
    else
      declare_victory(:white)
    end
  end

  def declare_victory(player)
    self.game_state = "#{player}_win".to_sym
    messages << "WIN: The player with the #{player.capitalize} pieces has won!"
  end

  def draw
    self.game_state = :draw
    messages << "DRAW: The game has ended in a draw."
  end
end
