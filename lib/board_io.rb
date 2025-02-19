# frozen_string_literal: true

# This modules handles input and output of Board instances,
# including printing to the command line and saving to a file
module BoardIO
  PIECE_CHARACTERS_WHITE = { rook: '♖', bishop: '♗', knight: '♘',
                             queen: '♕', king: '♔', pawn: '♙' }.freeze

  PIECE_CHARACTERS_BLACK = { rook: '♜', bishop: '♝', knight: '♞',
                             queen: '♛', king: '♚', pawn: '♟' }.freeze

  def display # rubocop:disable Metrics/MethodLength
    print "\n      a    b    c    d    e    f    g    h\n\n"
    print "    —————————————————————————————————————————\n"

    (0..7).each do |row_idx|
      print "#{8 - row_idx}   |"
      @board.each do |column|
        piece = column[row_idx]
        print piece.nil? ? ' 　 |' : " #{character(piece.type, piece.color)}  |"
      end
      print "   #{8 - row_idx}\n"
      print "    —————————————————————————————————————————\n"
    end

    print "\n      a    b    c    d    e    f    g    h\n\n"
  end

  def character(piece, color)
    piece_characters = color == :black ? PIECE_CHARACTERS_BLACK : PIECE_CHARACTERS_WHITE

    piece_characters[piece]
  end
end
