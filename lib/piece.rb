# frozen_string_literal: true

require_relative 'moveable'

# This class represents a game piece in chess
#
# It handles storing info (position, color, array of next moves, array of past moves)
# and validating a given move is within game board boundaries
#
# It has child classes for each different type of game piece
class Piece
  def initialize(position, color)
    @position = position
    @color = color
    @next_moves = []
    @past_moves = []
  end

  attr_reader :position, :color, :next_moves

  def between_board_bounds?(move)
    move[0].between?(0, 7) && move[1].between?(0, 7)
  end

  def update_next_moves
    @next_moves.clear
  end
end

# This is a child class of Piece that represents the King game piece
#
# It handles storing its position and color,
# and updating its possible next moves when it moves to a new position
class King < Piece
  include KingMoveable

  def update_next_moves
    super
    generate_king_moves(@next_moves)
  end
end

# This is a child class of Piece that represents the Queen game piece
#
# It handles storing its position and color,
# and updating its possible next moves when it moves to a new position
class Queen < Piece
  include HorizontalVerticalMoveable
  include DiagonalMoveable

  def update_next_moves
    super
    generate_horizontal_and_vertical_moves(@next_moves)
    generate_diagonal_moves(@next_moves)
  end
end

# This is a child class of Piece that represents the Rook game piece
#
# It handles storing its position and color,
# and updating its possible next moves when it moves to a new position
class Rook < Piece
  include HorizontalVerticalMoveable

  def update_next_moves
    super
    generate_horizontal_and_vertical_moves(@next_moves)
  end
end

# This is a child class of Piece that represents the Bishop game piece
#
# It handles storing its position and color,
# and updating its possible next moves when it moves to a new position
class Bishop < Piece
  include DiagonalMoveable

  def update_next_moves
    super
    generate_diagonal_moves(@next_moves)
  end
end

# This is a child class of Piece that represents the Knight game piece
#
# It handles storing its position and color,
# and updating its possible next moves when it moves to a new position
class Knight < Piece
  include KnightMoveable

  def update_next_moves
    super
    generate_knight_moves(@next_moves)
  end
end

# This is a child class of Piece that represents the Pawn game piece
#
# It handles storing its position and color,
# and updating its possible next moves when it moves to a new position
class Pawn < Piece
  include PawnMoveable

  def update_next_moves
    super
    generate_pawn_moves(color, @next_moves)
  end
end
