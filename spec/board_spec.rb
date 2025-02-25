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

  describe '#move_piece' do
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

    context 'when moving to a valid position' do
      context 'when path is clear' do
        context 'when position is unoccupied' do
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

        context 'when position is occupied by opponent' do
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

        context 'when position is occupied by ally' do
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
      end

      context 'when path is blocked' do
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

    context 'when moving a pawn' do
      context 'when path is clear' do
        it 'moves pawn one unit and returns true' do
          old_position = [1, 6]
          new_position = [1, 5]

          pawn_free = board_rearranged[old_position[0]][old_position[1]]

          result = { move_valid: true, capture: false, en_passant: false, castling: false, promote_pawn: false }
          expect(board_rearranged.move_piece(pawn_free, new_position)).to eq(result)
          expect(board_rearranged[new_position[0]][new_position[1]]).to eq(pawn_free)
          expect(board_rearranged[old_position[0]][old_position[1]]).to be_nil
        end

        context 'when on first move' do
          it 'moves pawn two units and returns true' do
            old_position = [1, 6]
            new_position = [1, 5]

            pawn_double = board_rearranged[old_position[0]][old_position[1]]

            result = { move_valid: true, capture: false, en_passant: false, castling: false, promote_pawn: false }
            expect(board_rearranged.move_piece(pawn_double, new_position)).to eq(result)
            expect(board_rearranged[new_position[0]][new_position[1]]).to eq(pawn_double)
            expect(board_rearranged[old_position[0]][old_position[1]]).to be_nil
          end
        end

        context 'when not on first move' do
          it 'fails to move pawn two units and returns false' do
            old_position = [6, 2]
            new_position = [6, 4]

            pawn_double_fail = board_rearranged[old_position[0]][old_position[1]]

            result = { move_valid: false, capture: false, en_passant: false, castling: false, promote_pawn: false }
            expect(board_rearranged.move_piece(pawn_double_fail, new_position)).to eq(result)
            expect(board_rearranged[new_position[0]][new_position[1]]).to be_nil
            expect(board_rearranged[old_position[0]][old_position[1]]).to eq(pawn_double_fail)
          end
        end
      end

      context 'when path is blocked' do
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

      context 'when moving diagonally' do
        context 'when position is occupied by opponent' do
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

        context 'when position is occupied by ally' do
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

        context 'when position is unoccupied' do
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
    end
  end

  describe '#in_check?' do
    let(:king_color) { :black }
    context 'when king is not in check' do
      it 'returns false' do
        board_no_check = Board.new

        expect(board_no_check.in_check?(king_color)).to eq(false)
      end
    end

    let(:board_check) { Board.new }

    before do # rearrange to make black king in check
      # remove black_pawn
      board_check[4][1] = nil
      board_check.instance_variable_get(:@pieces_black).delete(board_check[4][1])

      # move white queen
      board_check[4][5] = board_check[3][7]
      board_check[3][7] = nil
      board_check[4][5].update_position([4, 5])
    end

    context 'when king is in check by one piece' do
      it 'returns true' do
        expect(board_check.in_check?(king_color)).to eq(true)
      end
    end

    context 'when king is in check by multiple pieces' do
      before do # rearrange to make black king in check
        # remove another black pawn
        board_check[4][1] = nil
        board_check.instance_variable_get(:@pieces_black).delete(board_check[3][1])

        # move white bishop
        board_check[2][2] = board_check[2][7]
        board_check[2][7] = nil
        board_check[2][2].update_position([2, 2])
      end

      it 'returns true' do
        expect(board_check.in_check?(king_color)).to eq(true)
      end
    end

    context 'when king was previously in check and now attempts to escape' do
      context 'when new position is in check' do
        before do
          # move black king down
          board_check[4][1] = board_check[4][0]
          board_check[4][0] = nil
        end

        it 'returns true' do
          expect(board_check.in_check?(king_color)).to(eq(true))
        end
      end

      context 'when new position is not in check' do
        before do
          # move black king down
          board_check[3][2] = board_check[4][0]
          board_check[4][0] = nil
          board_check[3][2].update_position([3, 2])
        end

        it 'returns false' do
          expect(board_check.in_check?(king_color)).to(eq(false))
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
