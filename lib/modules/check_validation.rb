# frozen_string_literal: true

# This module contains helper functions for Board#checkmate?
#
# It handles analyzing possible interactions between pieces,
# such as whether an ally piece can block or capture the threat
# to the king, and whether a piece cannot move because it acts
# as a pinned piece
module CheckValidation
  private

  def in_check?(color, potential_escape_position = nil)
    opponent_pieces(color).any? do |opponent_piece|
      piece_threatens_king?(opponent_piece, opponent_piece.color,
                            potential_escape_position || @kings[color].position)
    end
  end

  def validate_pinned_piece(piece, king, color, possible_pinning_pieces)
    # check if only one ally is blocking opponent's path to king
    possible_pinning_pieces.each do |opponent_piece|
      ally_pieces = ally_pieces(color)

      path = path(opponent_piece.position, king.position)
      ally_positions_in_path = (path & ally_pieces.map(&:position))

      if ally_positions_in_path.size == 1 && piece.position == ally_positions_in_path[0]
        return { pinned: true, line_of_attack: path }
      end
    end

    { pinned: false, line_of_attack: nil }
  end

  def possible_pinning_pieces(king_position, color)
    opponent_pieces(color).select { |opponent_piece| in_line_of_attack?(opponent_piece, king_position) }
  end

  def in_line_of_attack?(piece, king_position) # rubocop:disable Metrics/MethodLength
    column_difference, row_difference = position_difference(piece.position, king_position)

    case piece
    when Rook
      column_difference.zero? || row_difference.zero?
    when Bishop
      column_difference == row_difference
    when Queen
      column_difference.zero? || row_difference.zero? || column_difference == row_difference
    else
      false
    end
  end

  def can_escape_check?(king, color)
    king.next_moves.any? do |escape_move|
      !in_check?(color, escape_move) &&
        self[*escape_move].nil?
    end
  end

  def can_intercept_threat?(king, threatening_piece, color)
    possible_pinning_pieces = possible_pinning_pieces(king.position, color)

    ally_pieces(color).any? do |ally_piece|
      can_block_or_capture = can_block_path?(king, threatening_piece, ally_piece) ||
                             can_capture_threat?(threatening_piece, ally_piece, color)

      can_block_or_capture && !validate_pinned_piece(ally_piece, king, color, possible_pinning_pieces)[:pinned]
    end
  end

  def can_block_path?(king, threatening_piece, ally_piece)
    return false if threatening_piece.instance_of?(Knight) || ally_piece.instance_of?(King)

    ally_piece.next_moves.any? { |move| path(threatening_piece.position, king.position).include?(move) }
  end

  def can_capture_threat?(threatening_piece, ally_piece, color)
    if ally_piece.instance_of?(Pawn)
      pawn_diagonal_capture?(ally_piece, ally_piece.position, threatening_piece.position)
    elsif ally_piece.instance_of?(King)
      ally_piece.next_moves.any? do |move|
        (move == threatening_piece.position) && !in_check?(color, threatening_piece.position)
      end
    else
      ally_piece.next_moves.include?(threatening_piece.position)
    end
  end

  def piece_threatens_king?(opponent_piece, opponent_color, king_position)
    return pawn_threatens_king?(opponent_piece, opponent_color, king_position) if opponent_piece.instance_of?(Pawn)

    opponent_piece.next_moves.include?(king_position) &&
      path_clear?(opponent_piece, opponent_piece.position, king_position)
  end

  def pawn_threatens_king?(opponent_piece, opponent_color, king_position)
    diagonal_moves = opponent_color == :black ? [[1, 1], [-1, 1]] : [[1, -1], [-1, -1]]
    diagonal_moves.each do |diagonal_move|
      return true if king_position == [opponent_piece.position[0] + diagonal_move[0],
                                       opponent_piece.position[1] + diagonal_move[1]]
    end
    false
  end
end
