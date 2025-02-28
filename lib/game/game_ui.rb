# frozen_string_literal: true

using Rainbow

# This class handles interacting with the human player
# from the Game level
class GameUI
  def self.announce_intro
    puts <<~HEREDOC
      ———————————————————————————————————————————————————————————————
      Welcome to Chess!

      If you are not familiar with the rules, take a look at this:
        https://www.instructables.com/Playing-Chess/

      Press Ctrl-C to exit the game at any point. Let the games begin!
      ———————————————————————————————————————————————————————————————
    HEREDOC
  end

  def self.ask_player_types # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    puts "\n\nChoose game mode:".blue
    puts "\t1. Human against Human".blue
    puts "\t2. Human against Computer".blue
    print '=> '.blue

    loop do
      case gets.chomp.to_i
      when 1
        return :human_human
      when 2
        return :human_computer
      else
        puts ''
        puts "Invalid choice. Please enter '1' for two human players or '2' for human against computer".red.bg(:silver)
        print '=> '.blue
      end
    end
  end

  def self.announce_new_game(player_one_class, player_two_class)
    puts "\nA new #{player_one_class} VS #{player_two_class} game will be started!"
  end

  def self.announce_checkmate(name)
    puts "\nGame over! #{name} has been checkmated. Good game!".green
  end

  def self.save_game? # rubocop:disable Metrics/MethodLength
    puts "\n\nPress Enter to continue, or type in 'S' to save the current game".green
    print '=> '.blue

    loop do
      case gets.chomp.upcase
      when ''
        return false
      when 'S'
        return true
      end

      puts ''
      puts "Invalid choice. Please click Enter to continue or type in 'S' to save the current game."
        .red.bg(:silver)
      print '=> '.blue
    end
  end

  def self.ask_for_file_choice(save_files) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    puts "\nSelect a save file to load:".blue
    save_files.each_with_index do |file_name, idx|
      puts "  #{idx + 1}. #{file_name}"
    end
    print '=> '.blue

    loop do
      choice = gets.chomp.to_i - 1
      return save_files[choice] if choice.between?(0, save_files.size - 1)

      puts ''
      puts "Invalid file chosen. Please pick a number between 1 and #{save_files.size}.".red.bg(:silver)
      print '=> '.blue
    end
  end

  def self.ask_to_load_game # rubocop:disable Metrics/MethodLength
    print "\nWould you like to load a previously saved game? (Y/N)\n=> ".blue

    loop do
      case gets.chomp.upcase
      when 'Y'
        return true
      when 'N'
        return false
      else
        puts ''
        puts "Invalid choice. Please enter 'Y' to open a saved game or 'N' to start a new game.".red.bg(:silver)
        print '=> '.blue
      end
    end
  end
end
