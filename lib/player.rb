# frozen_string_literal: true

# This class represents a human player in chess
#
# It handles storing the player's name
# and interacting with the player via the command line
class HumanPlayer
  def initialize(color, player_num = 0, name = nil)
    @color = color
    @player_num = player_num # greet differently if two human players VS human against computer
    @name = name || ask_player_name
  end

  attr_reader :name, :color

  def make_move(board) # rubocop:disable Metrics/MethodLength
    puts "\n#{@name}, it's your turn! You are playing #{@color}."
    board.display

    loop do
      alphanum_original_position, indices_original_position = ask_for_position(board, :original)

      piece = board[*indices_original_position]

      alphanum_new_position, indices_new_position = ask_for_position(board, :new)

      if board.move_piece(piece, indices_new_position)
        puts "\n#{@name} moved #{piece.class.name} from #{alphanum_original_position} to #{alphanum_new_position}"
        return
      end

      puts "\n#{piece.class.name} cannot move to #{alphanum_new_position}. It's an illegal move. Try again please!"
    end
  end

  def to_h
    {
      type: self.class.name,
      color: @color,
      player_num: @player_num,
      name: @name
    }
  end

  def self.from_h(player_data)
    new(player_data[:color], player_data[:player_num], player_data[:name])
  end

  private

  def ask_player_name
    print @player_num.positive? ? "\nHey, player #{@player_num}! " : 'Hey you, yes you the human. '
    print "What's your name?\n=> "

    name = gets.chomp
    return name unless name.empty?

    puts "Alright then, you'll be Player #{@player_num}."
    "Player #{@player_num}"
  end

  def ask_for_position(board, type)
    case type
    when :original
      print "\nEnter the position of the piece you want to move\n=> "
      alphanum_position = validate_move_syntax(board, type, consider_color: true)
    when :new
      print "\nEnter the position to which you want to move your piece\n=> "
      alphanum_position = validate_move_syntax(board, type, consider_color: false)
    end

    [alphanum_position, alphanum_to_indices(alphanum_position)]
  end

  def validate_move_syntax(board, type, consider_color: false) # rubocop:disable Metrics/MethodLength
    loop do
      input = gets.chomp
      if !move_syntax_valid?(input)
        print "\nOops, that's invalid. Your input must be a letter followed by a number, like 'e4'.\n" \
              "Try again please!\n=> "
      elsif type == :original && empty?(board, alphanum_to_indices(input))
        print "\nThere's no piece at #{input}. Try again please!\n=> "
      elsif consider_color && !move_color_valid?(board, alphanum_to_indices(input))
        print "\nHmm, you're not allowed to move the piece at #{input}... You can only move #{@color} pieces.\n" \
              "Try again please!\n=> "
      else
        return input
      end
    end
  end

  def empty?(board, position)
    board[position[0]][position[1]].nil?
  end

  def move_syntax_valid?(position)
    position.size == 2 && ('a'..'h').include?(position[0]) && ('1'..'8').include?(position[1])
  end

  def move_color_valid?(board, position)
    moving_piece_color = board[position[0]][position[1]].color
    moving_piece_color == @color
  end

  def alphanum_to_indices(alphanum)
    [alphanum[0].ord - 'a'.ord, 8 - alphanum[1].to_i]
  end
end
