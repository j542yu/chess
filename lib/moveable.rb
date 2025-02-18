# frozen_string_literal: true

# NOTE: All modules in this file are meant to be used by instances of Piece and its child classes

# This module handles generating moves within board boundaries given the direction of move(s) one unit in length
module Moveable
  def generate_next_extending_moves(unit_moves, next_moves = [])
    unit_moves.each do |unit_move|
      # since board is 8 x 8, this tests all possible moves to the remaining 7 positions
      7.times do |i|
        # NOTE: i + 1 is used since i goes from 0 to 6
        next_move = [position[0] + ((i + 1) * unit_move[0]),
                     position[1] + ((i + 1) * unit_move[1])]
        next_moves << next_move if between_board_bounds?(next_move)
      end
    end

    next_moves
  end

  def generate_next_unit_moves(unit_moves, next_moves = [])
    unit_moves.each do |move|
      next_move = [position[0] + move[0], position[1] + move[1]]
      next_moves << next_move if between_board_bounds?(next_move)
    end

    next_moves
  end
end

# This module handles generating moves within board boundaries in the diagonal direction
module DiagonalMoveable
  include Moveable
  def generate_diagonal_moves(next_moves = [])
    unit_moves = [[1, 1], [1, -1], [-1, 1], [-1, -1]]

    generate_next_extending_moves(unit_moves, next_moves)
  end
end

# This module handles generating moves within board boundaries in the horizontal and vertical direction
module HorizontalVerticalMoveable
  include Moveable
  def generate_horizontal_and_vertical_moves(next_moves = [])
    unit_moves = [[1, 0], [-1, 0], [0, 1], [0, -1]]

    generate_next_extending_moves(unit_moves, next_moves)
  end
end

# This module handles generating moves within board boundaries for Knight game pieces
module KnightMoveable
  include Moveable
  def generate_knight_moves(next_moves = [])
    unit_moves = [[2, 1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2]]

    generate_next_unit_moves(unit_moves, next_moves)
  end
end

# This module handles generating moves within board boundaries for Pawn game pieces
module PawnMoveable
  def generate_pawn_moves(color, next_moves = [])
    unit_move = color == 'black' ? [0, 1] : [0, -1]
    next_move = if at_starting_position?(color) # double move from start
                  [position[0], position[1] + (unit_move[1] * 2)]
                else
                  [position[0], position[1] + unit_move[1]]
                end

    next_moves << next_move if between_board_bounds?(next_move)
    next_moves
  end

  def at_starting_position?(color)
    position[1] == if color == 'black'
                     1
                   else
                     6
                   end
  end
end

# This module handles generating moves within board boundaries for King game pieces
module KingMoveable
  include Moveable
  def generate_king_moves(next_moves = [])
    unit_moves = [[1, 0], [1, 1], [0, 1], [-1, 0], [-1, -1], [0, -1], [1, -1], [-1, 1]]

    generate_next_unit_moves(unit_moves, next_moves)
  end
end
