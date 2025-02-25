# frozen_string_literal: true

require_relative 'player'
require_relative 'board'
require_relative 'serializable/game_serializable'

# This class represents one round of the game chess
#
# It handles taking turns, storing past moves, and
# special move logic (ex. en passant, castling)
class Game
  include GameSerializable
  def initialize(players = [HumanPlayer.new(:white, 1), HumanPlayer.new(:black, 2)],
                 current_player_id = 0, board = Board.new)
    @players = players
    @current_player_id = current_player_id
    @board = board

    play
  end

  def play
    puts "\nPress Ctrl-C to exit the game at any point. Let the games begin!"
    loop do
      current_player.make_move(@board)
      if @board.checkmate?(current_player.color)
        announce_checkmate
        return
      end

      switch_players
      save_game?
    end
  end

  private

  def announce_checkmate
    puts "\nGame over! #{current_player.name} has been checkmated. Good game!"
  end

  def current_player
    @players[@current_player_id]
  end

  def other_player
    @players[1 - @current_player_id]
  end

  def switch_players
    @current_player_id = 1 - @current_player_id
  end

  def save_game? # rubocop:disable Metrics/MethodLength
    print "Press Enter to continue, or type in 'S' to save the current game\n=> "

    loop do
      case gets.chomp.upcase
      when ''
        return false
      when 'S'
        save_game
        return true
      end

      print "\nInvalid choice. Please click Enter to continue or type in 'S' to save the current game.\n=> "
    end
  end
end
