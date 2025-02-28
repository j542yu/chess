# frozen_string_literal: true

using Rainbow

# This class handles loading saved games and is
# used in main.rb
class GameLoader
  def self.load_saved_game # rubocop:disable Metrics/MethodLength
    save_files = Dir.glob("#{GameSerializable::SAVE_FOLDER_NAME}/*.yaml")

    if save_files.empty?
      puts ''
      print 'No saves found. '
      load_new_game
    elsif save_files.size == 1
      load_from_file(save_files[0])
    else
      file_name = GameUI.ask_for_file_choice(save_files)
      load_from_file(file_name)
    end
  end

  def self.load_from_file(file_name) # rubocop:disable Metrics/MethodLength
    yaml_data = File.read(file_name)

    allowed_classes = [Game, HumanPlayer, Board, Symbol,
                       Rook, Bishop, Knight, Queen, King, Pawn]
    game_data = YAML.safe_load(yaml_data, permitted_classes: allowed_classes, aliases: true)
    puts "\nSuccessfully loaded #{file_name[6..-6]}".green

    Game.from_h(game_data)

    true
  rescue Psych => e
    puts ''
    puts "Error loading saved game: #{e.message}".red.bg(:silver)
    false
  end

  def self.load_new_game
    GameUI.announce_new_game
    Game.new
  end
end
