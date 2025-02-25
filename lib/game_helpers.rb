# frozen_string_literal: true

# This class handles loading saved games and is
# used in main.rb
class GameLoader
  def self.load_saved_game
    save_files = Dir.glob("#{GameSerializable::SAVE_FOLDER_NAME}/*.yaml")

    if save_files.empty?
      puts "\nNo saves found. A new one will be started!"
      Game.new
    elsif save_files.size == 1
      load_from_file(save_files[0])
    else
      file_name = GameUI.ask_for_file_choice(save_files)
      load_from_file(file_name)
    end
  end

  def self.load_from_file(file_name)
    yaml_data = File.read(file_name)

    allowed_classes = [Game, HumanPlayer, Board, Symbol,
                       Rook, Bishop, Knight, Queen, King, Pawn]
    game_data = YAML.safe_load(yaml_data, permitted_classes: allowed_classes, aliases: true)
    puts "\nSuccessfully loaded #{file_name[6..-6]}."

    Game.from_h(game_data)

    true
  rescue Psych => e
    puts "\nError loading saved game: #{e.message}"
    false
  end
end

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

  def self.announce_checkmate(name)
    puts "\nGame over! #{name} has been checkmated. Good game!"
  end

  def self.save_game?
    print "\nPress Enter to continue, or type in 'S' to save the current game\n=> "

    loop do
      case gets.chomp.upcase
      when ''
        return false
      when 'S'
        return true
      end

      print "\nInvalid choice. Please click Enter to continue or type in 'S' to save the current game.\n=> "
    end
  end

  def self.ask_for_file_choice(save_files)
    puts "\nSelect a save file to load:"
    save_files.each_with_index do |file_name, idx|
      puts "  #{idx + 1}. #{file_name}"
    end
    print '=> '

    loop do
      choice = gets.chomp.to_i - 1
      return save_files[choice] if choice.between?(0, save_files.size - 1)

      print "\nInvalid file chosen. Please pick a number between 1 and #{save_files.size}.\n=> "
    end
  end

  def self.ask_to_load_game # rubocop:disable Metrics/MethodLength
    print "\nWould you like to load a previously saved game? (Y/N)\n=> "

    loop do
      case gets.chomp.upcase
      when 'Y'
        return true
      when 'N'
        return false
      else
        print "\nInvalid choice. Please enter 'Y' to open a saved game or 'N' to start a new game.\n=> "
      end
    end
  end
end
