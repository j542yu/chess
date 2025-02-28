# frozen_string_literal: true

require_relative 'move_validation_helpers'

# This module contains Board#move_piece helper functions
# specific to validating moves
module MoveValidation
  include CastlingValidation
  include PawnValidation

  private

  def valid_move?(moving_piece, old_position, new_position) # rubocop:disable Metrics/MethodLength
    result = { move_valid: false, endangers_king: false, castling: false }

    if endangers_king?(moving_piece, new_position)
      result[:endangers_king] = true
    elsif moving_piece.instance_of?(Pawn)
      result[:move_valid] = valid_pawn_move?(moving_piece, old_position, new_position)
    elsif castling?(moving_piece, old_position, new_position)
      result[:move_valid] = true
      result[:castling] = true
    else
      result[:move_valid] = valid_generic_piece_move?(moving_piece, old_position, new_position)
    end

    result
  end

  def endangers_king?(moving_piece, new_position)
    (moving_piece.instance_of?(King) && in_check?(moving_piece.color, new_position)) ||
      illegal_pinned_move?(moving_piece, new_position)
  end

  def illegal_pinned_move?(moving_piece, new_position)
    color = moving_piece.color
    king = @kings[color]
    pinned_status = validate_pinned_piece(moving_piece, king, color, possible_pinning_pieces(king.position, color))
    return false unless pinned_status[:pinned]

    return true if moving_piece.instance_of?(Knight)

    !pinned_status[:line_of_attack].include?(new_position)
  end

  def valid_generic_piece_move?(moving_piece, old_position, new_position)
    moving_piece.next_moves.include?(new_position) &&
      path_clear?(moving_piece, old_position, new_position) &&
      (!occupied?(new_position) || opponent?(moving_piece, new_position))
  end

  def path_clear?(moving_piece, old_position, new_position, validate_castling_path: false)
    return true if moving_piece.instance_of?(Knight)

    path = path(old_position, new_position)

    return false if validate_castling_path && path.any? { |position| in_check?(moving_piece.color, position) }

    path.all? do |position|
      # avoid counting opponent king as a blocking piece when testing opponent king escape moves
      self[*position].nil? || escaping_king?(position, moving_piece)
    end
  end

  def escaping_king?(position, moving_piece)
    self[*position].instance_of?(King) && opponent?(moving_piece, position)
  end

  def occupied?(position)
    !self[*position].nil?
  end

  def opponent?(moving_piece, new_position)
    other_piece = self[*new_position]
    moving_piece.color != other_piece.color
  end

  def path(old_position, new_position)
    column_difference, row_difference = position_difference(old_position, new_position)

    if column_difference.zero?
      vertical_path(old_position, new_position)
    elsif row_difference.zero?
      horizontal_path(old_position, new_position)
    elsif column_difference == row_difference
      diagonal_path(old_position, new_position)
    else
      raise StandardError, 'Attempted path not valid'
    end
  end

  def horizontal_path(old_position, new_position)
    row_idx = old_position[1] # constant since moving horizontally
    column_idx_range = exclusive_range(old_position[0], new_position[0])

    column_idx_range.map { |column_idx| [column_idx, row_idx] }
  end

  def vertical_path(old_position, new_position)
    column_idx = old_position[0] # constant since moving vertically
    row_idx_range = exclusive_range(old_position[1], new_position[1])

    row_idx_range.map { |row_idx| [column_idx, row_idx] }
  end

  def diagonal_path(old_position, new_position)
    path = []
    column_idx_range = exclusive_range(old_position[0], new_position[0])
    row_idx_range = exclusive_range(old_position[1], new_position[1])

    column_idx_range.each_with_index do |column_idx, i|
      path << [column_idx, row_idx_range[i]]
    end

    path
  end

  def exclusive_range(start, finish)
    if start < finish
      start.upto(finish).to_a[1..-2]
    else
      start.downto(finish).to_a[1..-2]
    end
  end
end
