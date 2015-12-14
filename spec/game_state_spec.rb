require 'rspec'
require_relative '../lib/chess_game.rb'

describe 'game check state -' do
  describe 'check -' do
    it 'a piece detecting an opposing king in range should put the game in check' do
      test_board = ChessGame.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, 'e3', King)).to eq true
      expect(test_board.set_piece(:black, 'd5', Pawn)).to eq true

      # Game should be playing, not in check
      expect(test_board.game_state).to eq :playing

      # Black pawn moves so white king is in range
      expect(test_board.select(:black, 'd5')). to eq true
      expect(test_board.move(:black, 'd4')). to eq true

      test_board.piece_control

      # Pawn should detect king in range
      expect(test_board.board_square('d4').pieces_in_range.include?('WKe3')).to eq true

      # Game should be in check
      expect(test_board.game_state).to eq :check
    end

    it "a king moving out of harm's way should take the game out of check" do
      test_board = ChessGame.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, 'e3', King)).to eq true
      expect(test_board.set_piece(:black, 'd4', Pawn)).to eq true

      # Sense piece control
      test_board.piece_control

      # Pawn should detect king in range
      expect(test_board.board_square('d4').pieces_in_range.include?('WKe3')).to eq true

      # Game should be in check
      expect(test_board.game_state).to eq :check

      # King moves out of range
      expect(test_board.select(:white, 'e3')). to eq true
      expect(test_board.move(:white, 'e2')). to eq true

      # Sense piece control
      test_board.piece_control

      # Game should be playing, not in check
      expect(test_board.game_state).to eq :playing
    end

    it 'another piece moving and breaking the check should put game out of check' do
      # need to write test but should work already
    end
  end

  describe 'checkmate -' do
    it 'a king should detect safe moves to get out of check' do
      # need to implement entirely
    end

    it 'should detect a checkmate (no safe moves)' do
      pending 'need to implement checkmate detection'
      test_board = ChessGame.new(:blank)

      # tests here

      expect(test_board.game_state).to eq :checkmate
    end

    it 'a state of checkmate should end the game and declare a winner' do
      pending 'need to implement win/lose/draw'
      test_board = ChessGame.new(:blank)
      test_board.game_state = :checkmate
      test_board.winner = :white
      expect(test_board.game_state).to eq :checkmate
      expect(test_board.winner).to eq :white
    end
  end

  describe 'stalemate -' do
    it 'a player cannot move to put themselves in check' do
      # need to implement entirely
    end

    it 'should detect a stalemate' do
      pending 'need to implement stalemate detection'
      test_board = ChessGame.new(:blank)

      # tests here

      expect(test_board.game_state).to eq :stalemate
    end

    it 'a state of stalemate should end the game' do
      pending 'need to implement win/lose/draw'
      test_board = ChessGame.new(:blank)
      test_board.game_state = :stalemate
      expect(test_board.game_state).to eq :stalemate
      expect(test_board.winner). to eq :draw
    end
  end

  describe 'resignation -' do
    it 'should give victory to other player' do
      test_board = ChessGame.new(:blank)
      test_board.resign(:white)
      expect(test_board.game_state).to eq :black_win

      test_board = ChessGame.new(:blank)
      test_board.resign(:black)
      expect(test_board.game_state).to eq :white_win
    end
  end

  describe 'game ending states -' do
    it 'a victory by white should register correctly' do
      test_board = ChessGame.new(:blank)
      test_board.declare_victory(:white)
      expect(test_board.game_state).to eq :white_win
    end

    it 'a victory by black should register correctly -' do
      test_board = ChessGame.new(:blank)
      test_board.declare_victory(:black)
      expect(test_board.game_state).to eq :black_win
    end

    it 'a draw should register correctly -' do
      test_board = ChessGame.new(:blank)
      test_board.draw
      expect(test_board.game_state).to eq :draw
    end
  end
end
