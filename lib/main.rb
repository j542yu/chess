# frozen_string_literal: true

require 'rainbow/refinement'
using Rainbow
require_relative 'game'
require_relative 'game_helpers'

GameUI.announce_intro

if GameUI.ask_to_load_game
  GameLoader.load_saved_game
else
  puts "\nA new game will be started!"
  Game.new
end
