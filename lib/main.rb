# frozen_string_literal: true

require 'rainbow/refinement'
require_relative 'game/game'
require_relative 'game/game_loader'
require_relative 'game/game_ui'

GameUI.announce_intro

if GameUI.ask_to_load_game
  GameLoader.load_saved_game
else
  GameLoader.load_new_game
end
