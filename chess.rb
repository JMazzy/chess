require './chess_board.rb'

class Chess

  attr_accessor :current_player

  def initialize
    @chess_board = ChessBoard.new
    print @chess_board.board_state
    self.current_player = :white
  end

  def ask_selection
    print "#{current_player.to_s.capitalize} select piece to move: "
    gets.chomp
  end

  def ask_move
    print "#{current_player.to_s.capitalize} choose where you want to move: "
    gets.chomp
  end

  def update
    if @chess_board.select(ask_selection)
      if @chess_board.move(ask_move)
        
      else
        puts "invalid move"
      end
    else 
      puts "invalid selection"
    end
    
    if current_player == :white
      self.current_player = :black
    else
      self.current_player = :white
    end
  end

  def draw
    print @chess_board.board_state
  end

  def game_loop
    loop do
      update
      draw
    end
  end
end

chess = Chess.new
#chess.game_loop
