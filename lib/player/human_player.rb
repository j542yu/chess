# frozen_string_literal: true

require_relative 'player'
require_relative 'modules/human_player_ui'

# This class represents a human player in chess,
# and is a child class of Player
#
# It handles storing the player's name and color,
# and interacting with the player via the command line
class HumanPlayer < Player
  include HumanPlayerUI

  def initialize(color, player_num, name = nil)
    super(color)
    @player_num = player_num # greet differently if two human players VS human against computer
    @name = name || ask_player_name
  end

  def make_move(board) # rubocop:disable Metrics/MethodLength
    super()
    board.display

    loop do
      alphanum_original_position, indices_original_position = ask_for_position(board, :original)

      piece = board[*indices_original_position]

      alphanum_new_position, indices_new_position = ask_for_position(board, :new)

      result = board.move_piece(piece, indices_new_position)
      if result[:move_valid] && !result[:endangers_king]
        announce_move(result, piece, alphanum_original_position, alphanum_new_position, board)
        promote_pawn(board, piece) if result[:promote_pawn]
        return
      else
        announce_failed_move(result, piece, alphanum_new_position)
      end
    end
  end

  private

  def empty?(board, position)
    board[position[0]][position[1]].nil?
  end

  def move_syntax_valid?(position)
    position.size == 2 && ('a'..'h').include?(position[0]) && ('1'..'8').include?(position[1])
  end

  def move_color_valid?(board, position)
    moving_piece_color = board[position[0]][position[1]].color
    moving_piece_color == @color
  end

  def alphanum_to_indices(alphanum)
    [alphanum[0].ord - 'a'.ord, 8 - alphanum[1].to_i]
  end

  def promote_pawn(board, piece)
    return unless ask_to_promote_pawn

    promotion_piece_name = ask_promotion_piece_name

    super(board, piece, promotion_piece_name)
  end
end
