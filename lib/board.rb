# frozen_string_literal: true

require_relative 'piece'
require_relative 'check_validation'
require_relative 'move_validation'
require_relative 'board_io'
require_relative 'serializable/board_serializable'

# This class represents the chess game board
#
# It handles storing the positions of all game pieces in a 2D array,
# and moving game pieces
class Board
  include CheckValidation
  include MoveValidation
  include BoardIO
  include BoardSerializable

  def initialize(pieces = [[], [], { black: nil, white: nil }], board = nil, move_history = [])
    @pieces_black, @pieces_white, @kings = pieces

    @board = board || generate_default_board

    @move_history = move_history
  end

  def [](column_idx, row_idx = nil)
    if row_idx.nil?
      @board[column_idx] # board[column_idx][row_idx]
    else
      @board[column_idx][row_idx] # board[*position]
    end
  end

  def opponent_pieces(color)
    color == :black ? @pieces_white : @pieces_black
  end

  def ally_pieces(color)
    color == :black ? @pieces_black : @pieces_white
  end

  # returns true if piece was successfully moved, or false otherwise
  def move_piece(moving_piece, new_position)
    old_position = moving_piece.position

    return false unless valid_move?(moving_piece, old_position, new_position)

    captured_piece = self[*new_position]
    remove_captured_piece(moving_piece, captured_piece)

    self[*old_position] = nil
    self[*new_position] = moving_piece
    moving_piece.update_position(new_position)

    @move_history << [moving_piece, old_position, new_position]

    true
  end

  def checkmate?(color)
    return false unless in_check?(color)

    king = @kings[color]
    return true unless can_escape_check?(king)

    threatening_pieces = opponent_pieces(color).select do |opponent_piece|
      piece_threatens_king?(opponent_piece, opponent_piece.color, king.position)
    end

    return true if threatening_pieces.size > 1

    !can_intercept_threat?(king, threatening_pieces[0])
  end

  private

  def []=(column_idx, row_idx, value)
    @board[column_idx][row_idx] = value
  end

  def generate_default_board
    board = Array.new(8) { Array.new(8) }

    place_major_pieces(board, :black, 0)
    place_pawns(board, :black, 1)

    place_major_pieces(board, :white, 7)
    place_pawns(board, :white, 6)

    board
  end

  def place_major_pieces(board, color, row_idx)
    pieces_all = ally_pieces(color)

    first_row_pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    first_row_pieces.each_with_index do |piece_class, column_idx|
      piece_new = piece_class.new([column_idx, row_idx], color)
      board[column_idx][row_idx] = piece_new
      pieces_all << piece_new
      @kings[color] = piece_new if piece_new.instance_of?(King)
    end
  end

  def place_pawns(board, color, row_idx)
    pieces_all = ally_pieces(color)

    (0..7).each do |column_idx|
      pawn_new = Pawn.new([column_idx, row_idx], color)
      board[column_idx][row_idx] = pawn_new
      pieces_all << pawn_new
    end
  end

  def remove_captured_piece(capturing_piece, captured_piece)
    captured_piece = @move_history[-1][0] if captured_piece.nil? && en_passant?(capturing_piece)

    return if captured_piece.nil?

    ally_pieces(captured_piece.color).delete(captured_piece)

    self[*captured_piece.position] = nil
  end
end
