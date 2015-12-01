class ChessPiece
  
  attr_accessor :team, :col, :row, :selected

  def initialize
    self.selected = false
  end

  def select
    if !selected
      self.selected = true
    end
  end

  def unselect
    if selected
      self.selected = false
    end
  end
end