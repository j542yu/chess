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
    @pieces_black = []
    @pieces_white = []
    @kings = { black: nil, white: nil }
    # allow saved board from previous game to be loaded if desired
    @board = board || generate_default_board
  end

  attr_reader :pieces_black, :pieces_white, :kings

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
  def move_piece(piece, new_position) # rubocop:disable Metrics/AbcSize
    old_position = piece.position

    return false unless valid_move?(piece, old_position, new_position)

    remove_captured_piece(new_position) unless @board[new_position[0]][new_position[1]].nil?

    @board[old_position[0]][old_position[1]] = nil
    @board[new_position[0]][new_position[1]] = piece
    piece.update_position(new_position)

    true
  end

  private

  def place_major_pieces(board, color, row_idx)
    pieces_all = color == :black ? @pieces_black : @pieces_white

    first_row_pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    first_row_pieces.each_with_index do |piece_class, column_idx|
      piece_new = piece_class.new([column_idx, row_idx], color)
      board[column_idx][row_idx] = piece_new
      pieces_all << piece_new
      @kings[color] = piece_new if piece_new.instance_of?(King)
    end
  end

  def place_pawns(board, color, row_idx)
    pieces_all = color == :black ? @pieces_black : @pieces_white

    (0..7).each do |column_idx|
      pawn_new = Pawn.new([column_idx, row_idx], color)
      board[column_idx][row_idx] = pawn_new
      pieces_all << pawn_new
    end
  end

  def remove_captured_piece(captured_piece_position)
    captured_piece = @board[captured_piece_position[0]][captured_piece_position[1]]

    pieces = captured_piece.color == :black ? @pieces_black : @pieces_white

    pieces.delete(captured_piece)

    @board[captured_piece_position[0]][captured_piece_position[1]] = nil
  end
end
