class Game
  require_relative('board.rb')
  require_relative('piece.rb')
  require_relative('player.rb')
  require 'pry'

  attr_accessor :current_player, :coord, :dest, :selected_piece, :poss_moves, :last_move
  attr_reader :board, :player1, :player2, :last_move, :check, :kingw

  def initialize
    @player1 = Player.new('Player 1', 'white')
    @player2 = Player.new('Player 2', 'black')
    @current_player = @player1
    @board = Board.new(add_pieces_to_board)
    @current_king = @kingw
    @opposing_king = @kingb
    @check = false
    @last_move = [Knight, nil, nil]
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
      Array.new(8) { Pawn.new('black') }, Array.new(8, ' '), Array.new(8, ' '),
      Array.new(8, ' '), Array.new(8, ' '), Array.new(8) { Pawn.new('white') },
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
      castle
      @board.move_piece(@coord, @dest)
      request_pawn_change
      mark_moved(@selected_piece)
      @check = check?(@opposing_king)
      break if checkmate?

      switch_player
      @board.flip
    end
  end

  def request_move
    loop do
      # Ask player for letter number coordinates of piece to move
      request_piece
      # Find possible moves for selected object, given current board and object's location
      @poss_moves = @selected_piece.poss_moves(@coord[0], @coord[1], @board.grid)
      add_castle_moves
      add_en_passant_move
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
        return @dest unless causes_check?(@current_king, @coord, @dest)

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

  def causes_check?(target_king, start, finish)
    # Store destination piece as move is temporary
    temp_piece = @board.grid[finish[0]][finish[1]]
    # Temporarily move piece as player intends
    @board.grid[finish[0]][finish[1]] = @board.grid[start[0]][start[1]]
    @board.grid[start[0]][start[1]] = ' '
    cause = check?(target_king)
    # Return board to original state
    @board.grid[start[0]][start[1]] = @board.grid[finish[0]][finish[1]]
    @board.grid[finish[0]][finish[1]] = temp_piece
    return true if cause
  end

  def check?(target_king)
    check = false
    target_king_loc = find_piece(target_king)
    @board.grid.each_with_index do |row, row_idx|
      row.each_with_index do |ele, col_idx|
        unless ele == ' ' || ele.color == target_king.color
          poss_moves = ele.poss_moves(row_idx, col_idx, @board.grid)
          check = true if poss_moves.include?(target_king_loc)
        end
      end
    end
    check
  end

  def checkmate?
    @board.flip
    @board.grid.each_with_index do |row, row_idx|
      row.each_with_index do |ele, col_idx|
        unless ele == ' ' || ele.color == @current_king.color
          poss_moves = ele.poss_moves(row_idx, col_idx, @board.grid)
          poss_moves.each do |move|
            unless causes_check?(@opposing_king, [row_idx, col_idx], move)
              @board.flip
              return false
            end
          end
        end
      end
    end
    puts "Checkmate! #{@current_player.name} wins."
    true
  end

  def find_piece(piece)
    @board.grid.each_with_index do |row, row_idx|
      row.each_with_index do |ele, col_idx|
        return [row_idx, col_idx] if ele == piece
      end
    end
  end

  def respond_to_check
    puts "#{@current_player.name}, your king is in check." if @check
  end

  def add_castle_moves
    return unless @selected_piece.class == King && !@selected_piece.moved && !@check

    king_loc = find_piece(@selected_piece)
    # Check if possible to castle right
    @poss_moves << [king_loc[0], king_loc[1] + 2] if can_castle?((king_loc[1] + 1..6).to_a, @board.grid[7][7])
    # Check if possible to castle left
    @poss_moves << [king_loc[0], king_loc[1] - 2] if can_castle?((1...king_loc[1]).to_a, @board.grid[7][0])
  end

  def can_castle?(array, rook)
    # Ensure rightmost piece is rook, rook has not moved, and spaces between are empty
    array.each do |col|
      return false if @board.grid[7][col] != ' ' \
      || causes_check?(@current_king, @coord, [7, col]) \
      || rook.class != Rook || rook.moved == true
    end
  end

  def castle
    if @selected_piece == kingw
      @board.move_piece([7, 7], [7, 5]) if @dest == [7, 6]
      @board.move_piece([7, 0], [7, 3]) if @dest == [7, 2]
    else
      @board.move_piece([7, 7], [7, 4]) if @dest == [7, 5]
      @board.move_piece([7, 0], [7, 2]) if @dest == [7, 1]
    end
  end

  def add_en_passant_move
    last_piece = @last_move[0]
    last_piece_loc = find_piece(last_piece)
    # Ensure last move was pawn that moved two from starting position
    if @selected_piece.class == Pawn && last_piece.class == Pawn \
      && @last_move[1][0] == 6 && @last_move[2][0] == 4 \
      && @coord[0] == last_piece_loc[0] \
      && (@coord[1] - last_piece_loc[1]).abs == 1
      @poss_moves << [@coord[0] - 1, last_piece_loc[1]]
    end
  end

  def request_pawn_change
    return unless @selected_piece.class == Pawn && @dest[0].zero?

    pieces = %w[knight bishop queen rook]
    puts 'What would you like to change your pawn to?'
    loop do
      piece = gets.chomp.downcase
      if pieces.include?(piece)
        change_pawn(piece)
        return
      end

      puts 'Selection is not valid. Try again.'
    end
  end

  def change_pawn(piece)
    color = @selected_piece.color
    new_piece = case piece
                when 'knight'
                  Knight.new(color)
                when 'bishop'
                  Bishop.new(color)
                when 'queen'
                  Queen.new(color)
                when 'rook'
                  Rook.new(color)
                end
    @board.grid[@dest[0]][@dest[1]] = new_piece
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