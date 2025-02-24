# frozen_string_literal: true

# This module contains helper functions for Board#checkmate?
#
# It handles analyzing possible interactions between pieces,
# such as whether an ally piece can block or capture the threat
# to the king, and whether a piece cannot move because it acts
# as a pinned piece
module CheckValidation
  def in_check?(color, potential_escape_position = nil)
    opponent_pieces(color).any? do |opponent_piece|
      piece_threatens_king?(opponent_piece, opponent_piece.color,
                            potential_escape_position || @kings[color].position)
    end
  end

  def opponent_pieces(color)
    color == :black ? @pieces_white : @pieces_black
  end

  def ally_pieces(color)
    color == :black ? @pieces_black : @pieces_white
  end

  private

  def pinned_pieces(king)
    pinned_pieces = []

    # check if only one ally is blocking opponent's path to king
    possible_pinning_pieces(king).each do |opponent_piece|
      path = path(opponent_piece, opponent_piece.position, king.position)

      ally_pieces_in_path = ally_pieces(king.color).select do |ally_piece|
        path.include?(ally_piece.position)
      end

      pinned_pieces.push(*ally_pieces_in_path) if ally_pieces_in_path.size == 1
    end

    pinned_pieces
  end

  def in_line_of_attack?(piece, king)
    column_difference = (piece.position[0] - king.position[0]).abs
    row_difference = (piece.position[1] - king.position[1]).abs

    column_difference.zero? || row_difference.zero? || column_difference == row_difference
  end

  def possible_pinning_pieces(king)
    opponent_pieces(king.color).reject do |opponent_piece|
      opponent_piece.instance_of?(Knight) || opponent_piece.instance_of(Pawn) ||
        !in_line_of_attack?(opponent_piece, king)
    end
  end

  def can_escape_check?(king)
    king.next_moves.any? { |escape_move| !in_check?(king.color, escape_move) }
  end

  def can_intercept_threat?(king, threatening_piece)
    ally_pieces(king.color).any? do |ally_piece|
      can_block_or_capture = can_block_path?(king, threatening_piece, ally_piece) ||
                             can_capture_threat?(threatening_piece, ally_piece)

      can_block_or_capture && !pinned_pieces(king).include?(ally_piece)
    end
  end

  def can_block_path?(king, threatening_piece, ally_piece)
    return false if threatening_piece.instance_of?(Knight) || ally_piece.instance_of?(King)

    path = path(threatening_piece, threatening_piece.position, king.position)

    ally_piece.next_moves.any? { |move| path.include?(move) }
  end

  def can_capture_threat?(threatening_piece, ally_piece)
    if ally_piece.instance_of(Pawn)
      pawn_can_diagonal_move?(ally_piece, ally_piece.position, threatening_piece.position)
    else
      ally_piece.next_moves.include?(threatening_piece.position)
    end
  end

  def piece_threatens_king?(opponent_piece, opponent_color, king_position)
    return pawn_threatens_king?(opponent_piece, opponent_color, king_position) if opponent_piece.instance_of?(Pawn)

    opponent_piece.next_moves.include?(king_position)
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
