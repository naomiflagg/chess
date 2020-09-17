class Game
  require_relative('board.rb')
  require_relative('piece.rb')
  require_relative('player.rb')
  require 'pry'
  
  attr_accessor :board, :player1, :player2, :current_player, :coord

  def initialize
    @player1 = Player.new('Player 1', 'white')
    @player2 = Player.new('Player 2', 'black')
    @current_player = @player1
    @board = Board.new(add_pieces_to_board)
  end

  def begin_game
    display_instructions
    change_player_name(player1)
    change_player_name(player2)
    add_pieces_to_board
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
    @pieces = [
      rookb = Rook.new('black'), rookw = Rook.new('white'), knightb = Knight.new('black'),
      knightw = Knight.new('white'), bishopb = Bishop.new('black'),
      bishopw = Bishop.new('white'), queenb = Queen.new('black'),
      queenw = Queen.new('white'), kingb = King.new('black'), kingw = King.new('white'), 
      pawnb = Pawn.new('black'), pawnw = Pawn.new('white')
    ]
    grid = [
      [
        rookb, knightb, bishopb, queenb,
        kingb, bishopb, knightb, rookb
      ],
      Array.new(8, pawnb), Array.new(8, ' '), Array.new(8, ' '),
      Array.new(8, ' '), Array.new(8, ' '), Array.new(8, pawnw),
      [
        rookw, knightw, bishopw, queenw,
        kingw, bishopw, knightw, rookw
      ]
    ]
  end

  def play_turn
    loop do
      @board.display
      request_move
      move_piece(@coord, @dest)
      break if checkmate?

      check?
      switch_player
      @board.flip
    end
  end

  def request_move
    # Ask player for letter number coordinates of piece to move
    request_piece
    # Find possible moves for selected object, given current board and object's location
    poss_moves = selected_piece.poss_moves(@coord[0], @coord[1], @board.grid)
    # Ask player for coordinates for selected piece's destination
    request_destination(poss_moves)
  end

  def request_piece
    puts "#{current_player.name}, which piece would you like to move? " \
    'Select the square by its letter, number coordinates. Example: e4.'
    loop do
      let_num = gets.chomp.downcase
      break if valid?(let_num)

      puts "Your input must be in letter number format, like b6, and make sure\n"\
      "you're selecting your own color."
    end
  end

  def valid?(let_num)
    return false unless let_num.length == 2 && ('a'..'h').include?(let_num[0]) \
        && ('1'..'8').include?(let_num[1])

    # Ensure selected piece is the current player's piece
    # Turn letter number coordinates in to array indices
    @coord = @board.find_coord(let_num)
    # Find piece at selected indices
    selected_piece = @board.grid[@coord[0]][@coord[1]]
    # Ensure piece belongs to current player
    return true if selected_piece.color == @current_player.color
  end

  def request_destination(poss_moves)
    puts 'Where would you like to move your piece? Use letter, number coordinates.'
    loop do
      @dest = gets.chomp.downcase
      # Turn letter, number input in to array indices
      @dest = @board.find_coord(@dest)
      # Ensure input is in the list of valid moves
      return @dest if poss_moves.include?(@dest)

      puts 'Your move is not valid. Please try again.'
    end
  end

  def checkmate?
  end

  def check?
  end

  def switch_player
    @current_player = @current_player == @player1 ? @player2 : @player1
    puts "Thanks. #{@current_player.name}, you're up!"
  end
end

#game = Game.new
#binding.pry
#game.board.display
#game.request_move