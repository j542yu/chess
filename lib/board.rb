# frozen_string_literal: true

require_relative 'piece'
require_relative 'move_validation'
require_relative 'board_io'

# This class represents the chess game board
#
# It handles storing the positions of all game pieces in a 2D array,
# and moving game pieces
class Board
  include MoveValidation
  include BoardIO

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

  def [](column_idx)
    @board[column_idx]
  end

  # returns true if piece was successfully moved, or false otherwise
  def move_piece(piece, new_position)
    old_position = piece.position

    return false unless valid_move?(piece, old_position, new_position)

    @board[old_position[0]][old_position[1]] = nil
    @board[new_position[0]][new_position[1]] = piece
    piece.update_position(new_position)

    true
  end

  private

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
end
