# Stores the current state of the game, and can answer questions about board-level moves
class Board
  require_relative('piece.rb')
  require_relative('player.rb')

  attr_accessor :grid, :fallen, :last_move

  def initialize(game)
    @game = game
    @grid = add_pieces
    @fallen = []
    @last_move = [Knight, nil, nil]
  end

  def add_pieces
    [
      [
        Rook.new('black'), Knight.new('black'), Bishop.new('black'), Queen.new('black'),
        King.new('black'), Bishop.new('black'), Knight.new('black'), Rook.new('black')
      ],
      Array.new(8) { Pawn.new('black') }, Array.new(8, ' '), Array.new(8, ' '),
      Array.new(8, ' '), Array.new(8, ' '), Array.new(8) { Pawn.new('white') },
      [
        Rook.new('white'), Knight.new('white'), Bishop.new('white'), Queen.new('white'),
        King.new('white'), Bishop.new('white'), Knight.new('white'), Rook.new('white')
      ]
    ]
  end

  def display
    board_break = '  ---------------------------------'
    alpha = '    a   b   c   d   e   f   g   h'
    puts alpha
    puts board_break
    num = 8
    @grid.each do |row|
      new_row = row.map do |ele|
        ele == ' ' ? ele : ele.symbol
      end
      puts "#{num} | #{new_row.join(' | ')} | #{num}"
      puts board_break
      num -= 1
    end
    puts alpha
    return if @fallen.empty?

    puts 'The fallen:'
    @fallen.each { |piece| print piece.symbol }
    puts "\n"
  end

  def valid?(start)
    # Ensure input was a valid letter-number combination
    return false if start.include?(nil)

    # Find piece at selected indices
    piece = get_piece(start)
    return false if piece == ' '

    # Ensure piece belongs to current player
    return true if piece.color == @game.current_player.color
  end

  # Find grid coordinates associated with letter number format
  def find_coord(let_num)
    col = let_num[0]
    row = let_num[1]
    row_vals = {
      '8' => 0, '7' => 1, '6' => 2, '5' => 3, \
      '4' => 4, '3' => 5, '2' => 6, '1' => 7
    }
    col_vals = {
      'a' => 0, 'b' => 1, 'c' => 2, 'd' => 3, \
      'e' => 4, 'f' => 5, 'g' => 6, 'h' => 7
    }
    [row_vals[row], col_vals[col]]
  end

  def get_piece(coords)
    @grid[coords[0]][coords[1]]
  end

  def set_piece(coords, new_piece)
    @grid[coords[0]][coords[1]] = new_piece
  end

  # Find possible moves for selected object, given current board and object's location
  def poss_moves(piece, start)
    poss_moves = piece.poss_moves(start[0], start[1], grid)

    add_castle_moves(piece, start, poss_moves) unless piece.class != King || piece.moved || check?(piece)
    add_en_passant_move(start, poss_moves) if piece.class == Pawn
    poss_moves
  end

  def add_castle_moves(piece, start, poss_moves)
    king_loc = find_piece(piece)
    # Add righthand check to moves list if possible to castle right
    poss_moves << [king_loc[0], king_loc[1] + 2] if can_castle?((king_loc[1] + 1..6).to_a, @grid[7][7], start)
    # Add lefthand check to moves list if possible to castle left
    poss_moves << [king_loc[0], king_loc[1] - 2] if can_castle?((1...king_loc[1]).to_a, @grid[7][0], start)
  end

  def can_castle?(array, rook, start)
    # Ensure rightmost piece is rook, rook has not moved, and spaces between are empty
    array.each do |col|
      return false if @grid[7][col] != ' ' \
      || rook.class != Rook || rook.moved == true \
      || causes_check?(@game.current_player.king, start, [7, col])
    end
  end

  def add_en_passant_move(start, poss_moves)
    last_piece = last_move[0]
    last_piece_loc = find_piece(last_piece)
    # Ensure last move was pawn that moved two from starting position
    if last_piece.class == Pawn && last_move[1][0] == 6 \
      && last_move[2][0] == 4 && start[0] == last_piece_loc[0] \
      && (start[1] - last_piece_loc[1]).abs == 1
      poss_moves << [start[0] - 1, last_piece_loc[1]]
    end
  end

  def find_piece(piece)
    @grid.each_with_index do |row, row_idx|
      row.each_with_index do |ele, col_idx|
        return [row_idx, col_idx] if ele == piece
      end
    end
  end

  def castle(piece, finish)
    if piece.color == 'white'
      move_piece([7, 7], [7, 5]) if finish == [7, 6]
      move_piece([7, 0], [7, 3]) if finish == [7, 2]
    else
      move_piece([7, 7], [7, 4]) if finish == [7, 5]
      move_piece([7, 0], [7, 2]) if finish == [7, 1]
    end
  end

  def promote(piece, promotion)
    color = piece.color
    new_piece = case promotion
                when 'knight'
                  Knight.new(color)
                when 'bishop'
                  Bishop.new(color)
                when 'queen'
                  Queen.new(color)
                when 'rook'
                  Rook.new(color)
                end
    set_piece(find_piece(piece), new_piece)
  end

  def causes_check?(target_king, start, finish)
    # Store destination piece as move is temporary
    temp_piece = get_piece(finish)
    # Temporarily move piece as player intends
    set_piece(finish, get_piece(start))
    set_piece(start, ' ')
    causes_check = check?(target_king)
    # Return board to original state
    set_piece(start, get_piece(finish))
    set_piece(finish, temp_piece)
    return true if causes_check
  end

  def check?(target_king)
    check = false
    target_king_loc = find_piece(target_king)
    @grid.each_with_index do |row, row_idx|
      row.each_with_index do |ele, col_idx|
        unless ele == ' ' || ele.color == target_king.color
          poss_moves = ele.poss_moves(row_idx, col_idx, @grid)
          check = true if poss_moves.include?(target_king_loc)
        end
      end
    end
    check
  end

  def checkmate?
    flip
    @grid.each_with_index do |row, row_idx|
      row.each_with_index do |ele, col_idx|
        unless ele == ' ' || ele.color == @game.current_player.color
          poss_moves = ele.poss_moves(row_idx, col_idx, @grid)
          poss_moves.each do |move|
            unless causes_check?(@game.opposing_player.king, [row_idx, col_idx], move)
              flip
              return false
            end
          end
        end
      end
    end
    puts "Checkmate! #{@game.current_player.name} wins."
    true
  end

  def move_piece(start, finish)
    dest_piece = get_piece(finish)
    @fallen << dest_piece unless dest_piece == ' '
    set_piece(finish, get_piece(start))
    set_piece(start, ' ')
    @last_move = [get_piece(finish), start, finish]
  end

  def flip
    @grid.map!(&:reverse).reverse!
  end
end

#board = Board.new
#board.display