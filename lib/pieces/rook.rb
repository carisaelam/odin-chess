require_relative '../piece'
require_relative '../board'

class Rook < Piece
  def unicode_symbol
    if color == :white
      "\u2656"
    else
      "\u265C"
    end
  end

  def to_s
    "#{color.capitalize} #{self.class} #{position} - INSTANCE"
  end

  def valid_move?(start_position, end_position)
    p 'VALID MOVE RUNNING inside ROOK'
    row = start_position[0]
    col = start_position[1]

    left_moves = [
      [row, col + 1],
      [row, col + 2],
      [row, col + 3],
      [row, col + 4],
      [row, col + 5],
      [row, col + 6],
      [row, col + 7]
    ]

    right_moves = [
      [row, col - 1],
      [row, col - 2],
      [row, col - 3],
      [row, col - 4],
      [row, col - 5],
      [row, col - 6],
      [row, col - 7]
    ]

    down_moves = [
      [row + 1, col],
      [row + 2, col],
      [row + 3, col],
      [row + 4, col],
      [row + 5, col],
      [row + 6, col],
      [row + 7, col]
    ]
    up_moves = [
      [row - 1, col],
      [row - 2, col],
      [row - 3, col],
      [row - 4, col],
      [row - 5, col],
      [row - 6, col],
      [row - 7, col]
    ]

    def in_bounds?(position)
      p "running in_bounds for position: #{position}"
      p position[0].between?(0, 7) && position[1].between?(0, 7)
    end

    def occupied_by_my_piece?(position)
    end

    moves = []
    down_moves.each do |move|
      p 'DOWN move'
      p "move is #{move}"
      break unless in_bounds?(move)

      piece = @board.piece_at(move)
      break if color == piece.color

      moves << move
    end

    up_moves.each do |move|
      p 'UP move'
      p "move is #{move}"
      break unless in_bounds?(move)

      piece = @board.piece_at(move)
      break if color == piece.color

      moves << move
    end

    left_moves.each do |move|
      p 'LEFT move'
      p move

      break unless in_bounds?(move)

      piece = @board.piece_at(move)
      break if color == piece.color

      moves << move
    end

    right_moves.each do |move|
      p 'RIGHT move'
      p move

      break unless in_bounds?(move)

      piece = @board.piece_at(move)
      break if color == piece.color

      moves << move
    end

    p "valid moves include: #{moves}"

    filtered_moves = filter_possible_moves(moves)
    filtered_moves.include?(end_position)
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
end
