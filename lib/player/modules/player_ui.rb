# frozen_string_literal: true

# This modules contains methods inherited by HumanPlayer and
# ComputerPlayer from the Player class
#
# It handles outputting command line messages for the human player
module PlayerUI
  private

  def announce_turn(player_class_name)
    puts "\n———————————————————————————————————————————————————————————————"
    case player_class_name
    when 'HumanPlayer'
      puts "#{@name}, it's your turn! You are playing #{@color}."
    when 'ComputerPlayer'
      puts "It's #{name}'s turn! It is playing #{@color}."
    end
  end

  def announce_move(result, piece, alphanum_original_position, alphanum_new_position, board)
    print "\n#{@name} moved #{piece.class.name} from #{alphanum_original_position} to #{alphanum_new_position}"

    if result[:castling]
      print ' via castling'
    elsif result[:capture]
      print ' and captured an opponent piece'
      print ' via en passant' if result[:en_passant]
    end

    print "\n\n"
    board.display
  end

  def announce_pawn_promotion(piece, promotion_piece_name)
    puts "\n#{@name}'s pawn at #{piece.position} has been promoted to a #{promotion_piece_name}."
  end
end
