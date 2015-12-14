require 'rspec'
require_relative '../lib/chess_game.rb'

describe 'pieces should sense nearby pieces -' do
  describe 'pieces in taking range -' do
    it 'pawn senses pieces in range' do
      # Any pieces on the squares diagonally forward (positive for white and negative for black)

      test_board = ChessGame.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, 'f2', Pawn)).to eq true
      expect(test_board.set_piece(:black, 'g3', Pawn)).to eq true

      test_board.piece_control

      expect(test_board.board_square('f2').pieces_in_range.include?('BPg3')).to eq true
      expect(test_board.board_square('g3').pieces_in_range.include?('WPf2')).to eq true
    end

    it 'rook senses pieces in range' do
      # First piece along any
      test_board = ChessGame.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, 'c4', Rook)).to eq true
      expect(test_board.set_piece(:black, 'c6', Rook)).to eq true
      expect(test_board.set_piece(:black, 'a4', Rook)).to eq true
      expect(test_board.set_piece(:black, 'h4', Rook)).to eq true
      expect(test_board.set_piece(:black, 'c1', Rook)).to eq true

      test_board.piece_control

      expect(test_board.board_square('c4').pieces_in_range.include?('BRc6')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BRa4')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BRh4')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BRc1')).to eq true
    end

    it 'knight senses pieces in range' do
      test_board = ChessGame.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, 'd4', Knight)).to eq true
      expect(test_board.set_piece(:black, 'e6', Pawn)).to eq true
      expect(test_board.set_piece(:black, 'f5', Pawn)).to eq true
      expect(test_board.set_piece(:black, 'f3', Pawn)).to eq true
      expect(test_board.set_piece(:black, 'e2', Pawn)).to eq true
      expect(test_board.set_piece(:black, 'c2', Pawn)).to eq true
      expect(test_board.set_piece(:black, 'b3', Pawn)).to eq true
      expect(test_board.set_piece(:black, 'b5', Pawn)).to eq true
      expect(test_board.set_piece(:black, 'c6', Pawn)).to eq true

      test_board.piece_control

      expect(test_board.board_square('d4').pieces_in_range.include?('BPe6')).to eq true
      expect(test_board.board_square('d4').pieces_in_range.include?('BPf5')).to eq true
      expect(test_board.board_square('d4').pieces_in_range.include?('BPf3')).to eq true
      expect(test_board.board_square('d4').pieces_in_range.include?('BPe2')).to eq true
      expect(test_board.board_square('d4').pieces_in_range.include?('BPc2')).to eq true
      expect(test_board.board_square('d4').pieces_in_range.include?('BPb3')).to eq true
      expect(test_board.board_square('d4').pieces_in_range.include?('BPb5')).to eq true
      expect(test_board.board_square('d4').pieces_in_range.include?('BPc6')).to eq true
    end

    it 'bishop senses pieces in range' do
      test_board = ChessGame.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, 'c4', Bishop)).to eq true
      expect(test_board.set_piece(:black, 'e6', Bishop)).to eq true
      expect(test_board.set_piece(:black, 'e2', Bishop)).to eq true
      expect(test_board.set_piece(:black, 'a6', Bishop)).to eq true
      expect(test_board.set_piece(:black, 'a2', Bishop)).to eq true

      test_board.piece_control

      expect(test_board.board_square('c4').pieces_in_range.include?('BBe6')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BBe2')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BBa6')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BBa2')).to eq true
    end

    it 'queen senses pieces in range' do
      test_board = ChessGame.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, 'c4', Queen)).to eq true
      expect(test_board.set_piece(:black, 'e6', Bishop)).to eq true
      expect(test_board.set_piece(:black, 'e2', Bishop)).to eq true
      expect(test_board.set_piece(:black, 'a6', Bishop)).to eq true
      expect(test_board.set_piece(:black, 'a2', Bishop)).to eq true
      expect(test_board.set_piece(:black, 'c6', Rook)).to eq true
      expect(test_board.set_piece(:black, 'a4', Rook)).to eq true
      expect(test_board.set_piece(:black, 'h4', Rook)).to eq true
      expect(test_board.set_piece(:black, 'c1', Rook)).to eq true

      test_board.piece_control

      expect(test_board.board_square('c4').pieces_in_range.include?('BBe6')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BBe2')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BBa6')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BBa2')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BRc6')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BRa4')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BRh4')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BRc1')).to eq true
    end

    it 'king senses pieces in range' do
      test_board = ChessGame.new(:blank)

      # Place the pieces
      expect(test_board.set_piece(:white, 'c4', King)).to eq true
      expect(test_board.set_piece(:black, 'c5', Pawn)).to eq true
      expect(test_board.set_piece(:black, 'c3', Pawn)).to eq true
      expect(test_board.set_piece(:black, 'b4', Pawn)).to eq true
      expect(test_board.set_piece(:black, 'd4', Pawn)).to eq true
      expect(test_board.set_piece(:black, 'b5', Pawn)).to eq true
      expect(test_board.set_piece(:black, 'b3', Pawn)).to eq true
      expect(test_board.set_piece(:black, 'd5', Pawn)).to eq true
      expect(test_board.set_piece(:black, 'd3', Pawn)).to eq true

      test_board.piece_control

      expect(test_board.board_square('c4').pieces_in_range.include?('BPc5')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BPc3')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BPb4')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BPd4')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BPb5')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BPb3')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BPd5')).to eq true
      expect(test_board.board_square('c4').pieces_in_range.include?('BPd3')).to eq true
    end

    it 'sensing should work on a standard board' do
      test_board = ChessGame.new(:standard)

      # Mainly making sure this does not raise any errors
      test_board.piece_control

      expect(test_board.board_square('c1').pieces_in_range.include?('WPb2')).to eq true
      expect(test_board.board_square('b1').pieces_in_range.include?('WPd2')).to eq true
      expect(test_board.board_square('a1').pieces_in_range.include?('WPa2')).to eq true
      expect(test_board.board_square('e8').pieces_in_range.include?('BPe7')).to eq true
      expect(test_board.board_square('d8').pieces_in_range.include?('BKe8')).to eq true
    end
  end
end
