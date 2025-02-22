# frozen_string_literal: true

# This module handles validating moves when moving game pieces
# in a Board instance
module MoveValidation
  private

  def valid_move?(piece, old_position, new_position)
    return valid_pawn_move?(piece, old_position, new_position) if piece.instance_of?(Pawn)

    piece.next_moves.include?(new_position) &&
      path_clear?(piece, old_position, new_position) &&
      (!occupied?(new_position) || opponent?(piece, new_position))
  end

  def valid_pawn_move?(piece, old_position, new_position)
    (piece.next_moves.include?(new_position) &&
       path_clear?(piece, old_position, new_position) && !occupied?(new_position)) ||
      (pawn_can_diagonal_move?(piece, old_position, new_position) && opponent?(piece, new_position))
  end

  def pawn_can_diagonal_move?(piece, old_position, new_position)
    return false unless occupied?(new_position)

    diagonal_moves = piece.color == :black ? [[1, 1], [-1, 1]] : [[1, -1], [-1, -1]]

    diagonal_moves.any? do |diagonal_move|
      new_position == [old_position[0] + diagonal_move[0], old_position[1] + diagonal_move[1]]
    end
  end

  def path_clear?(piece, old_position, new_position)
    return true if piece.instance_of?(Knight)

    path = path(piece, old_position, new_position)
    path.all? { |column_idx, row_idx| @board[column_idx][row_idx].nil? }
  end

  def occupied?(position)
    !@board[position[0]][position[1]].nil?
  end

  def opponent?(piece, new_position)
    other_piece = @board[new_position[0]][new_position[1]]
    piece.color != other_piece.color
  end

  def path(piece, old_position, new_position)
    paths = {
      Queen: %i[horizontal_path vertical_path diagonal_path],
      Rook: %i[horizontal_path vertical_path],
      Bishop: %i[diagonal_path],
      Pawn: %i[vertical_path]
    }

    paths[piece.class.name.to_sym].flat_map { |method| send(method, old_position, new_position) }
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
