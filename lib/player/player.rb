# frozen_string_literal: true

require_relative 'modules/player_ui'

# This class is the parent class for HumanPlayer and ComputerPlayer
class Player
  include PlayerUI

  def initialize(color)
    @color = color
  end

  attr_reader :name, :color

  def make_move
    announce_turn
  end

  def to_h(human: false)
    result = {
      type: self.class.name,
      color: @color,
      name: @name
    }

    result[:player_num] = @player_num if human

    result
  end

  def self.from_h(player_data)
    case player_data[:type]
    when 'HumanPlayer'
      new(player_data[:color], player_data[:player_num], player_data[:name])
    when 'ComputerPlayer'
      new(player_data[:color])
    end
  end

  private

  def promote_pawn(board, piece, promotion_piece_name)
    board.promote_pawn(piece, promotion_piece_name)

    announce_pawn_promotion(piece, promotion_piece_name)
  end
end
