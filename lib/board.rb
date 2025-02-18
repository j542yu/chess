# frozen_string_literal: true

require_relative 'piece'

# This class represents the chess game board
#
# It handles storing the positions of all game pieces in a 2D array
class Board
  PIECE_CHARACTERS_WHITE = { rook: '♖', bishop: '♗', knight: '♘',
                             queen: '♕', king: '♔', pawn: '♙' }.freeze

  PIECE_CHARACTERS_BLACK = { rook: '♜', bishop: '♝', knight: '♞',
                             queen: '♛', king: '♚', pawn: '♟' }.freeze

  def initialize(board = nil)
    # allow saved board from previous game to be loaded if desired
    @board = board || generate_default_board
  end

  attr_reader :piece_characters_white, :piece_characters_black

  def generate_default_board
    board = Array.new(8) { Array.new(8) }

    place_major_pieces(board, :black, 0)
    place_pawns(board, :black, 1)

    place_major_pieces(board, :white, 7)
    place_pawns(board, :white, 6)

    board
  end

  def place_major_pieces(board, color, row_idx)
    first_row_pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    first_row_pieces.each_with_index do |piece_class, column_idx|
      board[column_idx][row_idx] = piece_class.new([column_idx, row_idx], color)
    end
  end

  def place_pawns(board, color, row_idx)
    (0..7).each do |column_idx|
      board[column_idx][row_idx] = Pawn.new([column_idx, row_idx], color)
    end
  end

  def display # rubocop:disable Metrics/MethodLength
    print "\n      a    b    c    d    e    f    g    h\n\n"
    print "    —————————————————————————————————————————\n"

    (0..7).each do |row_idx|
      print "#{8 - row_idx}   |"
      @board.each do |column|
        piece = column[row_idx]
        print piece.nil? ? ' 　 |' : " #{character(piece.type, piece.color)}  |"
      end
      print "   #{8 - row_idx}\n"
      print "    —————————————————————————————————————————\n"
    end

    print "\n      a    b    c    d    e    f    g    h\n\n"
  end

  def character(piece, color)
    piece_characters = color == :black ? PIECE_CHARACTERS_BLACK : PIECE_CHARACTERS_WHITE

    piece_characters[piece]
  end
end

Board.new.display
