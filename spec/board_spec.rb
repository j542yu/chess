# frozen_string_literal: true

require_relative '../lib/board'

describe Board do
  describe '#generate_default_board' do
    let(:board) { Board.new.instance_variable_get(:@board) } # used in #initialize method

    it 'places major pieces in correct positions' do
      # random selection
      expect(board[0][0]).to be_a(Rook).and have_attributes(position: [0, 0], color: :black)
      expect(board[4][0]).to be_a(King).and have_attributes(position: [4, 0], color: :black)
      expect(board[7][7]).to be_a(Rook).and have_attributes(position: [7, 7], color: :white)
    end

    it 'places pawns in correct positions' do
      (0..7).each do |column_idx|
        expect(board[column_idx][1]).to be_a(Pawn).and have_attributes(position: [column_idx, 1], color: :black)
        expect(board[column_idx][6]).to be_a(Pawn).and have_attributes(position: [column_idx, 6], color: :white)
      end
    end

    it 'leaves empty squares as nil' do
      (2..5).each do |row_idx|
        (0..7).each do |column_idx|
          expect(board[column_idx][row_idx]).to be_nil
        end
      end
    end
  end

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
        board_arr = board_moved.instance_variable_get(:@board)

        random_column_idx = 6
        random_old_row_idx = 1
        random_new_row_idx = 3

        board_arr[random_column_idx][random_new_row_idx] = board_arr[random_column_idx][random_old_row_idx]

        board_arr[random_column_idx][random_old_row_idx] = nil
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
