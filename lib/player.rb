# frozen_string_literal: true

require_relative 'modules/player_ui'

# This class represents a human player in chess
#
# It handles storing the player's name
# and interacting with the player via the command line
class HumanPlayer
  include PlayerUI

  def initialize(color, player_num = 0, name = nil)
    @color = color
    @player_num = player_num # greet differently if two human players VS human against computer
    @name = name || ask_player_name
  end

  attr_reader :name, :color

  def make_move(board) # rubocop:disable Metrics/MethodLength
    announce_turn
    board.display

    loop do
      alphanum_original_position, indices_original_position = ask_for_position(board, :original)

      piece = board[*indices_original_position]

      alphanum_new_position, indices_new_position = ask_for_position(board, :new)

      result = board.move_piece(piece, indices_new_position)
      if result[:move_valid]
        announce_move(result, piece, alphanum_original_position, alphanum_new_position)
        promote_pawn(board, piece) if result[:promote_pawn]
        return
      else
        announce_failed_move(piece, alphanum_new_position)
      end
    end
  end

  def to_h
    {
      type: self.class.name,
      color: @color,
      player_num: @player_num,
      name: @name
    }
  end

  def self.from_h(player_data)
    new(player_data[:color], player_data[:player_num], player_data[:name])
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
    board.promote_pawn(piece, promotion_piece_name)

    announce_pawn_promotion(piece, promotion_piece_name)
  end
end
