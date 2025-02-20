# frozen_string_literal: true

require_relative '../lib/game'

describe Game do
  describe '#in_check?' do
    let(:king_color) { :black }
    context 'when king is not in check' do
      it 'returns false' do
        game_no_check = Game.new(nil, nil)

        expect(game_no_check.in_check?(king_color)).to eq(false)
      end
    end

    subject(:game_check) { Game.new(nil, nil) }
    let(:board_check) { game_check.instance_variable_get(:@board) }

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
        expect(game_check.in_check?(king_color)).to eq(true)
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
        expect(game_check.in_check?(king_color)).to eq(true)
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
          expect(game_check.in_check?(king_color)).to(eq(true))
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
          expect(game_check.in_check?(king_color)).to(eq(false))
        end
      end
    end
  end
end
