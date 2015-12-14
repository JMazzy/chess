require 'rspec'
require_relative "../lib/chess_game.rb"

describe "selection should work" do
  it "disallows blank selection" do
    test_board = ChessGame.new(:standard)
    expect(test_board.select(:white, "f5")).to eq false
    expect(test_board.selected).to eq nil
  end

  it "disallows selecting opposing piece" do
    test_board = ChessGame.new(:standard)
    expect(test_board.select(:white, "d7")).to eq false
    expect(test_board.selected).to eq nil
  end

  it "allows valid selection" do
    test_board = ChessGame.new(:standard)
    expect(test_board.select(:black, "d7")).to eq true
    expect(test_board.selected).to eq [6,3]
  end
end
