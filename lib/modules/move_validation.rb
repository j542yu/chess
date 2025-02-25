# frozen_string_literal: true

require_relative 'move_validation_helpers'

# This module contains Board#move_piece helper functions
# specific to validating moves
module MoveValidation
  include CastlingValidation
  include PawnValidation

  private

  def valid_move?(moving_piece, old_position, new_position)
    result = { move_valid: false, castling: false }

    if moving_piece.instance_of?(Pawn)
      result[:move_valid] = valid_pawn_move?(moving_piece, old_position, new_position)
    else
      result[:move_valid] = valid_generic_piece_move?(moving_piece, old_position, new_position)
      result[:castling] = castling?(moving_piece, old_position, new_position)
    end

    result
  end

  def valid_generic_piece_move?(moving_piece, old_position, new_position)
    moving_piece.next_moves.include?(new_position) &&
      path_clear?(moving_piece, old_position, new_position) &&
      (!occupied?(new_position) || opponent?(moving_piece, new_position))
  end

  def path_clear?(moving_piece, old_position, new_position)
    return true if moving_piece.instance_of?(Knight)

    path = path(moving_piece, old_position, new_position)
    path.all? { |position| self[*position].nil? }
  end

  def occupied?(position)
    !self[*position].nil?
  end

  def opponent?(moving_piece, new_position)
    other_piece = self[*new_position]
    moving_piece.color != other_piece.color
  end

  def path(moving_piece, old_position, new_position)
    paths = {
      Queen: %i[horizontal_path vertical_path diagonal_path],
      Rook: %i[horizontal_path vertical_path],
      Bishop: %i[diagonal_path],
      Pawn: %i[vertical_path],
      King: %i[horizontal_path] # for castling check only
    }

    paths[moving_piece.class.name.to_sym].flat_map { |method| send(method, old_position, new_position) }
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
