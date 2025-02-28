# frozen_string_literal: true

using Rainbow

# This modules handles input and output of Board instances,
# including printing to the command line and saving to a file
module BoardDisplay
  PIECE_CHARACTERS_WHITE = { Rook => '♖', Bishop => '♗', Knight => '♘',
                             Queen => '♕', King => '♔', Pawn => '♙' }.freeze

  PIECE_CHARACTERS_BLACK = { Rook => '♜', Bishop => '♝', Knight => '♞',
                             Queen => '♛', King => '♚', Pawn => '♟' }.freeze

  def display # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    print "\n      a    b    c    d    e    f    g    h\n\n".faint
    print "    —————————————————————————————————————————\n".faint

    (0..7).each do |row_idx|
      print "#{8 - row_idx}   |".faint
      @board.each do |column|
        piece = column[row_idx]
        print piece.nil? ? ' 　 ' : " #{character(piece.class, piece.color)}  "
        print '|'.faint
      end
      print "   #{8 - row_idx}\n    —————————————————————————————————————————\n".faint
    end

    print "\n      a    b    c    d    e    f    g    h\n\n".faint
  end

  def character(piece, color)
    piece_characters = color == :black ? PIECE_CHARACTERS_BLACK : PIECE_CHARACTERS_WHITE

    piece_characters[piece]
  end
end
