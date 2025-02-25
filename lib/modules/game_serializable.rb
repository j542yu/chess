# frozen_string_literal: true

require 'fileutils'
require 'yaml'

# This module handles serializing Game object data and
# saving / opening saved games,
# and is included in the Game class
module GameSerializable
  def self.included(base)
    base.extend(ClassMethods)
  end

  SAVE_FOLDER_NAME = 'saves'

  def save_game
    FileUtils.mkdir_p(SAVE_FOLDER_NAME)

    file_contents = to_yaml

    num_of_saves = Dir.entries(SAVE_FOLDER_NAME).size - 2

    file_name = "#{SAVE_FOLDER_NAME}/save_#{num_of_saves + 1}.yaml"

    File.open(file_name, 'w') { |file| file.puts file_contents }

    puts "\nCurrent game progress has been saved under #{file_name}."
  end

  def to_h
    {
      players: @players.map(&:to_h),
      current_player_id: @current_player_id,
      board: @board.to_h
    }
  end

  module ClassMethods
    def from_h(game_data)
      players = game_data[:players].map do |player_data|
        klass = Object.const_get(player_data[:type])
        klass.from_h(player_data)
      end

      Game.new(players, game_data[:current_player_id], Board.from_h(game_data[:board]))
    end
  end

  private

  def to_yaml
    YAML.dump(to_h)
  end
end
