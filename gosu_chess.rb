require 'gosu'

require './chess_board.rb'

class Chess < Gosu::Window
  def initialize
    super 640, 640
    self.caption = "Chess"

    @chess_board = ChessBoard.new
    @chess_board.show
  end

  def update

  end

  def draw
    
  end
end

window = Chess.new
window.show
@chess_board.show
