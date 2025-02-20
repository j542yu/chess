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
    @move_history = []
  end

  def in_check?(color, potential_escape_position = nil)
    opponent_color = color == :black ? :white : :black
    opponent_pieces = opponent_color == :black ? @board.pieces_black : @board.pieces_white
    king_position = potential_escape_position || @board.kings[color].position

    opponent_pieces.each do |piece|
      return true if piece_threatens_king?(piece, opponent_color, king_position)
    end

    false
  end

  def checkmate?(color)
    false unless in_check?(color)
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

  def pawn_threatens_king?(piece, opponent_color, king_position)
    diagonal_moves = opponent_color == :black ? [[1, 1], [-1, 1]] : [[1, -1], [-1, -1]]
    diagonal_moves.each do |diagonal_move|
      return true if king_position == [piece.position[0] + diagonal_move[0],
                                       piece.position[1] + diagonal_move[1]]
    end
    false
  end

  def piece_threatens_king?(piece, opponent_color, king_position)
    return pawn_threatens_king?(piece, opponent_color, king_position) if piece.type == :pawn

    piece.next_moves.include?(king_position)
  end
end
