# frozen_string_literal: true

require_relative 'piece'

# This class represents the chess game board
#
# It handles storing the positions of all game pieces in a 2D array
class Board
  PIECE_CHARACTERS_WHITE = { rook: '♖', bishop: '♗', knight: '♘',
                             queen: '♕', king: '♔', pawn: '♙' }.freeze

  PIECE_CHARACTERS_BLACK = { rook: '♜', bishop: '♝', knight: '♞',
                             queen: '♛', king: '♚', pawn: '♟' }.freeze

  def initialize(board = nil)
    # allow saved board from previous game to be loaded if desired
    @board = board || generate_default_board
  end

  attr_reader :piece_characters_white, :piece_characters_black

  def generate_default_board
    board = Array.new(8) { Array.new(8) }

    place_major_pieces(board, :black, 0)
    place_pawns(board, :black, 1)

    place_major_pieces(board, :white, 7)
    place_pawns(board, :white, 6)

    board
  end

  def [](column_idx)
    @board[column_idx]
  end

  # returns true if piece was successfully moved, or false otherwise
  def move_piece(piece, new_position)
    old_position = piece.position

    return false unless valid_move?(piece, old_position, new_position)

    @board[old_position[0]][old_position[1]] = nil
    @board[new_position[0]][new_position[1]] = piece
    piece.update_position(new_position)

    true
  end

  def valid_move?(piece, old_position, new_position)
    return valid_pawn_move?(piece, old_position, new_position) if piece.type == :pawn
    return valid_king_move?(piece, new_position) if piece.type == :king

    piece.next_moves.include?(new_position) &&
      path_clear?(piece, old_position, new_position) &&
      (!occupied?(new_position) || can_capture?(piece, new_position))
  end

  def valid_pawn_move?(piece, old_position, new_position)
    (piece.next_moves.include?(new_position) && path_clear?(piece, old_position, new_position)) ||
      (pawn_diagonal_capture?(piece, old_position, new_position) && can_capture?(piece, new_position))
  end

  def valid_king_move?(piece, new_position)
    piece.next_moves.include?(new_position) && (!occupied?(new_position) || can_capture?(piece, new_position))
  end

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

  private

  def place_major_pieces(board, color, row_idx)
    first_row_pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    first_row_pieces.each_with_index do |piece_class, column_idx|
      board[column_idx][row_idx] = piece_class.new([column_idx, row_idx], color)
    end
  end

  def place_pawns(board, color, row_idx)
    (0..7).each do |column_idx|
      board[column_idx][row_idx] = Pawn.new([column_idx, row_idx], color)
    end
  end

  def character(piece, color)
    piece_characters = color == :black ? PIECE_CHARACTERS_BLACK : PIECE_CHARACTERS_WHITE

    piece_characters[piece]
  end

  def pawn_diagonal_capture?(piece, old_position, new_position)
    diagonal_moves = piece.color == :black ? [[1, 1], [-1, 1]] : [[1, -1], [-1, -1]]

    diagonal_moves.any? do |diagonal_move|
      new_position == [old_position[0] + diagonal_move[0], old_position[1] + diagonal_move[1]]
    end
  end

  def path_clear?(piece, old_position, new_position)
    return true if piece.type == :knight

    path = path(piece, old_position, new_position)
    path.all? { |column_idx, row_idx| @board[column_idx][row_idx].nil? }
  end

  def occupied?(position)
    !@board[position[0]][position[1]].nil?
  end

  def can_capture?(piece, new_position)
    other_piece = @board[new_position[0]][new_position[1]]
    piece.color != other_piece.color
  end

  def path(piece, old_position, new_position)
    paths = {
      queen: %i[horizontal_path vertical_path diagonal_path],
      rook: %i[horizontal_path vertical_path],
      bishop: %i[diagonal_path],
      pawn: %i[vertical_path]
    }

    paths[piece.type].flat_map { |method| send(method, old_position, new_position) }
  end

  def horizontal_path(old_position, new_position)
    row_idx = old_position[1] # constant since moving horizontally
    column_idx_range = exclusive_range(old_position[0], new_position[0])

    column_idx_range.map { |column_idx| [column_idx, row_idx] }
  end

  def vertical_path(old_position, new_position)
    column_idx = old_position[0] # constant since moving vertically
    row_idx_range = exclusive_range(old_position[1], new_position[1])

    row_idx_range.map { |row_idx| [column_idx, row_idx] }
  end

  def diagonal_path(old_position, new_position)
    path = []
    column_idx_range = exclusive_range(old_position[0], new_position[0])
    row_idx_range = exclusive_range(old_position[1], new_position[1])

    column_idx_range.each_with_index do |column_idx, i|
      path << [column_idx, row_idx_range[i]]
    end

    path
  end

  def exclusive_range(start, finish)
    if start < finish
      start.upto(finish)[1..-2]
    else
      start.downto(finish)[1..-2]
    end
  end
end
