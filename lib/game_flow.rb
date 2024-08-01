# frozen_string_literal: true

require_relative 'piece_mover'
require_relative 'coordinate_converter'
require_relative 'board'
require_relative 'check_status'
require_relative 'serialize'

class GameFlow
  include Serialize

  attr_reader :board, :piece_mover, :coordinate_converter, :check_status, :count
  attr_accessor :color

  def initialize(board, piece_mover, coordinate_converter, check_status, count = 0)
    @board = board
    @piece_mover = piece_mover
    @coordinate_converter = coordinate_converter
    @check_status = check_status
    @color = :white
  end

  def start
    welcome
    load_or_new
    puts "New Game!\n\nType save at the start of any move to save your game."
    board.print_board
    loop do
      player_turn
      toggle_color
      break if check_status.checkmate?(color)
    end
  end

  private

  def save_game
    puts 'Name your saved game. No spaces.'
    filename = gets.chomp
    to_yaml(filename)
    puts 'Your game has been saved!'
  end

  def player_turn
    turn_information
    turn_check_status
    turn_piece_selection
    board.increment_count
    board.print_board
  end

  def welcome
    puts "Welcome to Chess!\n\n"
    puts "Player 1 is white, and Player 2 is black.\n\n"
  end

  def turn_information
    puts
    puts "It is #{color.capitalize}'s turn"
  end

  def turn_check_status
    return unless check_status.check?(color) == true

    p "#{color.capitalize}: You are in CHECK. You must get out of check"
    p 'GAME OVER' if check_status.checkmate?(color) == true
  end

  def turn_piece_selection
    print "#{color.capitalize}, select a piece: "
    start_point = check_start_input
    print 'Select an end point: '
    end_point = check_alg_input(gets.chomp)

    if pawn?(start_point) && promotion_possible?(color, end_point)
      move_piece(start_point, end_point)
      p 'about to aske_for_promotion'
      ask_for_promotion(end_point, color)
    elsif king_or_rook?(start_point) && castling_possible?(start_point, end_point)
      ask_for_castling(start_point, end_point)
    else
      check_for_check(start_point, end_point)
    end
  end

  def pawn?(position)
    @board.piece_at(position).instance_of?(Pawn)
  end

  def promotion_possible?(color, end_position)
    @board.promotion_possible?(color, end_position)
  end

  def ask_for_promotion(position, color)
    puts "You're getting promoted!!"
    puts "your color is #{color}"
    puts 'Q - Queen, K - Knight, B - Bishop, R - Rook'
    input = gets.chomp.downcase
    piece_selected =
      case input
      when 'q'
        'Queen'
      when 'k'
        'Knight'
      when 'b'
        'Bishop'
      when 'r'
        'Rook'
      else
        'Not a valid selection. Try again.'
        ask_for_promotion(color)
      end
    p "you selected: #{piece_selected}"
    perform_promotion(position, color, piece_selected)
  end

  def perform_promotion(position, color, piece_selected)
    piece =
      case piece_selected
      when 'Queen'
        Queen.new(color, position, board)
      when 'Knight'
        Knight.new(color, position, board)
      when 'Bishop'
        Bishop.new(color, position, board)
      when 'Rook'
        Rook.new(color, position, board)
      end
    @board.place_piece(piece, position)
  end

  def king_or_rook?(position)
    @board.piece_at(position).instance_of?(King) || @board.piece_at(position).instance_of?(Rook)
  end

  def castling_possible?(start_position, end_position)
    @board.castle_short_move_available?(color) || @board.castle_long_move_available?(color)
  end

  def ask_for_castling(start_position, end_position)
    puts 'Do you want to castle? Y/N'
    input = gets.chomp.downcase

    if input == 'y'
      perform_castling
    else
      check_for_check(start_position, end_position)
    end
  end

  def perform_castling
    if @board.castle_short_move_available?(color)
      @piece_mover.perform_short_castle(color)
    elsif @board.castle_long_move_available?(color)
      @piece_mover.perform_long_castle(color)
    else
      puts 'Castling is not available'
    end
  end

  def toggle_color
    @color = @color == :black ? :white : :black
  end

  # actually moves piece
  def check_for_check(start_point, end_point)
    # loop to check for check
    # p 'Running check for check in GameFlow'
    loop do
      # p 'moving piece...'
      move_piece(start_point, end_point) # move the piece

      # p "checkstatus: #{check_status.check?(color)}"

      break unless check_status.check?(color) # stop here unless the move would put your king in check

      # if move puts king in check...
      king_in_check_prompt(start_point, end_point)

      # re-do select move and loop again
      start_point = check_start_input
      print 'Select an end point: '
      end_point = check_alg_input(gets.chomp)
    end
  end

  def king_in_check_prompt(start_point, end_point)
    puts 'That would put your king in check. Try again.'
    check_status.reset_check
    move_piece(end_point, start_point) # revert the move
    check_status.reset_check # reset check to false
    print 'Select a piece: '
  end

  def check_start_input
    input = gets.chomp
    save_game if input.downcase == 'save'
    alg_cleared = check_alg_input(input)

    until check_piece_color(alg_cleared)
      puts 'Not your piece. Pick again'
      input = gets.chomp
      alg_cleared = check_alg_input(input)
    end

    alg_cleared
  end

  def check_piece_color(input)
    piece = board.piece_at(input)
    piece && piece.color == color
  end

  def check_alg_input(input)
    until ('a'..'h').include?(input[0]) && (1..8).include?(input[1].to_i)
      puts "Please enter a valid coordinate (e.g., 'e2'):"
      input = gets.chomp
    end

    coordinate_converter.convert_from_alg_notation(input)
  end

  def move_piece(start_position, end_position)
    unless piece_mover.validate_move(start_position, end_position)
      puts 'Not a valid move for that piece. Pick another move'
      turn_piece_selection
    end

    piece_mover.move_piece(start_position, end_position)
  end
end

# # GameFlow Class Goals

# [x] Manage Turn Sequence
#   [x] Alternate turns between players.
#   [x] Keep track of which player's turn it is.

# [ ] Handle Move Execution
#   [x] Validate the move according to the rules of chess.
#   [x] Update the board with the new piece positions.
#   [ ] Handle special moves (e.g., castling, en passant).

# [x] Validate Moves
#   [x] Check if a move is legal based on piece type and current board state.
#   [x] Ensure that moves do not put the player's king in check.

# [x] Check Game Status
#   [x] Determine if the game has ended (checkmate, stalemate).
#   [x] Handle game-ending conditions and notify players.

# [x] Handle Player Input
#   [x] Interpret player commands and translate them into moves.
#   [x] Provide feedback to players on invalid moves or game status.

# [x] Maintain Game State
#   [x] Keep track of the current game state (e.g., active pieces, board configuration).
#   [x] Manage game history (optional, for undo/redo functionality).

# [x] Interface with Other Classes
#   [x] Coordinate with the `Board` class to update and query the board state.
#   [x] Utilize `Piece` classes to validate and execute piece-specific moves.

# [x] Provide Game Status Information
#   [x] Display current game status (e.g., which player’s turn it is, if a player is in check).
