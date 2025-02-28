# frozen_string_literal: true

using Rainbow

# This module handles human player interactions through the command line
# and is meant to be used with the HumanPlayer class
#
# Some methods build off on inherited methods from the Player class
# in the PlayerUI module
module HumanPlayerUI
  private

  def ask_player_name
    print @player_num.positive? ? "\nHey, player #{@player_num}! ".blue : "\nHey you, yes you the human. ".blue
    print "What's your name?\n=> ".blue

    name = gets.chomp
    return name unless name.empty?

    default_name = @player_num.positive? ? "Player #{@player_num}" : 'Unnamed Player'
    puts "Alright then, you'll be #{default_name}."
    default_name
  end

  def ask_for_position(board, type)
    case type
    when :original
      print "\nEnter the position of the piece you want to move\n=> ".blue
      alphanum_position = validate_move_syntax(board, type, consider_color: true)
    when :new
      print "\nEnter the position to which you want to move your piece\n=> ".blue
      alphanum_position = validate_move_syntax(board, type, consider_color: false)
    end

    [alphanum_position, alphanum_to_indices(alphanum_position)]
  end

  def validate_move_syntax(board, type, consider_color: false) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    loop do
      input = gets.chomp
      if !move_syntax_valid?(input)
        puts ''
        puts "Oops, that's invalid. Your input must be a letter followed by a number, like 'e4'."
          .red.bg(:silver)
        print "Try again please!\n=> ".blue
      elsif type == :original && empty?(board, alphanum_to_indices(input))
        puts ''
        puts "There's no piece at #{input}.".red.bg(:silver)
        print "Try again please!\n=> ".blue
      elsif consider_color && !move_color_valid?(board, alphanum_to_indices(input))
        puts ''
        puts "Hmm, you're not allowed to move the piece at #{input}... You can only move #{@color} pieces."
          .red.bg(:silver)
        print "Try again please!\n=> ".blue
      else
        return input
      end
    end
  end

  def announce_turn
    super(self.class.name)
  end

  def announce_failed_move(piece, alphanum_new_position)
    puts ''
    puts "#{piece.class.name} cannot move to #{alphanum_new_position}. It's an illegal move."
      .red.bg(:silver)
    puts 'Try again please!'.blue
  end

  def ask_to_promote_pawn # rubocop:disable Metrics/MethodLength
    print "\n#{@name}, your pawn is eligible to be promoted! Would you like to promote your pawn? (Y/N)\n=> ".blue
    loop do
      case gets.chomp.upcase
      when 'Y'
        return true
      when 'N'
        return false
      else
        puts ''
        puts "Invalid input. Please enter 'Y' to promote your pawn, or 'N' to leave the pawn as is."
          .red.bg(:silver)
        print '=> '
      end
    end
  end

  def ask_promotion_piece_name
    print "\n What piece would you like to promote your pawn to? (Queen/Knight/Rook/Bishop)\n=> ".blue
    loop do
      choice = gets.chomp.capitalize
      return choice if %w[Queen Knight Rook Bishop].include?(choice)

      puts ''
      puts "Invalid input. Please enter 'Queen', 'Knight', 'Rook', or 'Bishop'".red.bg(:silver)
      print '=> '.blue
    end
  end
end
