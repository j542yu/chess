# frozen_string_literal: true

require_relative 'player'

# This class represents a computer player in chess,
# and is a child class of Player
#
# It handles making a random legal move when prompted by Game
class ComputerPlayer < Player
  NAME = 'Marvin the Computer'

  def initialize(color)
    super
    @name = NAME
  end

  def make_move(board) # rubocop:disable Metrics/MethodLength
    super()

    loop do
      pieces = case @color
               when :black
                 board.instance_variable_get(:@pieces_black)
               when :white
                 board.instance_variable_get(:@pieces_white)
               end

      piece = pieces.sample
      old_position = piece.position
      possible_move = possible_moves(piece).sample
      result = board.move_piece(piece, possible_move)
      next unless result[:move_valid] && !result[:endangers_king]

      promote_pawn(board, piece) if result[:promote_pawn]

      announce_move(result, piece, indices_to_alphanum(old_position), indices_to_alphanum(possible_move), board)
      return
    end
  end

  def possible_moves(piece)
    possible_moves = []

    possible_moves.push(*piece.next_moves)

    if piece.instance_of?(King)
      add_castling_moves(piece, possible_moves)
    elsif piece.instance_of?(Pawn)
      add_diagonal_moves(piece, possible_moves)
    end

    possible_moves
  end

  def add_castling_moves(piece, possible_moves)
    position = piece.position

    castling_moves = [[position[0] + 2, position[1]], [position[0] - 2, position[1]]].select do |move|
      piece.between_board_bounds?(move)
    end

    possible_moves.push(*castling_moves)
  end

  def add_diagonal_moves(piece, possible_moves) # rubocop:disable Metrics/MethodLength
    position = piece.position

    new_row_idx = case piece.color
                  when :black
                    position[1] - 1
                  when :white
                    position[1] + 1
                  end

    diagonal_moves = [[position[0] - 1, new_row_idx], [position[0] + 1, new_row_idx]].select do |move|
      piece.between_board_bounds?(move)
    end

    possible_moves.push(*diagonal_moves)
  end

  def indices_to_alphanum(indices)
    "#{(indices[0] + 'a'.ord).chr}#{8 - indices[1]}"
  end

  def promote_pawn(board, piece)
    promotion_piece_name = %w[Queen Knight Rook Bishop].sample

    super(board, piece, promotion_piece_name)
  end

  def announce_turn
    super(self.class.name)
  end
end
