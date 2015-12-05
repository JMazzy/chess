class ChessPiece
  
  attr_accessor :team, :col, :row

  def initialize(team,row,col)
    self.team = team
    self.col = col
    self.row = row
  end

  def move(row,col)
    self.col = col
    self.row = row
  end
end