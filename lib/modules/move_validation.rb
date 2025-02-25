# frozen_string_literal: true

# This module handles validating moves when moving game pieces
# in a Board instance
module MoveValidation
  private

  def valid_move?(moving_piece, old_position, new_position)
    return valid_pawn_move?(moving_piece, old_position, new_position) if moving_piece.instance_of?(Pawn)

    moving_piece.next_moves.include?(new_position) &&
      path_clear?(moving_piece, old_position, new_position) &&
      (!occupied?(new_position) || opponent?(moving_piece, new_position))
  end

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
    column_difference = (last_move[2][0] - moving_piece.position[0]).abs
    row_difference = (last_move[2][1] - moving_piece.position[1]).abs
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
      Pawn: %i[vertical_path]
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
