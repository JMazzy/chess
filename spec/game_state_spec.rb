require 'rspec'
require_relative '../lib/chess_game.rb'

describe 'game check state -' do
  describe 'check -' do
    it 'a piece detecting an opposing king in range should put the game in check' do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, 'e3', King)).to eq true
      expect(test_game.set_piece(:black, 'd5', Pawn)).to eq true

      # Game should be playing, not in check
      expect(test_game.game_state).to eq :playing

      # Black pawn moves so white king is in range
      expect(test_game.select(:black, 'd5')).to eq true
      expect(test_game.move(:black, 'd4')).to eq true

      test_game.piece_control

      # Pawn should detect king in range
      expect(test_game.board_square('d4').pieces_in_range.include?('WKe3')).to eq true

      # Game should be in check
      expect(test_game.game_state).to eq :check_white
    end

    it "a king moving out of harm's way should take the game out of check" do
      test_game = ChessGame.new(:blank)

      # Place the pieces
      expect(test_game.set_piece(:white, 'e3', King)).to eq true
      expect(test_game.set_piece(:black, 'd4', Pawn)).to eq true

      # Sense piece control
      test_game.piece_control

      # Pawn should detect king in range
      expect(test_game.board_square('d4').pieces_in_range.include?('WKe3')).to eq true

      # Game should be in check
      expect(test_game.game_state).to eq :check_white

      # King moves out of range
      expect(test_game.select(:white, 'e3')). to eq true
      expect(test_game.move(:white, 'e2')). to eq true

      # Sense piece control
      test_game.piece_control

      # Game should be playing, not in check
      expect(test_game.game_state).to eq :playing
    end

    it 'another piece moving and breaking the check should put game out of check' do
      test_game = ChessGame.new(:blank)
      test_game.current_player = :white

      # Place the pieces
      expect(test_game.set_piece(:white, 'e4', King)).to eq true
      expect(test_game.set_piece(:black, 'c6', Bishop)).to eq true
      expect(test_game.set_piece(:white, 'd3', Rook)).to eq true

      # Sense piece control
      test_game.piece_control

      # Bishop should detect king in range
      expect(test_game.board_square('c6').pieces_in_range.include?('WKe4')).to eq true

      # Game should be in check
      expect(test_game.game_state).to eq :check_white

      # Rook moves between King and Bishop
      expect(test_game.select(:white, 'd3')).to eq true
      expect(test_game.move(:white, 'd5')).to eq true
      expect(test_game.board_square('d3').class).to eq NilClass
      expect(test_game.board_square('d5').class).to eq Rook

      # Sense piece control
      test_game.piece_control

      # Bishop should NOT detect king in range
      expect(test_game.board_square('c6').pieces_in_range.include?('WKe4')).to eq false

      # Game should be playing, not in check
      expect(test_game.game_state).to eq :playing
    end

    it "a king's move which puts itself in check should fail" do
      test_game = ChessGame.new(:blank)
      test_game.current_player = :black

      expect(test_game.set_piece(:black, 'c5', King)).to eq true
      expect(test_game.set_piece(:white, 'e5', Bishop)).to eq true

      # Sense piece control
      test_game.piece_control

      coords = test_game.chess_coords_to_indices('d4')
      expect(test_game.board.square_threats(coords[0],coords[1]).include?('WBe5')).to eq true

      # King moves into check; should fail
      expect(test_game.select(:black, 'c5')).to eq true
      expect(test_game.move(:black, 'd4')).to eq false

      expect(test_game.board_square('c5').class).to eq King
      expect(test_game.board_square('e5').class).to eq Bishop
      expect(test_game.board_square('d4').class).to eq NilClass

      expect(test_game.current_player).to eq :black
    end

    it "a move by a non-King which puts yourself in check should fail" do
      test_game = ChessGame.new(:blank)
      test_game.current_player = :black

      expect(test_game.set_piece(:black, 'c5', King)).to eq true
      expect(test_game.set_piece(:black, 'd4', Pawn)).to eq true
      expect(test_game.set_piece(:white, 'e3', Bishop)).to eq true

      expect(test_game.board_square_threats('c5').include?('WBe3'))
      expect(test_game.board_square_threats('d4').include?('WBe3'))

      # King moves into check; should fail
      expect(test_game.select(:black, 'd4')).to eq true
      expect(test_game.move(:black, 'd3')).to eq false

      expect(test_game.board_square("c5").class).to eq King
      expect(test_game.board_square('e3').class).to eq Bishop
      expect(test_game.board_square('d4').class).to eq Pawn

      expect(test_game.current_player).to eq :black
    end
  end

  describe 'checkmate -' do

    it 'should detect a checkmate (no safe moves)' do
      pending 'need to implement checkmate detection'
      test_game = ChessGame.new(:blank)

      # tests here

      expect(test_game.game_state).to eq :checkmate
    end

    it 'a state of checkmate should end the game and declare a winner' do
      test_game = ChessGame.new(:blank)
      test_game.checkmate(:white)
      expect(test_game.game_state).to eq :white_win

      test_game = ChessGame.new(:blank)
      test_game.checkmate(:black)
      expect(test_game.game_state).to eq :black_win
    end
  end

  describe 'stalemate -' do
    it 'a player cannot move to put themselves in check' do
      # need to implement entirely
    end

    it 'should detect a stalemate' do
      pending 'need to implement stalemate detection'
      test_game = ChessGame.new(:blank)

      # tests here

      expect(test_game.game_state).to eq :stalemate
    end

    it 'a state of stalemate should end the game' do
      test_game = ChessGame.new(:blank)
      test_game.stalemate(:white)
      expect(test_game.game_state).to eq :draw

      test_game = ChessGame.new(:blank)
      test_game.stalemate(:black)
      expect(test_game.game_state).to eq :draw
    end
  end

  describe 'resignation -' do
    it 'should give victory to other player' do
      test_game = ChessGame.new(:blank)
      test_game.resign(:white)
      expect(test_game.game_state).to eq :black_win

      test_game = ChessGame.new(:blank)
      test_game.resign(:black)
      expect(test_game.game_state).to eq :white_win
    end
  end

  describe 'game ending states -' do
    it 'a victory by white should register correctly' do
      test_game = ChessGame.new(:blank)
      test_game.declare_victory(:white)
      expect(test_game.game_state).to eq :white_win
    end

    it 'a victory by black should register correctly -' do
      test_game = ChessGame.new(:blank)
      test_game.declare_victory(:black)
      expect(test_game.game_state).to eq :black_win
    end

    it 'a draw should register correctly -' do
      test_game = ChessGame.new(:blank)
      test_game.draw
      expect(test_game.game_state).to eq :draw
    end
  end
end
