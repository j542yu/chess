# frozen_string_literal: true

require_relative '../lib/board'

describe Board do
  describe '#initialize' do
    subject(:board_start) { Board.new } # used in #initialize method

    it 'places major pieces in correct positions' do
      # random selection
      expect(board_start[0][0]).to be_a(Rook).and have_attributes(position: [0, 0], color: :black)
      expect(board_start[4][0]).to be_a(King).and have_attributes(position: [4, 0], color: :black)
      expect(board_start[7][7]).to be_a(Rook).and have_attributes(position: [7, 7], color: :white)
    end

    it 'places pawns in correct positions' do
      (0..7).each do |column_idx|
        expect(board_start[column_idx][1]).to be_a(Pawn).and have_attributes(position: [column_idx, 1], color: :black)
        expect(board_start[column_idx][6]).to be_a(Pawn).and have_attributes(position: [column_idx, 6], color: :white)
      end
    end

    it 'leaves empty squares as nil' do
      (2..5).each do |row_idx|
        (0..7).each do |column_idx|
          expect(board_start[column_idx][row_idx]).to be_nil
        end
      end
    end
  end

  let(:threatening_color) { :white }
  let(:threatening_pieces) { subject.instance_variable_get(:@pieces_white) }
  let(:ally_color) { :black }
  let(:ally_pieces) { subject.instance_variable_get(:@pieces_black) }
  let(:kings) { subject.instance_variable_get(:@kings) }

  subject(:board_rearranged) { Board.new }

  before do # randomly move some pieces
    old_new_positions = [[[3, 1], [3, 2]], [[4, 1], [4, 3]], [[6, 1], [6, 2]], # move black pawns
                         [[2, 6], [2, 5]], [[4, 6], [4, 4]], # move white pawns
                         [[5, 7], [2, 4]], # move white bishop
                         [[6, 7], [5, 5]]] # move white knight

    old_new_positions.each do |old_position, new_position|
      board_rearranged[new_position[0]][new_position[1]] = board_rearranged[old_position[0]][old_position[1]]
      board_rearranged[old_position[0]][old_position[1]] = nil
      board_rearranged[new_position[0]][new_position[1]].update_position(new_position)
    end
  end

  describe '#move_piece' do
    describe MoveValidation do
      context 'when moving to an unoccupied valid position through clear path' do
        it 'moves piece and returns true' do
          old_position = [7, 7]
          new_position = [5, 7]

          rook_free = board_rearranged[old_position[0]][old_position[1]]

          result = { move_valid: true, capture: false, en_passant: false, castling: false, promote_pawn: false }
          expect(board_rearranged.move_piece(rook_free, new_position)).to eq(result)
          expect(board_rearranged[new_position[0]][new_position[1]]).to eq(rook_free)
          expect(board_rearranged[old_position[0]][old_position[1]]).to be_nil
        end
      end

      context 'when moving to an opponent-occupied valid position through clear path' do
        let(:old_position) { [2, 4] }
        let(:new_position) { [5, 1] }
        let(:bishop_capture_opponent) { board_rearranged[old_position[0]][old_position[1]] }

        it 'captures opponent piece and returns true' do
          result = { move_valid: true, capture: true, en_passant: false, castling: false, promote_pawn: false }
          expect(board_rearranged.move_piece(bishop_capture_opponent, new_position)).to eq(result)
          expect(board_rearranged[new_position[0]][new_position[1]]).to eq(bishop_capture_opponent)
          expect(board_rearranged[old_position[0]][old_position[1]]).to be_nil
        end

        it 'removes opponent piece from collective pieces array' do
          capture_piece = board_rearranged[new_position[0]][new_position[1]]

          pieces = board_rearranged.ally_pieces(capture_piece.color)

          expect(pieces).to include(capture_piece)
          board_rearranged.move_piece(bishop_capture_opponent, new_position)
          expect(pieces).not_to include(capture_piece)
        end
      end

      context 'when moving to an ally-occupied valid position through clear path' do
        it 'does not move piece and returns false' do
          old_position = [7, 7]
          new_position = [4, 7]

          rook_capture_ally = board_rearranged[old_position[0]][old_position[1]]
          ally = board_rearranged[new_position[0]][new_position[1]]

          result = { move_valid: false, capture: false, en_passant: false, castling: false, promote_pawn: false }
          expect(board_rearranged.move_piece(rook_capture_ally, new_position)).to eq(result)
          expect(board_rearranged[new_position[0]][new_position[1]]).to eq(ally)
          expect(board_rearranged[old_position[0]][old_position[1]]).to eq(rook_capture_ally)
        end
      end

      context 'when moving to a valid position through blocked path' do
        it 'does not move non-knight piece and returns false' do
          old_position = [0, 0]
          new_position = [0, 4]

          rook_blocked = board_rearranged[old_position[0]][old_position[1]]

          result = { move_valid: false, capture: false, en_passant: false, castling: false, promote_pawn: false }
          expect(board_rearranged.move_piece(rook_blocked, new_position)).to eq(result)
          expect(board_rearranged[new_position[0]][new_position[1]]).to be_nil
          expect(board_rearranged[old_position[0]][old_position[1]]).to eq(rook_blocked)
        end

        it 'moves knight piece and returns true' do
          old_position = [1, 7]
          new_position = [0, 5]

          knight = board_rearranged[old_position[0]][old_position[1]]

          result = { move_valid: true, capture: false, en_passant: false, castling: false, promote_pawn: false }
          expect(board_rearranged.move_piece(knight, new_position)).to eq(result)
          expect(board_rearranged[new_position[0]][new_position[1]]).to eq(knight)
          expect(board_rearranged[old_position[0]][old_position[1]]).to be_nil
        end
      end

      context 'when moving to an invalid position' do
        it 'does not move piece and returns false' do
          old_position = [0, 0]
          invalid_position = [3, 1]

          rook_invalid = board_rearranged[old_position[0]][old_position[1]]

          result = { move_valid: false, capture: false, en_passant: false, castling: false, promote_pawn: false }
          expect(board_rearranged.move_piece(rook_invalid, invalid_position)).to eq(result)
          expect(board_rearranged[invalid_position[0]][invalid_position[1]]).to be_nil
          expect(board_rearranged[old_position[0]][old_position[1]]).to eq(rook_invalid)
        end
      end
    end

    describe PawnValidation do
      context 'when moving pawn through clear path' do
        it 'moves pawn one unit and returns true' do
          old_position = [1, 6]
          new_position = [1, 5]

          pawn_free = board_rearranged[old_position[0]][old_position[1]]

          result = { move_valid: true, capture: false, en_passant: false, castling: false, promote_pawn: false }
          expect(board_rearranged.move_piece(pawn_free, new_position)).to eq(result)
          expect(board_rearranged[new_position[0]][new_position[1]]).to eq(pawn_free)
          expect(board_rearranged[old_position[0]][old_position[1]]).to be_nil
        end

        it 'moves pawn two units on first move and returns true' do
          old_position = [1, 6]
          new_position = [1, 5]

          pawn_double = board_rearranged[old_position[0]][old_position[1]]

          result = { move_valid: true, capture: false, en_passant: false, castling: false, promote_pawn: false }
          expect(board_rearranged.move_piece(pawn_double, new_position)).to eq(result)
          expect(board_rearranged[new_position[0]][new_position[1]]).to eq(pawn_double)
          expect(board_rearranged[old_position[0]][old_position[1]]).to be_nil
        end

        it 'fails to move pawn two units after first move and returns false' do
          old_position = [6, 2]
          new_position = [6, 4]

          pawn_double_fail = board_rearranged[old_position[0]][old_position[1]]

          result = { move_valid: false, capture: false, en_passant: false, castling: false, promote_pawn: false }
          expect(board_rearranged.move_piece(pawn_double_fail, new_position)).to eq(result)
          expect(board_rearranged[new_position[0]][new_position[1]]).to be_nil
          expect(board_rearranged[old_position[0]][old_position[1]]).to eq(pawn_double_fail)
        end
      end

      context 'when moving pawn through blocked path' do
        it 'does not move pawn and returns false' do
          old_position = [4, 4]
          new_position = [4, 3]

          pawn_blocked = board_rearranged[old_position[0]][old_position[1]]
          blocking_piece = board_rearranged[new_position[0]][new_position[1]]

          result = { move_valid: false, capture: false, en_passant: false, castling: false, promote_pawn: false }
          expect(board_rearranged.move_piece(pawn_blocked, new_position)).to eq(result)
          expect(board_rearranged[new_position[0]][new_position[1]]).to eq(blocking_piece)
          expect(board_rearranged[old_position[0]][old_position[1]]).to eq(pawn_blocked)
        end
      end

      context 'when moving pawn diagonally and position is occupied by opponent' do
        before do # move a pawn to be able to diagonally capture
          old_position = [3, 6]
          new_position = [3, 4]

          board_rearranged[new_position[0]][new_position[1]] = board_rearranged[old_position[0]][old_position[1]]
          board_rearranged[old_position[0]][old_position[1]] = nil
          board_rearranged[new_position[0]][new_position[1]].update_position(new_position)
        end

        let(:old_position) { [3, 4] }
        let(:new_position) { [4, 3] }
        let(:pawn_capture_opponent) { board_rearranged[old_position[0]][old_position[1]] }
        it 'captures opponent piece and returns true' do
          result = { move_valid: true, capture: true, en_passant: false, castling: false, promote_pawn: false }
          expect(board_rearranged.move_piece(pawn_capture_opponent, new_position)).to eq(result)
          expect(board_rearranged[new_position[0]][new_position[1]]).to eq(pawn_capture_opponent)
          expect(board_rearranged[old_position[0]][old_position[1]]).to be_nil
        end

        it 'removes opponent piece from collective pieces array' do
          capture_piece = board_rearranged[new_position[0]][new_position[1]]

          pieces = board_rearranged.ally_pieces(capture_piece.color)

          expect(pieces).to include(capture_piece)
          board_rearranged.move_piece(pawn_capture_opponent, new_position)
          expect(pieces).not_to include(capture_piece)
        end
      end

      context 'when moving pawn diagonally and position is occupied by ally' do
        before do # move a pawn to be able to diagonally capture
          old_position = [1, 6]
          new_position = [1, 5]

          board_rearranged[new_position[0]][new_position[1]] = board_rearranged[old_position[0]][old_position[1]]
          board_rearranged[old_position[0]][old_position[1]] = nil
          board_rearranged[new_position[0]][new_position[1]].update_position(new_position)
        end

        it 'does not move pawn and returns false' do
          old_position = [1, 5]
          new_position = [2, 4]

          pawn_capture_ally = board_rearranged[old_position[0]][old_position[1]]
          ally = board_rearranged[new_position[0]][new_position[1]]

          result = { move_valid: false, capture: false, en_passant: false, castling: false, promote_pawn: false }
          expect(board_rearranged.move_piece(pawn_capture_ally, new_position)).to eq(result)
          expect(board_rearranged[new_position[0]][new_position[1]]).to eq(ally)
          expect(board_rearranged[old_position[0]][old_position[1]]).to eq(pawn_capture_ally)
        end
      end

      context 'when moving pawn diagonally and position is unoccupied' do
        it 'does not move pawn and returns false' do
          old_position = [5, 1]
          new_position = [4, 2]

          pawn_capture_fail = board_rearranged[old_position[0]][old_position[1]]

          result = { move_valid: false, capture: false, en_passant: false, castling: false, promote_pawn: false }
          expect(board_rearranged.move_piece(pawn_capture_fail, new_position)).to eq(result)
          expect(board_rearranged[new_position[0]][new_position[1]]).to be_nil
          expect(board_rearranged[old_position[0]][old_position[1]]).to eq(pawn_capture_fail)
        end
      end
    end

    describe '#illegal_pinned_move?' do
      subject(:board_pinned) { Board.new([[], [], { black: nil, white: nil }], Array.new(8) { Array.new(8) }) }

      let(:pinned_queen) { Queen.new([4, 6], ally_color) }

      before do
        pinning_rook = Rook.new([4, 2], threatening_color)
        board_pinned[*pinning_rook.position] = pinning_rook
        threatening_pieces.push(pinning_rook)

        board_pinned[*pinned_queen.position] = pinned_queen

        ally_king = King.new([4, 7], ally_color)
        board_pinned[*ally_king.position] = ally_king
        kings[ally_color] = ally_king

        ally_pieces.push(pinned_queen, ally_king)
      end

      context 'when king is not in check and pinned piece moves outside line of attack' do
        it 'does not move pinned piece and returns false' do
          old_position = pinned_queen.position
          new_position = [3, 6]

          result = { move_valid: false, capture: false, en_passant: false, castling: false, promote_pawn: false }
          expect(board_pinned.move_piece(pinned_queen, new_position)).to eq(result)
          expect(board_pinned[new_position[0]][new_position[1]]).to be_nil
          expect(board_pinned[old_position[0]][old_position[1]]).to eq(pinned_queen)
        end
      end

      context 'when king is not in check abd pinned piece moves within line of attack' do
        it 'moves pinned piece and returns true' do
          old_position = pinned_queen.position
          new_position = [4, 5]

          result = { move_valid: true, capture: false, en_passant: false, castling: false, promote_pawn: false }
          expect(board_pinned.move_piece(pinned_queen, new_position)).to eq(result)
          expect(board_pinned[new_position[0]][new_position[1]]).to eq(pinned_queen)
          expect(board_pinned[old_position[0]][old_position[1]]).to be_nil
        end
      end

      context 'when king is in check and pinned piece attempts to capture threatening piece' do
        let(:threatening_bishop) { Bishop.new([5, 6], threatening_color) }

        before do
          board_pinned[*threatening_bishop.position] = threatening_bishop
          threatening_pieces.push(threatening_bishop)
        end

        it 'does not move pinned piece and returns false' do
          old_position = pinned_queen.position
          new_position = threatening_bishop.position

          result = { move_valid: false, capture: false, en_passant: false, castling: false, promote_pawn: false }
          expect(board_pinned.move_piece(pinned_queen, new_position)).to eq(result)
          expect(board_pinned[new_position[0]][new_position[1]]).to eq(threatening_bishop)
          expect(board_pinned[old_position[0]][old_position[1]]).to eq(pinned_queen)
        end
      end
    end
  end

  describe '#checkmate?' do
    context 'when checkmate' do
      subject(:board_checkmate) { Board.new([[], [], { black: nil, white: nil }], Array.new(8) { Array.new(8) }) }

      context 'by two rooks' do
        before do
          rook_one = Rook.new([6, 0], threatening_color)
          board_checkmate[*rook_one.position] = rook_one

          rook_two = Rook.new([7, 1], threatening_color)
          board_checkmate[*rook_two.position] = rook_two

          threatening_pieces.push(rook_one, rook_two)

          ally_king = King.new([2, 0], ally_color)
          board_checkmate[*ally_king.position] = ally_king
          kings[ally_color] = ally_king

          ally_pieces.push(ally_king)
        end

        it 'returns true' do
          expect(board_checkmate.checkmate?(ally_color)).to eq(true)
        end
      end

      context 'by queen and king' do
        before do
          threatening_queen = Queen.new([6, 6], threatening_color)
          board_checkmate[*threatening_queen.position] = threatening_queen

          threatening_king = King.new([5, 6], threatening_color)
          board_checkmate[*threatening_king.position] = threatening_king
          kings[threatening_color] = threatening_king

          threatening_pieces.push(threatening_queen, threatening_king)

          ally_king = King.new([7, 6], ally_color)
          board_checkmate[*ally_king.position] = ally_king
          kings[ally_color] = ally_king

          ally_pieces.push(ally_king)
        end

        it 'returns true' do
          expect(board_checkmate.checkmate?(ally_color)).to eq(true)
        end
      end

      context 'by king and rook' do
        before do
          threatening_rook = Rook.new([1, 0], threatening_color)
          board_checkmate[*threatening_rook.position] = threatening_rook

          threatening_king = King.new([6, 1], threatening_color)
          board_checkmate[*threatening_king.position] = threatening_king
          kings[threatening_color] = threatening_king

          threatening_pieces.push(threatening_rook, threatening_king)

          ally_king = King.new([6, 0], ally_color)
          board_checkmate[*ally_king.position] = ally_king
          kings[ally_color] = ally_king

          ally_pieces.push(ally_king)
        end

        it 'returns true' do
          expect(board_checkmate.checkmate?(ally_color)).to eq(true)
        end
      end
    end

    context 'when not in checkmate' do
      context 'because threatening piece can be captured' do
        subject(:board_no_checkmate) { Board.new([[], [], { black: nil, white: nil }], Array.new(8) { Array.new(8) }) }

        before do
          threatening_bishop = Bishop.new([5, 5], threatening_color)
          board_no_checkmate[*threatening_bishop.position] = threatening_bishop

          threatening_pieces.push(threatening_bishop)

          ally_king = King.new([7, 7], ally_color)
          board_no_checkmate[*ally_king.position] = ally_king
          kings[ally_color] = ally_king

          ally_knight = Knight.new([6, 7], ally_color)
          board_no_checkmate[*ally_knight.position] = ally_knight

          ally_pieces.push(ally_king, ally_knight)
        end

        it 'returns false' do
          expect(board_no_checkmate.checkmate?(ally_color)).to eq(false)
        end
      end

      context 'because threatening piece can be blocked' do
        subject(:board_no_checkmate) { Board.new }

        before do
          board_no_checkmate.move_piece(board_no_checkmate[3, 1], [3, 2])
          board_no_checkmate.move_piece(board_no_checkmate[4, 6], [4, 4])
          board_no_checkmate.move_piece(board_no_checkmate[5, 7], [1, 3])
        end

        it 'returns false' do
          expect(board_no_checkmate.checkmate?(ally_color)).to eq(false)
        end
      end
    end
  end

  describe BoardDisplay do
    describe '#display' do
      context 'when game is at start' do
        it 'shows game pieces in default position' do
          board_start = Board.new

          expected_output = <<~HEREDOC

                  a    b    c    d    e    f    g    h

                —————————————————————————————————————————
            8   | ♜  | ♞  | ♝  | ♛  | ♚  | ♝  | ♞  | ♜  |   8
                —————————————————————————————————————————
            7   | ♟  | ♟  | ♟  | ♟  | ♟  | ♟  | ♟  | ♟  |   7
                —————————————————————————————————————————
            6   | 　 | 　 | 　 | 　 | 　 | 　 | 　 | 　 |   6
                —————————————————————————————————————————
            5   | 　 | 　 | 　 | 　 | 　 | 　 | 　 | 　 |   5
                —————————————————————————————————————————
            4   | 　 | 　 | 　 | 　 | 　 | 　 | 　 | 　 |   4
                —————————————————————————————————————————
            3   | 　 | 　 | 　 | 　 | 　 | 　 | 　 | 　 |   3
                —————————————————————————————————————————
            2   | ♙  | ♙  | ♙  | ♙  | ♙  | ♙  | ♙  | ♙  |   2
                —————————————————————————————————————————
            1   | ♖  | ♘  | ♗  | ♕  | ♔  | ♗  | ♘  | ♖  |   1
                —————————————————————————————————————————

                  a    b    c    d    e    f    g    h

          HEREDOC

          expect { board_start.display }.to output(expected_output).to_stdout
        end
      end

      context 'when game has progressed' do
        subject(:board_moved) { Board.new }

        before do # move a pawn
          random_column_idx = 6
          random_old_row_idx = 1
          random_new_row_idx = 3

          board_moved[random_column_idx][random_new_row_idx] = board_moved[random_column_idx][random_old_row_idx]

          board_moved[random_column_idx][random_old_row_idx] = nil
        end

        it 'shows correctly moved game pieces' do
          expected_output = <<~HEREDOC

                  a    b    c    d    e    f    g    h

                —————————————————————————————————————————
            8   | ♜  | ♞  | ♝  | ♛  | ♚  | ♝  | ♞  | ♜  |   8
                —————————————————————————————————————————
            7   | ♟  | ♟  | ♟  | ♟  | ♟  | ♟  | 　 | ♟  |   7
                —————————————————————————————————————————
            6   | 　 | 　 | 　 | 　 | 　 | 　 | 　 | 　 |   6
                —————————————————————————————————————————
            5   | 　 | 　 | 　 | 　 | 　 | 　 | ♟  | 　 |   5
                —————————————————————————————————————————
            4   | 　 | 　 | 　 | 　 | 　 | 　 | 　 | 　 |   4
                —————————————————————————————————————————
            3   | 　 | 　 | 　 | 　 | 　 | 　 | 　 | 　 |   3
                —————————————————————————————————————————
            2   | ♙  | ♙  | ♙  | ♙  | ♙  | ♙  | ♙  | ♙  |   2
                —————————————————————————————————————————
            1   | ♖  | ♘  | ♗  | ♕  | ♔  | ♗  | ♘  | ♖  |   1
                —————————————————————————————————————————

                  a    b    c    d    e    f    g    h

          HEREDOC

          expect { board_moved.display }.to output(expected_output).to_stdout
        end
      end
    end
  end
end
