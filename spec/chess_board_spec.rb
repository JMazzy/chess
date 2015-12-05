require 'rspec'
require_relative "../lib/chess_board.rb"

describe "selection should work" do
  it "disallows blank selection" do
    test_board = ChessBoard.new(:blank)
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
  describe "pawn should move correctly" do
    it "moves one space forward" do
      test_board = ChessBoard.new(:standard)
      expect(test_board.board_square("d2").class).to eq Pawn
      expect(test_board.select(:white, "d2")).to eq true
      expect(test_board.move(:white, "d3")).to eq true
      expect(test_board.board_square("d3").class).to eq Pawn
    end
  end
end