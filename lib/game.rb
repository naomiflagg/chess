class Game
  require_relative('board.rb')
  require_relative('piece.rb')
  require_relative('player.rb')
  require 'pry'

  attr_accessor :current_player, :coord, :dest
  attr_reader :board, :player1, :player2, :last_move, :check, :kingw

  def initialize
    @player1 = Player.new('Player 1', 'white')
    @player2 = Player.new('Player 2', 'black')
    @current_player = @player1
    @board = Board.new(add_pieces_to_board)
    @current_king = @kingw
    @opposing_king = @kingb
    @check = false
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

  def add_pieces_to_board
    [
      [
        Rook.new('black'), Knight.new('black'), Bishop.new('black'), Queen.new('black'),
        @kingb = King.new('black'), Bishop.new('black'), Knight.new('black'), Rook.new('black')
      ],
      Array.new(8, Pawn.new('black')), Array.new(8, ' '), Array.new(8, ' '),
      Array.new(8, ' '), Array.new(8, ' '), Array.new(8, Pawn.new('white')),
      [
        Rook.new('white'), Knight.new('white'), Bishop.new('white'), Queen.new('white'),
        @kingw = King.new('white'), Bishop.new('white'), Knight.new('white'), Rook.new('white')
      ]
    ]
  end

  def play_turn
    loop do
      respond_to_check
      @board.display
      request_move
      @last_move = [@selected_piece, @coord, @dest]
      @board.move_piece(@coord, @dest)
      verify_king_attack(@opposing_king)
      break if game_over?

      switch_player
      @board.flip
    end
  end

  def request_move
    loop do
      # Ask player for letter number coordinates of piece to move
      request_piece
      # Find possible moves for selected object, given current board and object's location
      poss_moves = @selected_piece.poss_moves(@coord[0], @coord[1], @board.grid)
      # Ask player for coordinates for selected piece's destination
      break unless request_destination(poss_moves) == false
    end
  end

  def request_piece
    puts "#{current_player.name}, which piece would you like to move? " \
    'Select the square by its letter, number coordinates. Example: e4.'
    loop do
      let_num = gets.chomp.downcase
      break if valid?(let_num)

      puts "Your input must be in letter number format, like b6, and make sure\n"\
      "you're selecting your own color. Try again."
    end
  end

  def valid?(let_num)
    return false unless let_num.length == 2 && ('a'..'h').include?(let_num[0]) \
        && ('1'..'8').include?(let_num[1])

    # Ensure selected piece is the current player's piece
    # Turn letter number coordinates in to array indices
    @coord = @board.find_coord(let_num)
    # Find piece at selected indices
    @selected_piece = @board.grid[@coord[0]][@coord[1]]
    return false if @selected_piece == ' '

    # Ensure piece belongs to current player
    return true if @selected_piece.color == @current_player.color
  end

  def request_destination(poss_moves)
    puts 'Where would you like to move your piece? Use letter, number coordinates.'
    loop do
      @dest = gets.chomp.downcase
      return false if @dest == 'n'

      # Turn letter, number input in to array indices
      @dest = @board.find_coord(@dest)
      # Ensure input is in the list of valid moves
      if poss_moves.include?(@dest)
        return @dest unless causes_check?

        puts 'Your move puts or keeps your king in check. Please try another.'
        return false
      end
      puts "Your move is not valid. Please try again,\n" \
      'or enter N to select another piece to move.'
    end
  end

  def causes_check?
    # Store destination piece as move is temporary
    temp_piece = @board.grid[@dest[0]][@dest[1]]
    # Temporarily move piece as player intends
    @board.grid[@dest[0]][@dest[1]] = @board.grid[@coord[0]][@coord[1]]
    @board.grid[@coord[0]][@coord[1]] = ' '
    verify_king_attack(@current_king)
    # Return board to original state
    @board.grid[@coord[0]][@coord[1]] = @board.grid[@dest[0]][@dest[1]]
    @board.grid[@dest[0]][@dest[1]] = temp_piece
    return true if @check
  end

  def verify_king_attack(target_king)
    @check = false
    @checkmate = true
    target_king_loc = find_king(target_king)
    @board.grid.each_with_index do |row, row_idx|
      row.each_with_index do |ele, col_idx|
        unless ele == ' ' || ele.color == target_king.color
          poss_moves = ele.poss_moves(row_idx, col_idx, @board.grid)
          poss_moves.include?(target_king_loc) ? @check = true : @checkmate = false
        end
      end
    end
  end

  def find_king(target_king)
    @board.grid.each_with_index do |row, row_idx|
      row.each_with_index do |ele, col_idx|
        return [row_idx, col_idx] if ele == target_king
      end
    end
  end

  def game_over?
    puts "Checkmate! #{@current_player.name} wins." if @checkmate
  end

  def respond_to_check
    puts "#{@current_player.name}, your king is in check." if @check
  end

  def switch_player
    @current_player = @current_player == @player1 ? @player2 : @player1
    @current_king = @current_king == @kingb ? @kingw : @kingb
    @opposing_king = @opposing_king == @kingb ? @kingw : @kingb
    puts "#{@current_player.name}, you're up!"
  end
end

game = Game.new
game.begin_game