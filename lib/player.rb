# frozen_string_literal: true

# This class represents a human player in chess
#
# It handles storing the player's name
# and interacting with the player via the command line
class HumanPlayer
  RANDOM_NAMES = ['Chris P Bacon', 'Zoltan Pepper', 'Ella Vader', 'Amy Stake', 'Barb Dwyer', 'Justin Case'].freeze

  def initialize(color, player_num = 0)
    @player_num = player_num # greet differently if two human players VS human against computer
    @name = ask_name
    @color = color
  end

  def ask_name
    print @player_num.positive? ? "Hey, player #{@player_num}!" : 'Hey you, yes you the human.'
    print "What's your name? Psst... just press enter if you want a random name :>\n=> "

    name = gets.chomp
    return name unless name.empty?

    name = RANDOM_NAMES.sample
    puts "Alright then, you'll be #{name} (sorry...)."
    name
  end
end
