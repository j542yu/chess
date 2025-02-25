# frozen_string_literal: true

# This module contains Board#move_piece helper functions
# specific to the consequences of moving a piece,
# including commiting the actual move, performing captures,
# and promoting pawns
module MovePieceHelpers
  private

  def move_generic_piece(moving_piece, old_position, new_position, result)
    capture_result = remove_captured_piece(moving_piece, self[*new_position])
    result.merge!(capture_result)

    commit_move(moving_piece, old_position, new_position)

    result.merge!(can_promote_pawn?(moving_piece))
  end

  def move_castling_pieces(king, old_king_position, new_king_position, result)
    rook = castling_rook(new_king_position, king.color)

    old_rook_position = rook.position

    column_offset = kingside(new_king_position) ? 1 : -1
    new_rook_position = [old_king_position[0] + column_offset, old_rook_position[1]]

    commit_move(king, old_king_position, new_king_position)
    commit_move(rook, old_rook_position, new_rook_position)

    result
  end

  def commit_move(moving_piece, old_position, new_position)
    self[*old_position] = nil
    self[*new_position] = moving_piece
    moving_piece.update_position(new_position)

    @move_history << [moving_piece, old_position, new_position]
  end

  def remove_captured_piece(capturing_piece, captured_piece)
    result = { capture: false, en_passant: false }

    if captured_piece.nil? && en_passant?(capturing_piece)
      captured_piece = @move_history[-1][0]
      result[:en_passant] = true
    end

    return result if captured_piece.nil?

    ally_pieces(captured_piece.color).delete(captured_piece)

    self[*captured_piece.position] = nil

    result[:capture] = true
    result
  end

  def can_promote_pawn?(moving_piece)
    final_row_idx = moving_piece.color == :black ? 7 : 0

    moving_piece.position[1] == final_row_idx ? { promote_pawn: true } : { promote_pawn: false }
  end

  def position_difference(position_one, position_two)
    [(position_one[0] - position_two[0]).abs, (position_one[1] - position_two[1]).abs]
  end

  def promote_pawn(piece, promotion_piece_name)
    color = piece.color
    ally_pieces = ally_pieces(color)
    position = piece.position
    promotion_piece = Object.const_get(promotion_piece_name).new(position, color)

    self[*position] = promotion_piece
    ally_pieces.delete(piece)
    ally_pieces.push(promotion_piece)
  end
end
