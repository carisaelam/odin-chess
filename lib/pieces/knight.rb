# frozen_string_literal: true

require_relative '../piece'
require_relative '../board'

# specifics for knight pieces
class Knight < Piece
  def unicode_symbol
    if color == :white
      "\u2658"
    else
      "\u265E"
    end
  end

  def valid_move?(start_position, end_position)
    all_moves = all_valid_moves(start_position)

    all_moves.include?(end_position)
  end

  def all_valid_moves(position)
    row, col = position
    generate_moves(row, col)
  end

  private

  def generate_moves(row, col)
    moves = []
    moves.push([row + 1, col + 2])
    moves.push([row - 1, col + 2])
    moves.push([row + 1, col - 2])
    moves.push([row - 1, col - 2])
    moves.push([row + 2, col + 1])
    moves.push([row - 2, col + 1])
    moves.push([row + 2, col - 1])
    moves.push([row - 2, col - 1])

    in_bounds_moves = moves.select { |move| in_bounds?(move) }
    in_bounds_moves.select { |move| check_colors(move) }
  end
end
