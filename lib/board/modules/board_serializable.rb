# frozen_string_literal: true

# This module handles serializing Board object data,
# and is included in the Board class to support
# the ability to save / open saved games in the Game class
module BoardSerializable
  def self.included(base)
    base.extend(ClassMethods)
  end

  def to_h
    serialized = {
      pieces: {}, kings: { black: nil, white: nil },
      board: Array.new(8) { Array.new(8) }, move_history: []
    }

    # create unique identifiers for each Piece object to
    # ensure other instance variables share these same Piece object references
    # instead of independent new ones
    piece_to_id = {}

    convert_all_pieces_to_ids(serialized, piece_to_id)
    serialize_board(serialized, piece_to_id)
    serialize_kings(serialized, piece_to_id)
    serialize_move_history(serialized, piece_to_id)

    serialized
  end

  module ClassMethods
    def from_h(serialized)
      # use unique ID's created in to_h to ensure instance variables
      # correctly share appropriate Piece object references
      id_to_piece = {}

      convert_all_ids_to_pieces(serialized, id_to_piece)

      board = Board.new([[], [], { black: nil, white: nil }], Array.new(8) { Array.new(8) }, [])

      unserialize_board_and_kings(board, serialized, id_to_piece)
      unserialize_move_history(board, serialized, id_to_piece)

      board
    end

    def convert_all_ids_to_pieces(serialized, id_to_piece)
      serialized[:pieces].each do |piece_id, piece_data|
        klass = Object.const_get(piece_data[:type])
        id_to_piece[piece_id] = klass.from_h(piece_data)
      end
    end

    def unserialize_board_and_kings(board, serialized, id_to_piece) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      serialized[:board].each_with_index do |column, column_idx|
        column.each_with_index do |piece_id, row_idx|
          piece = id_to_piece[piece_id]
          next if piece_id.nil?

          board.instance_variable_get(:@board)[column_idx][row_idx] = piece
          if piece.color == :black
            board.instance_variable_get(:@pieces_black) << piece
          else
            board.instance_variable_get(:@pieces_white) << piece
          end

          board.instance_variable_get(:@kings)[piece.color] = piece if piece.instance_of?(King)
        end
      end
    end

    def unserialize_move_history(board, serialized, id_to_piece)
      serialized[:move_history].each do |piece_id, old_position, new_position|
        board.instance_variable_get(:@move_history) << [id_to_piece[piece_id], old_position, new_position]
      end
    end
  end

  private

  def convert_all_pieces_to_ids(serialized, piece_to_id)
    (@pieces_black + @pieces_white).each_with_index do |piece, idx|
      piece_id = :"#{piece.class.name}_#{idx}"
      piece_to_id[piece] = piece_id
      serialized[:pieces][piece_id] = piece.to_h
    end
  end

  def serialize_board(serialized, piece_to_id)
    @board.each_with_index do |column, column_idx|
      column.each_with_index do |piece, row_idx|
        serialized[:board][column_idx][row_idx] = piece.nil? ? nil : piece_to_id[piece]
      end
    end
  end

  def serialize_kings(serialized, piece_to_id)
    serialized[:kings][:black] = piece_to_id[@kings[:black]]
    serialized[:kings][:white] = piece_to_id[@kings[:white]]
  end

  def serialize_move_history(serialized, piece_to_id)
    @move_history.each do |piece, old_position, new_position|
      serialized[:move_history] << [piece_to_id[piece], old_position, new_position]
    end
  end
end
