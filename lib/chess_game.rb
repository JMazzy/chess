require_relative './pawn.rb'
require_relative './king.rb'
require_relative './queen.rb'
require_relative './bishop.rb'
require_relative './knight.rb'
require_relative './rook.rb'
require_relative './chess_board.rb'

class ChessGame
  # game states are :playing, :check, :white_win, :black_win, :draw

  attr_accessor :board,
                :selected,
                :current_player,
                :selecting,
                :moving,
                :game_state,
                :messages

  def initialize(board_type = :standard)
    self.board = ChessBoard.new

    self.board.fill if board_type == 'standard' || board_type == :standard

    self.selected = nil

    self.game_state = :playing

    self.messages = ["BEGIN: It's on!"]

    self.current_player = :white
    self.selecting = false
    self.moving = false
  end

  def handle_selection(selection)
    if select(current_player,selection)
      # turn selecting off
      self.selecting = false
      # turn moving on
      self.moving = true
      return :select_success
    else
      return :select_fail
    end
  end

  def handle_moving(move)
    # complete the move
    if move(current_player,move)
      # if move is valid
      # moving off
      self.moving = false
      self.selecting = true

      # switch players
      switch_player
      return :move_success
    else
      revert
      return :move_fail
    end
  end

  def handle_mate
    if mate?(current_player)
      if game_state == "check_#{current_player}".to_sym
        checkmate(current_player)
      else
        stalemate(current_player)
      end
    end
  end

  def revert
    self.selecting = false
    self.moving = false
  end

  def update
    if selecting == moving
      self.selecting = true
      self.moving = false
    end
  end

  def switch_player
    if current_player == :white
      self.current_player = :black
    else
      self.current_player = :white
    end

    piece_sensing

    handle_mate
  end

  def board_square(coord_string)
    if coords = chess_coords_to_indices(coord_string)
      row = coords[0]
      col = coords[1]

      board.square(row,col)
    end
  end

  def set_piece(team, coord_string, piece_class)
    if coords = chess_coords_to_indices(coord_string)
      row = coords[0]
      col = coords[1]

      board.set_piece(row, col, team, piece_class)
      return true
    else
      return false
    end
  end

  def select_ok?(player, row, col)
    if board.in_bounds?(row,col)
      if board.piece_exists?(row,col)
        # Make sure the piece belongs to the current player
        if board.square(row,col).team == player
          messages << "SELECTION: #{player.to_s.capitalize} selected #{board.square(row,col).class} at #{indices_to_chess_coords(row, col)}"
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
    if board.square(from_row,from_col).class == Knight
      return true
    else
      # Check for pieces on intervening squares
      # The single step corresponding to the move (-1, 0, 1)
      row_step = to_row <=> from_row
      col_step = to_col <=> from_col

      temp_row = from_row + row_step
      temp_col = from_col + col_step

      until temp_row == to_row && temp_col == to_col
        if board.in_bounds?(temp_row,temp_col)

          # if a piece is there
          if board.square(temp_row,temp_col)
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
  def piece_sensing
    # iterate through each piece on the board
    board.each do |origin_piece|
      if !!origin_piece

        # clear the piece's sensing data before populating
        origin_piece.clear_possible_moves
        origin_piece.clear_pieces_in_range

        # iterate through each potential direction of movement
        origin_piece.controlled_squares.each do |direction_of_movement|
          # iterate through coordinates moving away from the piece
          direction_of_movement.each do |test_coords|
            if (  test_coords &&
                  board.in_bounds?(test_coords[0],test_coords[1]) )

              # set row and column variables for convenience and clarity
              test_row = test_coords[0]
              test_col = test_coords[1]

              # Call the possible move detection method
              detect_possible_move(origin_piece,test_row,test_col)

              # Call the piece detection method and break if it succeeds;
              # Once a piece is found, no more moves in that direction are valid
              break if detect_piece_in_range(origin_piece, test_row, test_col)
            end
          end
        end
      end
    end
    check_for_check(current_player)
  end

  # Determines whether the origin piece can complete a move to the given coordinates
  def detect_possible_move(origin_piece, test_row, test_col)
    if  !board.piece_exists?(test_row,test_col) ||
        board.piece_team(test_row,test_col) != board.piece_team(origin_piece.row,origin_piece.col)
      move_string = indices_to_chess_coords(test_row,test_col)
      if origin_piece.class == Pawn
        if  test_col == origin_piece.col && !board.piece_exists?(test_row,test_col) ||
            test_col != origin_piece.col && board.piece_exists?(test_row,test_col)
          origin_piece.add_possible_move(move_string)
          true
        else
          false
        end
      else
        origin_piece.add_possible_move(move_string)
        true
      end
    else
      false
    end
  end

  def detect_piece_in_range(origin_piece, test_row, test_col)
    if board.piece_exists?(test_row,test_col)
      # The string to add to pieces in range
      piece_string = find_piece_string(test_row,test_col)

      # Add the piece to the origin_pieces pieces in range
      origin_piece.add_piece_in_range(piece_string)

      true
    else
      false
    end
  end

  def check_for_check(team)
    self.game_state = :playing

    if team == :white
      other_team = :black
    else
      other_team = :white
    end

    board.each do |origin_piece|
      if origin_piece && origin_piece.team == other_team
        origin_piece.pieces_in_range.each do |piece_string|
          m = piece_string.match(/(\w)(\w)(\w\d)/)
          if m[1] == team.to_s[0].upcase && m[2] == "K"
            self.game_state = "check_#{team}".to_sym
          end
        end
      end
    end
  end

  # Returns true if that move does not result in check
  def safe_move?( team, from_row,from_col, to_row, to_col)
    backup_board = Marshal.load(Marshal.dump(board))

    # try the move
    board.move_piece(from_row,from_col,to_row,to_col)
    piece_sensing

    if game_state == "check_#{team}".to_sym
      result = false
    else
      result = true
    end

    # switch back to the backup board
    board.move_piece(to_row,to_col,from_row,from_col)
    self.board = backup_board
    piece_sensing

    # Return the result of this check
    result
  end

  def mate?(team)
    # Iterate through each piece on the board
    board.each do |origin_piece|

      # Only consider valid pieces which belong to the current player
      if !!origin_piece && origin_piece.team == current_player

        # Consider all possible moves for that piece
        origin_piece.possible_moves.each do |possible_move|

          # Retrieve the destination coordinates
          move_coords = chess_coords_to_indices(possible_move)

          #Check if the move is safe (does not result in check)
          if safe_move?(team, origin_piece.row, origin_piece.col, move_coords[0], move_coords[1])
            # If ANY move is safe, it is not a mate
            return false
          end
        end
      end
    end

    # If NO moves are safe, it is a mate
    return true
  end

  def find_piece_string(row,col)
    team_marker = find_team_marker(board.piece_team(row,col))
    piece_marker = find_piece_marker(board.piece_class(row,col))
    coordinates = indices_to_chess_coords(row,col)
    "#{team_marker}#{piece_marker}#{coordinates}"
  end

  def find_piece_marker(piece_class)
    if piece_class == NilClass
      "0"
    elsif piece_class == Knight
      "N"
    else
      piece_class.to_s[0]
    end
  end

  def find_team_marker(piece_team)
    if piece_team == :none
      "0"
    else
      piece_team.to_s[0].upcase
    end
  end

  def castle_type(player, coord_string)
    if player == :white
      row = 0
    else
      row = 7
    end

    if coord_string == '0-0'
      king = board.square(row,4)
      rook = board.square(row,7)
      if king.first_move && rook.first_move
        :castle_ks
      else
        :illegal
      end
    elsif coord_string == '0-0-0'
      king = board.square(row,4)
      rook = board.square(row,0)
      if king.first_move && rook.first_move
        :castle_qs
      else
        :illegal
      end
    else
      :illegal
    end
  end

  def pawn_move_type(player, coord_string, from_row, _from_col, to_row, to_col)
    if ((player == :white && from_row == 4) ||
      (player == :black && from_row == 3)) &&
       board.square(from_row,to_col) && board.square(from_row,to_col).passantable
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
  end

  def capture_move_type(player, _from_row, _from_col, to_row, to_col)
    to_square = board.square(to_row,to_col)

    if to_square.team != player
      :capture
    else
      messages << 'ERROR: You cannot capture your own piece!'
      :illegal
    end
  end

  def find_move_type(player, coord_string)
    from_row = selected[0]
    from_col = selected[1]
    from_piece = board.square(from_row,from_col)

    if coords = chess_coords_to_indices(coord_string)
      to_row = coords[0]
      to_col = coords[1]

      # Make sure the move is in the bounds of the board
      if board.in_bounds?(to_row, to_col)

        # Make sure the path is clear for that piece to move
        if path_clear?(from_row, from_col, to_row, to_col)

          # Make sure the move does not put own king in check
          if safe_move?(player, from_row, from_col, to_row, to_col)
            # if square is occupied (not nil)
            if board.piece_exists?(to_row,to_col)
              # parses :capture xor :illegal
              capture_move_type(player, from_row, from_col, to_row, to_col)
            elsif from_piece.class == Pawn
              # Pawns have additional non-capture move types to parse
              pawn_move_type(player, coord_string, from_row, from_col, to_row, to_col)
            else
              # Not a capture
              :normal
            end
          else
            messages << "ERROR: You cannot put yourself into check!"
            :illegal
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
      :resignation
    else
      messages << 'ERROR: Bad move input!'
      :illegal
    end
  end

  def move(player, coord_string)
    from_row = selected[0]
    from_col = selected[1]
    from_piece = board.square(from_row,from_col)

    move_type = find_move_type(player, coord_string)

    if move_type == :illegal || move_type == :resignation
      false
    else
      if move_type.to_s[0..5] == 'castle'
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
  end

  def normal_move(player, coord_string, from_row, from_col, to_row, to_col)
    from_piece = board.square(from_row,from_col)

    # get the captured piece (nil if no capture)
    captured_piece = board.square(to_row,to_col)

    if !!captured_piece # if the square is occupied (not nil)
      board.capture_piece(to_row,to_col)
      move_phrase = "captured #{captured_piece.class} at #{coord_string}"
    else
      move_phrase = "to #{coord_string}"
    end

    # actually move the piece, leaving a blank square
    board.move_piece(from_row,from_col,to_row,to_col)

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

    board.move_piece(row,from_col,row,to_col)

    board.move_piece(row,rook_from_col,row,rook_to_col)

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
      new_piece = Rook
    elsif move_type == :promote_knight
      new_piece = Knight
    elsif move_type == :promote_bishop
      new_piece = Bishop
    elsif move_type == :promote_queen
      new_piece = Queen
    end

    board.set_piece(to_row,col,player,new_piece)

    messages << "MOVE: #{player.capitalize} promoted Pawn to #{new_piece} at #{indices_to_chess_coords(to_row, col)}"
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
    from_piece = board.square(from_row,from_col).dup
    from_piece.move(to_row, to_col)

    # Piece which is being captured en passant
    board.capture_piece(from_row,to_col)

    # Actually move the piece
    board.move_piece(from_row,from_col,to_row,to_col)

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

  def stalemate(player)
    draw
    messages << "STALEMATE: #{player.capitalize} is in a stalemate."
  end

  def checkmate(player)
    if player == :white
      declare_victory(:black)
    else
      declare_victory(:white)
    end

    messages << "CHECKMATE: #{player.capitalize} won in a checkmate!"
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
