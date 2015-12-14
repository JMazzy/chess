require 'rspec'
require_relative "../lib/chess_game.rb"

describe "pieces should move correctly -" do
  describe "pawn -" do
    it "moves one space forward" do
      test_game = ChessGame.new(:standard)
      expect(test_game.board_square("d2").class).to eq Pawn
      expect(test_game.select(:white, "d2")).to eq true
      expect(test_game.move(:white, "d3")).to eq true
      expect(test_game.board_square("d3").class).to eq Pawn
    end

    it "moves two spaces forward on first move only" do
      test_game = ChessGame.new(:standard)
      expect(test_game.board_square("d2").class).to eq Pawn

      # First move
      expect(test_game.select(:white, "d2")).to eq true
      expect(test_game.move(:white, "d4")).to eq true
      expect(test_game.board_square("d4").class).to eq Pawn

      # Second move
      expect(test_game.select(:white, "d4")).to eq true
      expect(test_game.move(:white, "d6")).to eq false
      expect(test_game.board_square("d6")).to eq nil
      expect(test_game.board_square("d4").class).to eq Pawn
    end

    it "does not move in any other direction" do
      test_game = ChessGame.new(:blank)

      expect(test_game.set_piece(:white, "e4", Pawn)).to eq true

      # Check moves to all spaces except starting space and valid move
      ('d'..'f').each do |col|
        (3..5).each do |row|
          unless ( col == 'e' && ( row == 5 || row == 4 ) )
            expect(test_game.select(:white, "e4")).to eq true
            expect(test_game.move(:white, "#{col}#{row}")).to eq false
            expect(test_game.board_square("#{col}#{row}")).to eq nil
            expect(test_game.board_square("e4").class).to eq Pawn
          end
        end
      end
    end

    it "does not move any other amount of spaces" do
      test_game = ChessGame.new(:blank)

      expect(test_game.set_piece(:white, "e2", Pawn)).to eq true

      (3..6).each do |num|
        expect(test_game.select(:white, "e2")).to eq true
        expect(test_game.move(:white, "e#{2+num}")).to eq false
        expect(test_game.board_square("e#{2+num}")).to eq nil
        expect(test_game.board_square("e2").class).to eq Pawn
      end
    end

    it "moves diagonally only when capturing" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "b2", Pawn)).to eq true
      expect(test_game.set_piece(:black, "c3", Pawn)).to eq true

      # Move white piece to capture black piece
      expect(test_game.select(:white, "b2")).to eq true
      expect(test_game.move(:white, "c3")).to eq true

      # Make sure pieces are where they should be
      expect(test_game.board_square("b2").class).to eq NilClass
      expect(test_game.board_square("c3").class).to eq Pawn
      expect(test_game.board_square("c3").team).to eq :white
      expect(test_game.board.captured_pieces[:black][0].class).to eq Pawn

      test_game.piece_control
    end

    it "can take another pawn en passant" do
      test_game = ChessGame.new(:blank)

      expect(test_game.set_piece(:white, "a2", Pawn)).to eq true
      expect(test_game.set_piece(:black, "b4", Pawn)).to eq true

      # White moves forward, passing by black pawn
      expect(test_game.select(:white, "a2")).to eq true
      expect(test_game.move(:white, "a4")).to eq true

      # Black is able to capture en passant
      expect(test_game.select(:black, "b4")).to eq true
      expect(test_game.move(:black, "a3")).to eq true

      # White pawn is no longer there
      expect(test_game.board_square("a4").class).to eq NilClass

      # Black pawn is on the square white pawn passed through
      expect(test_game.board_square("a3").class).to eq Pawn
      expect(test_game.board_square("a3").team).to eq :black
    end

    it "is promoted upon reaching far rank" do
      test_game = ChessGame.new(:blank)

      expect(test_game.set_piece(:white, "b7", Pawn)).to eq true
      expect(test_game.set_piece(:black, "c2", Pawn)).to eq true
      expect(test_game.set_piece(:white, "d7", Pawn)).to eq true
      expect(test_game.set_piece(:black, "e2", Pawn)).to eq true

      expect(test_game.select(:white, "b7")).to eq true
      expect(test_game.move(:white, "b8Q")).to eq true
      expect(test_game.select(:black, "c2")).to eq true
      expect(test_game.move(:black, "c1B")).to eq true
      expect(test_game.select(:white, "d7")).to eq true
      expect(test_game.move(:white, "d8N")).to eq true
      expect(test_game.select(:black, "e2")).to eq true
      expect(test_game.move(:black, "e1R")).to eq true

      expect(test_game.board_square("b8").class).to eq Queen
      expect(test_game.board_square("c1").class).to eq Bishop
      expect(test_game.board_square("d8").class).to eq Knight
      expect(test_game.board_square("e1").class).to eq Rook
    end

    it "doesn't move through pieces" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "b2", Pawn)).to eq true
      expect(test_game.set_piece(:black, "b3", Pawn)).to eq true

      # try to move white piece through black piece
      expect(test_game.select(:white, "b2")).to eq true
      expect(test_game.move(:white, "b4")).to eq false

      # Make sure pieces are still where they started
      expect(test_game.board_square("b2").class).to eq Pawn
      expect(test_game.board_square("b2").team).to eq :white
      expect(test_game.board_square("b3").class).to eq Pawn
      expect(test_game.board_square("b3").team).to eq :black
    end
  end

  describe "rook -" do
    it "moves up/down/left/right" do
      test_game = ChessGame.new(:blank)

      # Place the piece
      expect(test_game.set_piece(:white, "a1", Rook)).to eq true

      # Move up
      expect(test_game.select(:white, "a1")).to eq true
      expect(test_game.move(:white, "a4")).to eq true
      expect(test_game.board_square("a4").class).to eq Rook

      # Move right
      expect(test_game.select(:white, "a4")).to eq true
      expect(test_game.move(:white, "g4")).to eq true
      expect(test_game.board_square("g4").class).to eq Rook

      # Move down
      expect(test_game.select(:white, "g4")).to eq true
      expect(test_game.move(:white, "g2")).to eq true
      expect(test_game.board_square("g2").class).to eq Rook

      # Move left
      expect(test_game.select(:white, "g2")).to eq true
      expect(test_game.move(:white, "b2")).to eq true
      expect(test_game.board_square("b2").class).to eq Rook
    end

    it "does not move diagonally" do
      test_game = ChessGame.new(:blank)

      # Place the piece
      expect(test_game.set_piece(:white, "c4", Rook)).to eq true

      # Move up/right
      expect(test_game.select(:white, "c4")).to eq true
      expect(test_game.move(:white, "e6")).to eq false
      expect(test_game.board_square("e6").class).to eq NilClass

      # Move up/left
      expect(test_game.select(:white, "c4")).to eq true
      expect(test_game.move(:white, "a6")).to eq false
      expect(test_game.board_square("a6").class).to eq NilClass

      # Move down/left
      expect(test_game.select(:white, "c4")).to eq true
      expect(test_game.move(:white, "a2")).to eq false
      expect(test_game.board_square("a2").class).to eq NilClass

      # Move down/right
      expect(test_game.select(:white, "c4")).to eq true
      expect(test_game.move(:white, "e2")).to eq false
      expect(test_game.board_square("e2").class).to eq NilClass

      # Rook should still be in its starting position
      expect(test_game.board_square("c4").class).to eq Rook
    end

    it "captures a piece" do
      test_game = ChessGame.new(:blank)

      # Place the piece
      expect(test_game.set_piece(:white, "c4", Rook)).to eq true
      expect(test_game.set_piece(:black, "c8", Pawn)).to eq true

      # Capture a piece
      expect(test_game.select(:white, "c4")).to eq true
      expect(test_game.move(:white, "c8")).to eq true

      # Make sure pieces are where they should be
      expect(test_game.board_square("c4").class).to eq NilClass
      expect(test_game.board_square("c8").class).to eq Rook
      expect(test_game.board_square("c8").team).to eq :white
      expect(test_game.board.captured_pieces[:black][0].class).to eq Pawn
    end

    it "doesn't move through pieces" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "b2", Rook)).to eq true
      expect(test_game.set_piece(:black, "b5", Pawn)).to eq true

      # try to move piece through other piece
      expect(test_game.select(:white, "b2")).to eq true
      expect(test_game.move(:white, "b8")).to eq false

      # Make sure pieces are still where they started
      expect(test_game.board_square("b2").class).to eq Rook
      expect(test_game.board_square("b2").team).to eq :white
      expect(test_game.board_square("b5").class).to eq Pawn
      expect(test_game.board_square("b5").team).to eq :black
    end
  end

  describe "knight -" do
    it "moves to the correct places" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "b1", Knight)).to eq true

      expect(test_game.select(:white, "b1")). to eq true
      expect(test_game.move(:white, "c3")). to eq true
      expect(test_game.select(:white, "c3")). to eq true
      expect(test_game.move(:white, "b5")). to eq true
      expect(test_game.select(:white, "b5")). to eq true
      expect(test_game.move(:white, "d4")). to eq true
      expect(test_game.select(:white, "d4")). to eq true
      expect(test_game.move(:white, "e2")). to eq true

      expect(test_game.board_square("e2").class).to eq Knight
    end

    it "does not move elsewhere" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "c3", Knight)).to eq true

      # Can't move one square ahead
      expect(test_game.select(:white, "c3")). to eq true
      expect(test_game.move(:white, "c4")). to eq false

      # Can't move to an arbitrary location
      expect(test_game.select(:white, "c3")). to eq true
      expect(test_game.move(:white, "d8")). to eq false

      # Can't move two spaces ahead
      expect(test_game.select(:white, "c3")). to eq true
      expect(test_game.move(:white, "e3")). to eq false

      # Should still be in starting location
      expect(test_game.board_square("c3").class).to eq Knight
    end

    it "captures a piece" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "b1", Knight)).to eq true
      expect(test_game.set_piece(:black, "c3", Pawn)).to eq true

      expect(test_game.select(:white, "b1")). to eq true
      expect(test_game.move(:white, "c3")). to eq true

      expect(test_game.board_square("c3").class).to eq Knight
      expect(test_game.board.captured_pieces[:black][0].class).to eq Pawn
    end

    it "can jump over a piece" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "b1", Knight)).to eq true
      expect(test_game.set_piece(:white, "b2", Pawn)).to eq true

      # jump over the pawn
      expect(test_game.select(:white, "b1")). to eq true
      expect(test_game.move(:white, "c3")). to eq true

      # jump should be successful
      expect(test_game.board_square("c3").class).to eq Knight
      expect(test_game.board_square("b2").class).to eq Pawn
    end
  end

  describe "bishop -" do
    it "moves diagonally" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "f1", Bishop)).to eq true

      expect(test_game.select(:white, "f1")). to eq true
      expect(test_game.move(:white, "a6")). to eq true
      expect(test_game.select(:white, "a6")). to eq true
      expect(test_game.move(:white, "c8")). to eq true
      expect(test_game.select(:white, "c8")). to eq true
      expect(test_game.move(:white, "h3")). to eq true
      expect(test_game.select(:white, "h3")). to eq true
      expect(test_game.move(:white, "f1")). to eq true
    end

    it "does not move up/down/left/right" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "f1", Bishop)).to eq true

      expect(test_game.select(:white, "f1")). to eq true
      expect(test_game.move(:white, "f8")). to eq false
      expect(test_game.select(:white, "f1")). to eq true
      expect(test_game.move(:white, "h1")). to eq false
    end

    it "captures a piece" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "f1", Bishop)).to eq true
      expect(test_game.set_piece(:black, "a6", Pawn)).to eq true

      expect(test_game.select(:white, "f1")). to eq true
      expect(test_game.move(:white, "a6")). to eq true

      expect(test_game.board_square("a6").class).to eq Bishop
      expect(test_game.board.captured_pieces[:black][0].class).to eq Pawn
    end

    it "does not move through other pieces" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "f1", Bishop)).to eq true
      expect(test_game.set_piece(:black, "b5", Pawn)).to eq true

      expect(test_game.select(:white, "f1")). to eq true
      expect(test_game.move(:white, "a6")). to eq false

      expect(test_game.board_square("f1").class).to eq Bishop
    end
  end

  describe "queen -" do
    it "moves diagonally" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "d1", Queen)).to eq true

      expect(test_game.select(:white, "d1")). to eq true
      expect(test_game.move(:white, "a4")). to eq true
      expect(test_game.select(:white, "a4")). to eq true
      expect(test_game.move(:white, "e8")). to eq true
      expect(test_game.select(:white, "e8")). to eq true
      expect(test_game.move(:white, "h5")). to eq true
      expect(test_game.select(:white, "h5")). to eq true
      expect(test_game.move(:white, "d1")). to eq true

      expect(test_game.board_square("d1").class).to eq Queen
    end

    it "moves up/down/left/right" do
      test_game = ChessGame.new(:blank)

      # Place the piece
      expect(test_game.set_piece(:white, "d1", Queen)).to eq true

      # Move up
      expect(test_game.select(:white, "d1")).to eq true
      expect(test_game.move(:white, "a4")).to eq true
      expect(test_game.board_square("a4").class).to eq Queen

      # Move right
      expect(test_game.select(:white, "a4")).to eq true
      expect(test_game.move(:white, "g4")).to eq true
      expect(test_game.board_square("g4").class).to eq Queen

      # Move down
      expect(test_game.select(:white, "g4")).to eq true
      expect(test_game.move(:white, "g2")).to eq true
      expect(test_game.board_square("g2").class).to eq Queen

      # Move left
      expect(test_game.select(:white, "g2")).to eq true
      expect(test_game.move(:white, "b2")).to eq true
      expect(test_game.board_square("b2").class).to eq Queen
    end

    it "captures a piece" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "d1", Queen)).to eq true
      expect(test_game.set_piece(:black, "a4", Pawn)).to eq true

      expect(test_game.select(:white, "d1")). to eq true
      expect(test_game.move(:white, "a4")). to eq true

      expect(test_game.board_square("a4").class).to eq Queen
      expect(test_game.board.captured_pieces[:black][0].class).to eq Pawn
    end

    it "does not move through other pieces" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "f1", Queen)).to eq true
      expect(test_game.set_piece(:black, "b5", Pawn)).to eq true

      expect(test_game.select(:white, "f1")). to eq true
      expect(test_game.move(:white, "a6")). to eq false

      expect(test_game.board_square("f1").class).to eq Queen
    end
  end

  describe "king -" do
    it "moves diagonally one space" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "e1", King)).to eq true

      expect(test_game.select(:white, "e1")). to eq true
      expect(test_game.move(:white, "d2")). to eq true
      expect(test_game.select(:white, "d2")). to eq true
      expect(test_game.move(:white, "e3")). to eq true
      expect(test_game.select(:white, "e3")). to eq true
      expect(test_game.move(:white, "f2")). to eq true
      expect(test_game.select(:white, "f2")). to eq true
      expect(test_game.move(:white, "g1")). to eq true

      expect(test_game.board_square("g1").class).to eq King
    end

    it "cannot move more than one space diagonally" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "e1", King)).to eq true

      expect(test_game.select(:white, "e1")). to eq true
      expect(test_game.move(:white, "g3")). to eq false

      expect(test_game.board_square("e1").class).to eq King
    end

    it "moves up/down/left/right one space" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "e1", King)).to eq true

      expect(test_game.select(:white, "e1")). to eq true
      expect(test_game.move(:white, "d1")). to eq true
      expect(test_game.select(:white, "d1")). to eq true
      expect(test_game.move(:white, "d2")). to eq true
      expect(test_game.select(:white, "d2")). to eq true
      expect(test_game.move(:white, "e2")). to eq true
      expect(test_game.select(:white, "e2")). to eq true
      expect(test_game.move(:white, "e1")). to eq true

      expect(test_game.board_square("e1").class).to eq King
    end

    it "cannot move more than one space" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "e1", King)).to eq true

      expect(test_game.select(:white, "e1")). to eq true
      expect(test_game.move(:white, "e3")). to eq false

      expect(test_game.board_square("e1").class).to eq King
    end

    it "captures a piece" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "e1", King)).to eq true
      expect(test_game.set_piece(:black, "e2", Pawn)).to eq true

      expect(test_game.select(:white, "e1")). to eq true
      expect(test_game.move(:white, "e2")). to eq true

      expect(test_game.board_square("e2").class).to eq King
      expect(test_game.board.captured_pieces[:black][0].class).to eq Pawn
    end

    it "castles with a rook kingside" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "h1", Rook)).to eq true
      expect(test_game.set_piece(:white, "e1", King)).to eq true
      expect(test_game.set_piece(:black, "h8", Rook)).to eq true
      expect(test_game.set_piece(:black, "e8", King)).to eq true

      # Castle kingside
      expect(test_game.select(:white, "e1")).to eq true
      expect(test_game.move(:white, "0-0")).to eq true
      expect(test_game.select(:black, "e8")).to eq true
      expect(test_game.move(:black, "0-0")).to eq true

      # make sure pieces are in the right places
      expect(test_game.board_square("g1").class).to eq King
      expect(test_game.board_square("f1").class).to eq Rook
      expect(test_game.board_square("g8").class).to eq King
      expect(test_game.board_square("f8").class).to eq Rook
    end

    it "castles with a rook queenside" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, "a1", Rook)).to eq true
      expect(test_game.set_piece(:white, "e1", King)).to eq true
      expect(test_game.set_piece(:black, "a8", Rook)).to eq true
      expect(test_game.set_piece(:black, "e8", King)).to eq true

      # Castle queenside
      expect(test_game.select(:white, "e1")).to eq true
      expect(test_game.move(:white, "0-0-0")).to eq true
      expect(test_game.select(:black, "e8")).to eq true
      expect(test_game.move(:black, "0-0-0")).to eq true

      # Make sure pieces are in the right places
      expect(test_game.board_square("c1").class).to eq King
      expect(test_game.board_square("d1").class).to eq Rook
      expect(test_game.board_square("c8").class).to eq King
      expect(test_game.board_square("d8").class).to eq Rook
    end
  end
end
