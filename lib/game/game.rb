# frozen_string_literal: true

require_relative '../board/board'
require_relative 'modules/game_serializable'

# This class represents one round of the game chess
#
# It handles taking turns, storing past moves, and
# special move logic (ex. en passant, castling)
class Game
  include GameSerializable
  def initialize(players, current_player_id = 0, board = Board.new)
    @players = players
    @current_player_id = current_player_id
    @board = board

    play
  end

  def play
    loop do
      current_player = @players[@current_player_id]
      if @board.checkmate?(current_player.color)
        GameUI.announce_checkmate(current_player.name)
        return
      end
      current_player.make_move(@board)
      switch_players
      save_game if GameUI.save_game?
    end
  end

  private

  def switch_players
    @current_player_id = 1 - @current_player_id
  end
end
