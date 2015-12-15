class ChessPiece

  attr_accessor :team, :col, :row, :first_move, :pieces_in_range, :possible_moves, :threats

  def initialize(team,row,col)
    self.team = team
    self.col = col
    self.row = row
    self.first_move = true
    self.pieces_in_range = []
    self.possible_moves = []
  end

  def move(row,col)
    self.col = col
    self.row = row

    if first_move
      self.first_move = false
    end
  end

  def clear_pieces_in_range
    self.pieces_in_range = []
  end

  def clear_possible_moves
    self.possible_moves = []
  end

  def add_piece_in_range(piece)
    self.pieces_in_range << piece
  end

  def add_possible_move(possible_move)
    self.possible_moves << possible_move
  end
end
