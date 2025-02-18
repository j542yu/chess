# frozen_string_literal: true

require_relative '../lib/piece'

describe Piece do
  let(:random_color) { :white }
  let(:position_edge) { [0, 5] }
  let(:position_corner) { [7, 0] }
  let(:position_middle) { [5, 4] }

  describe King do
    describe KingMoveable do
      describe '#generate_king_moves' do
        correct_moves_edge = [[0, 4], [0, 6], [1, 5], [1, 6], [1, 4]]
        correct_moves_corner = [[6, 0], [7, 1], [6, 1]]
        correct_moves_middle = [[6, 4], [4, 4], [5, 5], [5, 3], [6, 5], [4, 3], [6, 3], [4, 5]]

        it 'updates next_moves with one-unit moves' do
          positions_and_expected_moves = [[position_edge, correct_moves_edge],
                                          [position_corner, correct_moves_corner],
                                          [position_middle, correct_moves_middle]]

          positions_and_expected_moves.each do |position, correct_moves|
            king = King.new(position, random_color)

            result = king.generate_king_moves(king.next_moves)
            expect(result).to match_array(correct_moves)
          end
        end
      end
    end
  end

  describe Queen do # covers movement used by rooks and bishops as well
    describe HorizontalVerticalMoveable do
      describe '#generate_horizontal_and_vertical_moves' do
        correct_moves_edge = [[1, 5], [2, 5], [3, 5], [4, 5], [5, 5], [6, 5], [7, 5],
                              [0, 4], [0, 3], [0, 2], [0, 1], [0, 0], [0, 6], [0, 7]]
        correct_moves_corner = [[6, 0], [5, 0], [4, 0], [3, 0], [2, 0], [1, 0], [0, 0],
                                [7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7]]
        correct_moves_middle = [[4, 4], [3, 4], [2, 4], [1, 4], [0, 4], [6, 4], [7, 4],
                                [5, 3], [5, 2], [5, 1], [5, 0], [5, 5], [5, 6], [5, 7]]

        it 'updates next_moves with horizontal and vertical moves' do
          positions_and_expected_moves = [[position_edge, correct_moves_edge],
                                          [position_corner, correct_moves_corner],
                                          [position_middle, correct_moves_middle]]

          positions_and_expected_moves.each do |position, correct_moves|
            queen = Queen.new(position, random_color)

            result = queen.generate_horizontal_and_vertical_moves(queen.next_moves)
            expect(result).to match_array(correct_moves)
          end
        end
      end
    end

    describe DiagonalMoveable do
      describe '#generate_diagonal_moves' do
        correct_moves_edge = [[1, 6], [2, 7], [1, 4], [2, 3], [3, 2], [4, 1], [5, 0]]
        correct_moves_corner = [[6, 1], [5, 2], [4, 3], [3, 4], [2, 5], [1, 6], [0, 7]]
        correct_moves_middle = [[6, 5], [7, 6], [4, 3], [3, 2], [2, 1], [1, 0],
                                [4, 5], [3, 6], [2, 7], [6, 3], [7, 2]]

        it 'updates next_moves with diagonal moves' do
          positions_and_expected_moves = [[position_edge, correct_moves_edge],
                                          [position_corner, correct_moves_corner],
                                          [position_middle, correct_moves_middle]]

          positions_and_expected_moves.each do |position, correct_moves|
            queen = Queen.new(position, random_color)

            result = queen.generate_diagonal_moves(queen.next_moves)
            expect(result).to match_array(correct_moves)
          end
        end
      end
    end
  end

  describe Knight do
    describe KnightMoveable do
      describe '#generate_knight_moves' do
        correct_moves_edge = [[2, 4], [2, 6], [1, 3], [1, 7]]
        correct_moves_corner = [[5, 1], [6, 2]]
        correct_moves_middle = [[7, 3], [7, 5], [3, 3], [3, 5],
                                [6, 2], [6, 6], [4, 2], [4, 6]]

        it "updates next_moves with 'L-shaped' jump moves" do
          positions_and_expected_moves = [[position_edge, correct_moves_edge],
                                          [position_corner, correct_moves_corner],
                                          [position_middle, correct_moves_middle]]

          positions_and_expected_moves.each do |position, correct_moves|
            knight = Knight.new(position, random_color)

            result = knight.generate_knight_moves(knight.next_moves)
            expect(result).to match_array(correct_moves)
          end
        end
      end
    end
  end

  describe Pawn do
    describe PawnMoveable do
      describe '#generate_pawn_moves' do
        black_position_start = [0, 1]
        black_position_end = [5, 7]

        white_position_start = [0, 6]
        white_position_end = [5, 0]

        position_middle = [1, 3]

        black_correct_move_start = [[0, 3]]
        black_correct_move_middle = [[1, 4]]

        white_correct_move_start = [[0, 4]]
        white_correct_move_middle = [[1, 2]]

        correct_move_end = []

        it 'updates next_moves with forward unit move' do
          positions_and_expected_moves = [[:black, black_position_start, black_correct_move_start],
                                          [:black, black_position_end, correct_move_end],
                                          [:black, position_middle, black_correct_move_middle],
                                          [:white, white_position_start, white_correct_move_start],
                                          [:white, white_position_end, correct_move_end],
                                          [:white, position_middle, white_correct_move_middle]]

          positions_and_expected_moves.each do |color, position, correct_moves|
            pawn = Pawn.new(position, color)

            result = pawn.generate_pawn_moves(pawn.color, pawn.next_moves)
            expect(result).to match_array(correct_moves)
          end
        end
      end
    end
  end
end
