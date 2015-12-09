class ChessPiece

  attr_accessor :team, :col, :row, :first_move, :pieces_in_range

  def initialize(team,row,col)
    self.team = team
    self.col = col
    self.row = row
    self.first_move = true
    self.pieces_in_range = []
  end

  def move(row,col)
    self.col = col
    self.row = row

    if first_move
      self.first_move = false
    end
  end
end
