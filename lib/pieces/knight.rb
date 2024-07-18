require_relative '../piece'

class Knight < Piece
  def initialize(color, position)
    super(color, position)
  end

  def unicode_symbol
    if color == :white
      "\u2658"
    else
      "\u265E"
    end
  end

  def valid_move?(start_position, end_position)
    knight_moves(start_position, end_position)
  end

  # filter out out of bounds moves
  def filter_possible_moves(moves)
    legal_moves = []

    moves.each do |move|
      next unless move[0].between?(0, 7) && move[1].between?(0, 7)

      legal_moves.push(move)
    end

    legal_moves
  end

  def knight_moves(start_position, end_position)
    row = start_position[0]
    col = start_position[1]
    moves = []
    moves.push([row + 1, col + 2])
    moves.push([row - 1, col + 2])
    moves.push([row + 1, col - 2])
    moves.push([row - 1, col - 2])
    moves.push([row + 2, col + 1])
    moves.push([row - 2, col + 1])
    moves.push([row + 2, col - 1])
    moves.push([row - 2, col - 1])

    filtered_moves = filter_possible_moves(moves)
    filtered_moves.include?(end_position)
  end
end
