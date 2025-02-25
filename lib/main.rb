# frozen_string_literal: true

require 'rainbow/refinement'
using Rainbow
require_relative 'game'

def announce_intro
  puts <<~HEREDOC
    ———————————————————————————————————————————————————————————————
    Welcome to Chess!

    If you are not familiar with the rules, take a look at this:
      https://www.instructables.com/Playing-Chess/
    ———————————————————————————————————————————————————————————————


  HEREDOC
end

def load_saved_game
  save_files = Dir.glob("#{GameSerializable::SAVE_FOLDER_NAME}/*.yaml")

  if save_files.empty?
    puts "\nNo saves found. A new one will be started!"
    Game.new
  else
    file_name = ask_for_file_choice(save_files)
    load_from_file(file_name)
  end
end

def ask_for_file_choice(save_files)
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

def load_from_file(file_name)
  yaml_data = File.read(file_name)

  allowed_classes = [Game, HumanPlayer, Board, Symbol,
                     Rook, Bishop, Knight, Queen, King, Pawn]
  game_data = YAML.safe_load(yaml_data, permitted_classes: allowed_classes, aliases: true)
  Game.from_h(game_data)
  puts "\nSuccessfully loaded #{file_name}."
  true
rescue Psych
  puts "Error loading saved game: #{e.message}"
  false
end

announce_intro

print "Would you like to load a previously saved game? (Y/N)\n=> "

loop do
  case gets.chomp.upcase
  when 'Y'
    load_saved_game
    break
  when 'N'
    puts "\nA new game will be started!"
    Game.new
    break
  else
    print "Invalid choice. Please enter 'Y' to open a saved game or 'N' to start a new game.\n=> "
  end
end
