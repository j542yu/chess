# frozen_string_literal: true

require_relative 'player'
require_relative 'board'

# This class represents one round of the game chess
#
# It handles taking turns, storing past moves, and
# special move logic (ex. en passant, castling)
class Game
  def initialize(player_one = HumanPlayer.new(:white, 1), player_two = HumanPlayer(:black, 2))
    @players = [player_one, player_two]
    @current_player_id = 0
    @board = Board.new
  end

  private

  def announce_intro # rubocop:disable Metrics/MethodLength
    puts <<~HEREDOC

      Welcome to Chess!

      If you are not familiar with the rules, read this:
        https://www.instructables.com/Playing-Chess/

    HEREDOC

    if @players[0].instance_of?(HumanPlayer) && @players[1].instance_of?(HumanPlayer)
      puts 'Two human players will take turns and play against each other.'
    else
      puts "You will be battling a computer player!!! (don't worry, it's not very smart...)"
    end

    puts "\nLet the game begin!"
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
end
