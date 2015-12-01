require './knight.rb'

class ChessBoard

  attr_accessor :board, :off_board, :selected
  
  def initialize
    pieces = [ Knight.new(:white, 1,0), Knight.new(:white, 6,0), Knight.new(:black, 1,7), Knight.new(:black, 6,7) ]

    @board =  [ [nil,nil,nil,nil,nil,nil,nil,nil],
                [nil,nil,nil,nil,nil,nil,nil,nil],
                [nil,nil,nil,nil,nil,nil,nil,nil],
                [nil,nil,nil,nil,nil,nil,nil,nil],
                [nil,nil,nil,nil,nil,nil,nil,nil],
                [nil,nil,nil,nil,nil,nil,nil,nil],
                [nil,nil,nil,nil,nil,nil,nil,nil],
                [nil,nil,nil,nil,nil,nil,nil,nil] ]

    pieces.each do |piece|
      self.board[piece.col][piece.row] = piece
    end

    self.selected = nil

    @off_board = { white: [], black: [] }
  end

  def show
    board.each do |row|
      row.each do |square|
        if square.class == Knight
          print " K "
        else
          print " - "
        end
      end
      puts "\n"
    end
  end

  def select(col,row)
    unselect

    if col >= 0 and col < 8 and row >=0 and row < 8
      if board[col][row]
        self.selected = [col,row]
        board[col][row].select
        "#{board[col][row].class} selected (#{col}, #{row})"
      else
        "cannot select empty square"
      end
    else
      "square doesn't exist"
    end
  end

  def unselect
    if selected
      col = selected[0]
      row = selected[1]
      board[col][row].unselect
      self.selected = nil
    end
  end
end
