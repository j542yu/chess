# frozen_string_literal: true

# This class represents a human player in chess
#
# It handles storing the player's name
# and interacting with the player via the command line
class HumanPlayer
  RANDOM_NAMES = ['Chris P Bacon', 'Zoltan Pepper', 'Ella Vader', 'Amy Stake', 'Barb Dwyer', 'Justin Case'].freeze

  def initialize(color, player_num = 0)
    @player_num = player_num # greet differently if two human players VS human against computer
    @name = ask_player_name
    @color = color
  end

  def make_move(board, previously_invalid: false)
    puts 'Your previous attempt was an illegal move. Try again.' if previously_invalid

    puts "#{name}, it's your turn!"

    piece_name = ask_for_piece_name
    piece = clarify_piece(piece_name, board)
    move = ask_for(:move)

    move_translator(move)

    [piece, move]
  end

  private

  def ask_player_name
    print @player_num.positive? ? "Hey, player #{@player_num}!" : 'Hey you, yes you the human.'
    print "What's your name? Psst... just press enter if you want a random name :>\n=> "

    name = gets.chomp
    return name unless name.empty?

    name = RANDOM_NAMES.sample
    puts "Alright then, you'll be #{name} (sorry...)."
    name
  end

  def ask_for_piece_name
    print "Enter the name of the piece to move:\n=> "

    input = nil
    loop do
      input = gets.chomp.capitalize.to_sym
      break if piece_valid?(input)

      print "Oop, that's not a piece in chess.\n" \
            'Your input should be any of the following:' \
            "'Rook', 'Knight', 'Bishop', 'Queen', 'King', 'Pawn'\n=> "
    end
  end

  def clarify_piece(piece_name, board) # rubocop:disable Metrics/AbcSize
    pieces = board.ally_pieces(@color).select { |ally_piece| ally_piece.class.name.to_sym == piece_name }
    return if pieces.size == 1

    print "There's multiple #{piece_name}s: "
    pieces.each do |piece|
      alphanum_position = indices_to_alphanum(piece.position)
      print "#{alphanum_position} "
    end

    print "Which piece would you like to move?\n=>"
    position = ask_for(:position)
    pieces.find { |piece| piece.position == position }
  end

  def piece_valid?(input)
    %i[Rook Knight Bishop Queen King Pawn].include?(input)
  end

  def ask_for(input)
    print "Enter your #{input}:\n=> "
    loop do
      input = gets.chomp.chars
      return input if move_valid?(input)

      print "Oop, that's invalid. Your input should be a letter followed by a number, like 'e4'. Try again please!\n=> "
    end
  end

  def move_valid?(input)
    input.size == 2 && /[a-h]/.include?(input[0]) && (1..8).include?(input[1])
  end

  def alphanum_to_indices(alphanum)
    [ord(alphanum[0]) - ord('a'), alphanum[1].to_i - 1]
  end

  def indices_to_alphanum(indices)
    "#{(indices[0] + ord('a')).chr}#{indices[1] + 1}"
  end
end
