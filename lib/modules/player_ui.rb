# frozen_string_literal: true

# This module handles player interactions through the command line
# and is meant to be used with the Player class
module PlayerUI
  def ask_player_name
    print @player_num.positive? ? "\nHey, player #{@player_num}! " : 'Hey you, yes you the human. '
    print "What's your name?\n=> "

    name = gets.chomp
    return name unless name.empty?

    puts "Alright then, you'll be Player #{@player_num}."
    "Player #{@player_num}"
  end

  def ask_for_position(board, type)
    case type
    when :original
      print "\nEnter the position of the piece you want to move\n=> "
      alphanum_position = validate_move_syntax(board, type, consider_color: true)
    when :new
      print "\nEnter the position to which you want to move your piece\n=> "
      alphanum_position = validate_move_syntax(board, type, consider_color: false)
    end

    [alphanum_position, alphanum_to_indices(alphanum_position)]
  end

  def validate_move_syntax(board, type, consider_color: false) # rubocop:disable Metrics/MethodLength
    loop do
      input = gets.chomp
      if !move_syntax_valid?(input)
        print "\nOops, that's invalid. Your input must be a letter followed by a number, like 'e4'.\n" \
              "Try again please!\n=> "
      elsif type == :original && empty?(board, alphanum_to_indices(input))
        print "\nThere's no piece at #{input}. Try again please!\n=> "
      elsif consider_color && !move_color_valid?(board, alphanum_to_indices(input))
        print "\nHmm, you're not allowed to move the piece at #{input}... You can only move #{@color} pieces.\n" \
              "Try again please!\n=> "
      else
        return input
      end
    end
  end

  def announce_turn
    puts "\n#{@name}, it's your turn! You are playing #{@color}."
  end

  def announce_move(result, piece, alphanum_original_position, alphanum_new_position)
    print "\n#{@name} moved #{piece.class.name} from #{alphanum_original_position} to #{alphanum_new_position} "
    puts 'and captured an opponent piece' if result[:capture]
    puts 'via en passant' if result[:en_passant]
  end

  def announce_failed_move(piece, alphanum_new_position)
    puts "\n#{piece.class.name} cannot move to #{alphanum_new_position}. It's an illegal move. Try again please!"
  end

  def announce_pawn_promotion(piece, promotion_piece_name)
    puts "\n#{@name}'s pawn at #{piece.position} has been promoted to a #{promotion_piece_name}."
  end

  def ask_to_promote_pawn # rubocop:disable Metrics/MethodLength
    print "\n#{@name}, your pawn is eligible to be promoted! Would you like to promote your pawn? (Y/N)\n=> "
    loop do
      case gets.chomp.upcase
      when 'Y'
        return true
      when 'N'
        return false
      else
        print "\nInvalid input. Please enter 'Y' to promote your pawn, or 'N' to leave the pawn as is.\n=> "
      end
    end
  end

  def ask_promotion_piece_name
    print "\n What piece would you like to promote your pawn to? (Queen/Knight/Rook/Bishop)\n=> "
    loop do
      choice = gets.chomp.capitalize
      return choice if %w[Queen Knight Rook Bishop].include?(choice)

      print "\nInvalid input. Please enter 'Queen', 'Knight', 'Rook', or 'Bishop'\n=> "
    end
  end
end
