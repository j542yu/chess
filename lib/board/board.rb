# frozen_string_literal: true

require_relative 'piece'
require_relative 'modules/board_display'
require_relative 'modules/board_serializable'
require_relative 'modules/check_validation'
require_relative 'modules/move_validation'
require_relative 'modules/move_piece_helpers'

# This class represents the chess game board
#
# It handles storing the positions of all game pieces in a 2D array,
# and moving game pieces
class Board
  include BoardDisplay
  include BoardSerializable
  include CheckValidation
  include MoveValidation
  include MovePieceHelpers

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

  def []=(column_idx, row_idx, value)
    @board[column_idx][row_idx] = value
  end

  def opponent_pieces(color)
    case color
    when :black
      @pieces_white
    when :white
      @pieces_black
    end
  end

  def ally_pieces(color)
    case color
    when :black
      @pieces_black
    when :white
      @pieces_white
    end
  end

  # returns boolean hash with move info (move_valid, capture, en_passant, castling, promote_pawn)
  def move_piece(moving_piece, new_position)
    result = { move_valid: false, endangers_king: false, capture: false, castling: false,
               en_passant: false, promote_pawn: false }

    old_position = moving_piece.position

    result.merge!(valid_move?(moving_piece, old_position, new_position))
    return result unless result[:move_valid]

    if result[:castling]
      move_castling_pieces(moving_piece, old_position, new_position, result)
    else
      move_generic_piece(moving_piece, old_position, new_position, result)
    end
  end

  def checkmate?(color)
    return false unless in_check?(color)

    king = @kings[color]
    return false if can_escape_check?(king, color)

    threatening_pieces = opponent_pieces(color).select do |opponent_piece|
      piece_threatens_king?(opponent_piece, opponent_piece.color, king.position)
    end

    return false if threatening_pieces.empty? ||
                    (threatening_pieces.size == 1 && can_intercept_threat?(king, threatening_pieces[0], color))

    true
  end

  private

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
end
