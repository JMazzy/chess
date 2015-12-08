require 'rspec'
require_relative "../lib/chess_board.rb"

describe "selection should work" do
  it "disallows blank selection" do
    test_board = ChessBoard.new(:standard)
    expect(test_board.select_ok?(:white, "f5")).to eq false
    expect(test_board.selected).to eq nil
  end

  it "disallows selecting opposing piece" do
    test_board = ChessBoard.new(:standard)
    expect(test_board.select_ok?(:white, "d7")).to eq false
    expect(test_board.selected).to eq nil
  end

  it "allows valid selection" do
    test_board = ChessBoard.new(:standard)
    expect(test_board.select(:black, "d7")).to eq true
    expect(test_board.selected).to eq [6,3]
  end
end

describe "pieces should move correctly" do
  describe "pawn" do
    it "moves one space forward" do
      test_board = ChessBoard.new(:standard)
      expect(test_board.board_square("d2").class).to eq Pawn
      expect(test_board.select(:white, "d2")).to eq true
      expect(test_board.move(:white, "d3")).to eq true
      expect(test_board.board_square("d3").class).to eq Pawn
    end

    it "moves two spaces forward on first move only" do
      test_board = ChessBoard.new(:standard)
      expect(test_board.board_square("d2").class).to eq Pawn

      # First move
      expect(test_board.select(:white, "d2")).to eq true
      expect(test_board.move(:white, "d4")).to eq true
      expect(test_board.board_square("d4").class).to eq Pawn

      # Second move
      expect(test_board.select(:white, "d4")).to eq true
      expect(test_board.move(:white, "d6")).to eq false
      expect(test_board.board_square("d6")).to eq nil
      expect(test_board.board_square("d4").class).to eq Pawn
    end

    it "does not move in any other direction" do
      test_board = ChessBoard.new(:blank)

      expect(test_board.set_piece(:white, "e4", Pawn)).to eq true

      # Check moves to all spaces except starting space and valid move
      ('d'..'f').each do |col|
        (3..5).each do |row|
          unless ( col == 'e' && ( row == 5 || row == 4 ) )
            expect(test_board.select(:white, "e4")).to eq true
            expect(test_board.move(:white, "#{col}#{row}")).to eq false
            expect(test_board.board_square("#{col}#{row}")).to eq nil
            expect(test_board.board_square("e4").class).to eq Pawn
          end
        end
      end
    end

    it "does not move any other amount of spaces" do
      test_board = ChessBoard.new(:blank)

      expect(test_board.set_piece(:white, "e2", Pawn)).to eq true

      (3..6).each do |num|
        expect(test_board.select(:white, "e2")).to eq true
        expect(test_board.move(:white, "e#{2+num}")).to eq false
        expect(test_board.board_square("e#{2+num}")).to eq nil
        expect(test_board.board_square("e2").class).to eq Pawn
      end
    end

    it "moves diagonally only when capturing" do
      test_board = ChessBoard.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, "b2", Pawn)).to eq true
      expect(test_board.set_piece(:black, "c3", Pawn)).to eq true

      # Move white piece to capture black piece
      expect(test_board.select(:white, "b2")).to eq true
      expect(test_board.move(:white, "c3")).to eq true

      # Make sure pieces are where they should be
      expect(test_board.board_square("b2").class).to eq NilClass
      expect(test_board.board_square("c3").class).to eq Pawn
      expect(test_board.board_square("c3").team).to eq :white
      expect(test_board.captured_pieces[:black][0].class).to eq Pawn
    end

    it "can take another pawn en passant" do
      pending #NEEDS TO BE IMPLEMENTED
      test_board = ChessBoard.new(:blank)

      expect(test_board.set_piece(:white, "a2", Pawn)).to eq true
      expect(test_board.set_piece(:black, "b4", Pawn)).to eq true

      # White moves forward, passing by black pawn
      expect(test_board.select(:white, "a2")).to eq true
      expect(test_board.move(:white, "a4")).to eq true

      # Black is able to capture en passant
      expect(test_board.select(:black, "b4")).to eq true
      expect(test_board.move(:black, "a3")).to eq true

      # White pawn is no longer there
      expect(test_board.board_square("a4").class).to eq NilClass

      # Black pawn is on the square white pawn passed through
      expect(test_board.board_square("a3").class).to eq Pawn
      expect(test_board.board_square("a3").team).to eq :black
    end

    it "is promoted upon reaching far rank" do
      test_board = ChessBoard.new(:blank)

      expect(test_board.set_piece(:white, "b7", Pawn)).to eq true
      expect(test_board.set_piece(:black, "c2", Pawn)).to eq true
      expect(test_board.set_piece(:white, "d7", Pawn)).to eq true
      expect(test_board.set_piece(:black, "e2", Pawn)).to eq true

      expect(test_board.select(:white, "b7")).to eq true
      expect(test_board.move(:white, "b8Q")).to eq true
      expect(test_board.select(:black, "c2")).to eq true
      expect(test_board.move(:black, "c1B")).to eq true
      expect(test_board.select(:white, "d7")).to eq true
      expect(test_board.move(:white, "d8N")).to eq true
      expect(test_board.select(:black, "e2")).to eq true
      expect(test_board.move(:black, "e1R")).to eq true

      expect(test_board.board_square("b8").class).to eq Queen
      expect(test_board.board_square("c1").class).to eq Bishop
      expect(test_board.board_square("d8").class).to eq Knight
      expect(test_board.board_square("e1").class).to eq Rook
    end

    it "doesn't move through pieces" do
      test_board = ChessBoard.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, "b2", Pawn)).to eq true
      expect(test_board.set_piece(:black, "b3", Pawn)).to eq true

      # try to move white piece through black piece
      expect(test_board.select(:white, "b2")).to eq true
      expect(test_board.move(:white, "b4")).to eq false

      # Make sure pieces are still where they started
      expect(test_board.board_square("b2").class).to eq Pawn
      expect(test_board.board_square("b2").team).to eq :white
      expect(test_board.board_square("b3").class).to eq Pawn
      expect(test_board.board_square("b3").team).to eq :black
    end
  end

  describe "rook" do
    it "moves up/down/left/right" do
      test_board = ChessBoard.new(:blank)

      # Place the piece
      expect(test_board.set_piece(:white, "a1", Rook)).to eq true

      # Move up
      expect(test_board.select(:white, "a1")).to eq true
      expect(test_board.move(:white, "a4")).to eq true
      expect(test_board.board_square("a4").class).to eq Rook

      # Move right
      expect(test_board.select(:white, "a4")).to eq true
      expect(test_board.move(:white, "g4")).to eq true
      expect(test_board.board_square("g4").class).to eq Rook

      # Move down
      expect(test_board.select(:white, "g4")).to eq true
      expect(test_board.move(:white, "g2")).to eq true
      expect(test_board.board_square("g2").class).to eq Rook

      # Move left
      expect(test_board.select(:white, "g2")).to eq true
      expect(test_board.move(:white, "b2")).to eq true
      expect(test_board.board_square("b2").class).to eq Rook
    end

    it "does not move diagonally" do
      test_board = ChessBoard.new(:blank)

      # Place the piece
      expect(test_board.set_piece(:white, "c4", Rook)).to eq true

      # Move up/right
      expect(test_board.select(:white, "c4")).to eq true
      expect(test_board.move(:white, "e6")).to eq false
      expect(test_board.board_square("e6").class).to eq NilClass

      # Move up/left
      expect(test_board.select(:white, "c4")).to eq true
      expect(test_board.move(:white, "a6")).to eq false
      expect(test_board.board_square("a6").class).to eq NilClass

      # Move down/left
      expect(test_board.select(:white, "c4")).to eq true
      expect(test_board.move(:white, "a2")).to eq false
      expect(test_board.board_square("a2").class).to eq NilClass

      # Move down/right
      expect(test_board.select(:white, "c4")).to eq true
      expect(test_board.move(:white, "e2")).to eq false
      expect(test_board.board_square("e2").class).to eq NilClass

      # Rook should still be in its starting position
      expect(test_board.board_square("c4").class).to eq Rook
    end

    it "captures a piece" do
      test_board = ChessBoard.new(:blank)

      # Place the piece
      expect(test_board.set_piece(:white, "c4", Rook)).to eq true
      expect(test_board.set_piece(:black, "c8", Pawn)).to eq true

      # Capture a piece
      expect(test_board.select(:white, "c4")).to eq true
      expect(test_board.move(:white, "c8")).to eq true

      # Make sure pieces are where they should be
      expect(test_board.board_square("c4").class).to eq NilClass
      expect(test_board.board_square("c8").class).to eq Rook
      expect(test_board.board_square("c8").team).to eq :white
      expect(test_board.captured_pieces[:black][0].class).to eq Pawn
    end

    it "doesn't move through pieces" do
      test_board = ChessBoard.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, "b2", Rook)).to eq true
      expect(test_board.set_piece(:black, "b5", Pawn)).to eq true

      # try to move piece through other piece
      expect(test_board.select(:white, "b2")).to eq true
      expect(test_board.move(:white, "b8")).to eq false

      # Make sure pieces are still where they started
      expect(test_board.board_square("b2").class).to eq Rook
      expect(test_board.board_square("b2").team).to eq :white
      expect(test_board.board_square("b5").class).to eq Pawn
      expect(test_board.board_square("b5").team).to eq :black
    end
  end

  describe "knight" do
    it "moves to the correct places" do
      test_board = ChessBoard.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, "b1", Knight)).to eq true

      expect(test_board.select(:white, "b1")). to eq true
      expect(test_board.move(:white, "c3")). to eq true
      expect(test_board.select(:white, "c3")). to eq true
      expect(test_board.move(:white, "b5")). to eq true
      expect(test_board.select(:white, "b5")). to eq true
      expect(test_board.move(:white, "d4")). to eq true
      expect(test_board.select(:white, "d4")). to eq true
      expect(test_board.move(:white, "e2")). to eq true

      expect(test_board.board_square("e2").class).to eq Knight
    end

    it "does not move elsewhere" do
      test_board = ChessBoard.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, "c3", Knight)).to eq true

      # Can't move one square ahead
      expect(test_board.select(:white, "c3")). to eq true
      expect(test_board.move(:white, "c4")). to eq false

      # Can't move to an arbitrary location
      expect(test_board.select(:white, "c3")). to eq true
      expect(test_board.move(:white, "d8")). to eq false

      # Can't move two spaces ahead
      expect(test_board.select(:white, "c3")). to eq true
      expect(test_board.move(:white, "e3")). to eq false

      # Should still be in starting location
      expect(test_board.board_square("c3").class).to eq Knight
    end

    it "captures a piece" do
      test_board = ChessBoard.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, "b1", Knight)).to eq true
      expect(test_board.set_piece(:black, "c3", Pawn)).to eq true

      expect(test_board.select(:white, "b1")). to eq true
      expect(test_board.move(:white, "c3")). to eq true

      expect(test_board.board_square("c3").class).to eq Knight
      expect(test_board.captured_pieces[:black][0].class).to eq Pawn
    end

    it "can jump over a piece" do
      test_board = ChessBoard.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, "b1", Knight)).to eq true
      expect(test_board.set_piece(:white, "b2", Pawn)).to eq true

      # jump over the pawn
      expect(test_board.select(:white, "b1")). to eq true
      expect(test_board.move(:white, "c3")). to eq true

      # jump should be successful
      expect(test_board.board_square("c3").class).to eq Knight
      expect(test_board.board_square("b2").class).to eq Pawn
    end
  end

  describe "bishop should move correctly" do
    it "moves diagonally" do
    end

    it "does not move up/down/left/right" do
    end

    it "captures a piece" do
    end

    it "does not move through other pieces" do
    end
  end

  describe "queen should move correctly" do
    it "moves diagonally" do
    end

    it "moves up/down/left/right" do
    end

    it "captures a piece" do
    end

    it "does not move through other pieces" do
    end
  end

  describe "king should move correctly" do
    it "moves diagonally one space only" do
    end

    it "cannot move more than one space diagonally" do
    end

    it "moves up/down/left/right one space only" do
    end

    it "cannot move more than one space" do
    end

    it "captures a piece" do
    end

    it "castles with a rook kingside" do
      test_board = ChessBoard.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, "h1", Rook)).to eq true
      expect(test_board.set_piece(:white, "e1", King)).to eq true
      expect(test_board.set_piece(:black, "h8", Rook)).to eq true
      expect(test_board.set_piece(:black, "e8", King)).to eq true

      # Castle kingside
      expect(test_board.select(:white, "e1")).to eq true
      expect(test_board.move(:white, "0-0")).to eq true
      expect(test_board.select(:black, "e8")).to eq true
      expect(test_board.move(:black, "0-0")).to eq true

      # make sure pieces are in the right places
      expect(test_board.board_square("g1").class).to eq King
      expect(test_board.board_square("f1").class).to eq Rook
      expect(test_board.board_square("g8").class).to eq King
      expect(test_board.board_square("f8").class).to eq Rook
    end

    it "castles with a rook queenside" do
      test_board = ChessBoard.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, "a1", Rook)).to eq true
      expect(test_board.set_piece(:white, "e1", King)).to eq true
      expect(test_board.set_piece(:black, "a8", Rook)).to eq true
      expect(test_board.set_piece(:black, "e8", King)).to eq true

      # Castle queenside
      expect(test_board.select(:white, "e1")).to eq true
      expect(test_board.move(:white, "0-0-0")).to eq true
      expect(test_board.select(:black, "e8")).to eq true
      expect(test_board.move(:black, "0-0-0")).to eq true

      # Make sure pieces are in the right places
      expect(test_board.board_square("c1").class).to eq King
      expect(test_board.board_square("d1").class).to eq Rook
      expect(test_board.board_square("c8").class).to eq King
      expect(test_board.board_square("d8").class).to eq Rook
    end
  end
end

describe "pieces should sense nearby pieces" do
  describe "pieces should be aware of pieces in taking range" do
    it "pawn should know about other pieces in range" do
    end

    it "rook should know about other pieces in range" do
    end

    it "knight should know about other pieces in range" do
    end

    it "bishop should know about other pieces in range" do
    end

    it "queen should know about other pieces in range" do
    end

    it "king should know about other pieces in range" do
    end
  end

  describe "game check state" do
    it "a piece detecting an opposing king in range should put the game in check" do
    end

    it "king should know about pieces putting it in check" do
    end

    it "a king moving out of harm's way should take the game out of check" do
    end

    it "should detect a checkmate" do
    end

    it "a state of checkmate should end the game and declare a winner" do
    end
  end
end
