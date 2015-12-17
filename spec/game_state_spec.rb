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

    it 'should detect a simple checkmate' do
      test_game = ChessGame.new(:blank)

      expect(test_game.set_piece(:black, 'h5', King)).to eq true
      expect(test_game.set_piece(:white, 'f5', King)).to eq true
      expect(test_game.set_piece(:white, 'h1', Rook)).to eq true

      test_game.switch_player

      expect(test_game.game_state).to eq :white_win
    end

    it 'should detect a more complex checkmate' do
      test_game = ChessGame.new(:blank)
      expect(test_game.set_piece(:white, 'g2', King)).to eq true
      expect(test_game.set_piece(:white, 'c6', Bishop)).to eq true
      expect(test_game.set_piece(:white, 'd8', Rook)).to eq true

      expect(test_game.set_piece(:black, 'b8', King)).to eq true
      expect(test_game.set_piece(:black, 'c7', Pawn)).to eq true
      expect(test_game.set_piece(:black, 'a7', Pawn)).to eq true

      test_game.switch_player

      expect(test_game.game_state).to eq :white_win
    end

    it 'should detect a stammas mate' do
      test_game = ChessGame.new(:blank)
      expect(test_game.set_piece(:white, 'c2', King)).to eq true
      expect(test_game.set_piece(:white, 'd3', Knight)).to eq true

      expect(test_game.set_piece(:black, 'a2', King)).to eq true
      expect(test_game.set_piece(:black, 'a3', Pawn)).to eq true

      expect(test_game.current_player).to eq :white

      # White knight to b4
      test_game.handle_selection('d3')
      test_game.handle_moving('b4')
      # Black king to a1
      test_game.handle_selection('a2')
      test_game.handle_moving('a1')
      # White king to c1
      test_game.handle_selection('c2')
      test_game.handle_moving('c1')
      # Black pawn to a2
      expect(test_game.handle_selection('a3')).to eq :select_success
      expect(test_game.handle_moving('a2')).to eq :move_success
      # White knight to c2
      test_game.handle_selection('b4')
      test_game.handle_moving('c2')

      expect(test_game.game_state).to eq :white_win
    end

    it 'should detect a fools mate' do
      pending "pawn possible move / piece in range detection needs fixing"
      test_game = ChessGame.new(:standard)

      expect(test_game.handle_selection('f2')).to eq :select_success
      expect(test_game.handle_moving('f3')).to eq :move_success

      expect(test_game.handle_selection('e7')).to eq :select_success
      expect(test_game.handle_moving('e5')).to eq :move_success

      expect(test_game.handle_selection('g2')).to eq :select_success
      expect(test_game.handle_moving('g4')).to eq :move_success

      expect(test_game.handle_selection('d8')).to eq :select_success
      expect(test_game.handle_moving('h4')).to eq :move_success

      expect(test_game.game_state).to eq :black_win
    end

    it 'checkmate should end the game and declare a winner' do
      test_game = ChessGame.new(:blank)
      test_game.checkmate(:white)
      expect(test_game.game_state).to eq :black_win

      test_game = ChessGame.new(:blank)
      test_game.checkmate(:black)
      expect(test_game.game_state).to eq :white_win
    end
  end

  describe 'stalemate -' do

    it 'should detect a stalemate' do
      test_game = ChessGame.new(:blank)

      expect(test_game.set_piece(:black, 'h8', King)).to eq true
      expect(test_game.set_piece(:white, 'f7', King)).to eq true
      expect(test_game.set_piece(:white, 'g6', Queen)).to eq true

      test_game.current_player = :white

      test_game.piece_control

      expect(test_game.game_state).to eq :playing

      test_game.switch_player

      expect(test_game.game_state).to eq :draw
    end

    it 'stalemate should end the game' do
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
