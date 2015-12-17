require_relative './chess_piece.rb'

class Pawn < ChessPiece
  attr_accessor :passantable

  def initialize(team, row, col)
    super

    self.passantable = false
  end

  def move_ok?(new_row, new_col, move_type = :normal)
    # Unlike the other pieces, the pawn DOES NOT use absolute value for these
    col_move = new_col - col
    row_move = new_row - row

    # Switch sign if black team (for black "forward" is negative)
    row_move = -row_move if team == :black

    # Check if move type is normal or capture
    if move_type == :normal
      if first_move
        if col_move == 0 && (1..2).include?(row_move)
          true
        else
          # illegal move for pawn
          false
        end
      elsif col_move == 0 && row_move == 1
        true
      else
        # illegal move for pawn
        false
      end
    elsif move_type == :capture
      if col_move.abs == 1 && row_move == 1
        true
      else
        # illegal move for pawn capture
        false
      end
    elsif move_type == :passant
      if col_move.abs == 1 && row_move == 1
        true
      else
        # puts "illegal move for en passant pawn capture"
        false
      end
    elsif move_type.to_s[0..6] == 'promote'
      if col_move == 0 && row_move == 1
        if team == :black && new_row == 0
          true
        elsif team == :white && new_row == 7
          true
        else
          # it isn't really a promotion and should have failed already...
          false
        end
      else
        # illegal move for pawn
        false
      end
    else
      # the move type isn't accepted
      false
    end
  end

  # Method called by the board when the piece is moved
  def move(to_row, to_col)
    # "passantable" is the quality of being able to be captured "en passant"
    # set passantable, if passantable set un-passantable
    if (to_row - self.row).abs == 2
      self.passantable = true
    elsif passantable
      self.passantable = false
    end

    super
  end

  def controlled_squares
    if team == :white
      [ [ [row+1,col+1] ], [ [row+1,col] ], [ [row+1,col-1] ] ]
    else
      [ [ [row-1,col+1] ], [ [ [row-1,col] ] ], [ [row-1,col-1] ] ]
    end
  end
end
