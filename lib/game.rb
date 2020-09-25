# Stores the current state of the game program and orchestrates user input
# and various board states
class Game
  require_relative('board.rb')
  require_relative('piece.rb')
  require_relative('player.rb')
  require 'pry'

  attr_accessor :start, :finish, :piece
  attr_reader :board, :player1, :player2, :current_player, :opposing_player

  def initialize
    @board = Board.new(self)
    @player1 = Player.new('Player 1', 'white', @board.get_piece([7, 4]))
    @player2 = Player.new('Player 2', 'black', @board.get_piece([0, 4]))
    @current_player = @player1
    @opposing_player = @player2
  end

  def begin_game
    display_instructions
    change_player_name(player1)
    change_player_name(player2)
    play_turn
  end

  def display_instructions
    puts "Welcome to chess! Before we begin, I'll need your names."
  end

  def change_player_name(player)
    puts "#{player.name}, enter your name."
    player.name = gets.chomp
  end

  def play_turn
    loop do
      @board.display
      request_move
      @board.castle(@piece, @finish) if @piece.class == King
      @board.move_piece(@start, @finish)
      request_promotion if @piece.class == Pawn && @finish[0].zero?
      mark_moved(@piece)
      check = @board.check?(@opposing_player.king)
      break if @board.checkmate?

      switch_player
      @board.flip
      respond_to_check(check)
    end
  end

  def request_move
    loop do
      # Ask player for letter number coordinates of piece to move
      request_piece
      @piece = @board.get_piece(@start)
      poss_moves = @board.poss_moves(@piece, @start)
      # Ask player for coordinates for selected piece's destination
      break unless request_destination(poss_moves) == false
    end
  end

  def request_piece
    puts "#{@current_player.name}, which piece would you like to move? " \
    'Select the square by its letter, number coordinates. Example: e4.'
    loop do
      let_num = gets.chomp.downcase
      # Turn letter number coordinates in to array indices
      @start = @board.find_coord(let_num)
      break if @board.valid?(@start)

      puts "Your input must be in letter number format, like b6, and make sure\n"\
      "you're selecting your own color. Try again."
    end
  end

  def request_destination(poss_moves)
    puts 'Where would you like to move your piece? Use letter, number coordinates.'
    loop do
      finish = gets.chomp.downcase
      return false if finish == 'n'

      # Turn letter, number input in to array indices
      @finish = @board.find_coord(finish)
      # Ensure input is in the list of valid moves
      if poss_moves.include?(@finish)
        return @finish unless @board.causes_check?(@current_player.king, @start, @finish)

        puts 'Your move puts or keeps your king in check. Please try another.'
        return false

      end
      puts "Your move is not valid. Please try again,\n" \
      'or enter N to select another piece to move.'
    end
  end

  def mark_moved(piece)
    piece.moved = true if [King, Rook].include?(piece)
  end

  def respond_to_check(check)
    puts "#{@board.current_player.name}, your king is in check." if check
  end

  def request_promotion
    pieces = %w[knight bishop queen rook]
    puts 'What would you like to change your pawn to?'
    loop do
      piece = gets.chomp.downcase
      if pieces.include?(piece)
        @board.promote(piece)
        return
      end

      puts 'Selection is not valid. Try again.'
    end
  end

  def switch_player
    @current_player = @current_player == @player1 ? @player2 : @player1
    @opposing_player = @current_player == @player1 ? @player2 : @player1
    puts "#{@current_player.name}, you're up!"
  end
end

game = Game.new
game.begin_game