# frozen_string_literal: true

# This module contains Board#move_piece helper functions
# specific to validating castling moves, and is included
# in the MoveValidation module
module CastlingValidation
  def castling?(king, old_position, new_position)
    color = king.color
    return false unless valid_king_castling?(king, color, old_position, new_position)

    rook = castling_rook(new_position, color)
    return false unless !rook.nil? && !moved?(rook)

    valid_castling_path?(rook, king.position, color)
  end

  def valid_king_castling?(king, color, old_position, new_position)
    king.instance_of?(King) && !moved?(king) &&
      correct_castling_positioning(old_position, new_position) &&
      !in_check?(color) && !in_check?(color, new_position)
  end

  def valid_castling_path?(king, rook_position, color)
    path(king, king.position, rook_position).none? { |position| in_check?(color, position) }
  end

  def correct_castling_positioning(old_position, new_position)
    column_difference, row_difference = position_difference(old_position, new_position)
    column_difference == 2 && row_difference.zero?
  end

  def moved?(piece)
    @move_history.any? { |move| move[0] == piece }
  end

  def castling_rook(new_position, color)
    rook_column_idx = kingside(new_position) ? 7 : 0
    piece = self[rook_column_idx][new_position[1]]
    piece if piece.instance_of?(Rook) && piece.color == color
  end

  def kingside(new_king_position)
    new_king_position[0] > 4
  end
end

# This module contains Board#move_piece helper functions
# specific to validating pawn moves, and is included
# in the MoveValidation module
module PawnValidation
  def valid_pawn_move?(moving_piece, old_position, new_position)
    pawn_forward_move?(moving_piece, old_position, new_position) ||
      pawn_diagonal_capture?(moving_piece, old_position, new_position) ||
      en_passant?(moving_piece)
  end

  def pawn_forward_move?(moving_piece, old_position, new_position)
    moving_piece.next_moves.include?(new_position) &&
      path_clear?(moving_piece, old_position, new_position) && !occupied?(new_position)
  end

  def pawn_diagonal_capture?(moving_piece, old_position, new_position)
    pawn_can_diagonal_move?(moving_piece, old_position, new_position) && opponent?(moving_piece, new_position)
  end

  def en_passant?(moving_piece)
    last_move = @move_history[-1]
    return false if last_move.nil?

    opponent_pawn_double_move?(moving_piece, last_move) && correct_en_passant_positioning?(last_move, moving_piece)
  end

  def correct_en_passant_positioning?(last_move, moving_piece)
    column_difference, row_difference = position_difference(last_move[2], moving_piece.position)
    column_difference == 1 && row_difference.zero?
  end

  def opponent_pawn_double_move?(moving_piece, last_move)
    last_moved_piece = last_move[0]
    return false unless last_moved_piece.instance_of?(Pawn) && opponent?(moving_piece, last_moved_piece.position)

    column_move = last_move[1][0] - last_move[2][0]
    row_move = (last_move[1][1] - last_move[2][1]).abs

    column_move.zero? && row_move == 2
  end

  def pawn_can_diagonal_move?(moving_piece, old_position, new_position)
    return false unless occupied?(new_position)

    diagonal_moves = moving_piece.color == :black ? [[1, 1], [-1, 1]] : [[1, -1], [-1, -1]]

    diagonal_moves.any? do |diagonal_move|
      new_position == [old_position[0] + diagonal_move[0], old_position[1] + diagonal_move[1]]
    end
  end
end
