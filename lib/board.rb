class Board 
  attr_accessor :grid, :fallen, :last_move

  def initialize(grid)
    @grid = grid
    @fallen = []
    @last_move = [Knight, nil, nil]
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

  # Find grid coordinates associated with letter number format
  def find_coord(let_num)
    col = let_num[0]
    row = let_num[1]
    @row_vals = {
      '8' => 0, '7' => 1, '6' => 2, '5' => 3, \
      '4' => 4, '3' => 5, '2' => 6, '1' => 7
    }
    @col_vals = {
      'a' => 0, 'b' => 1, 'c' => 2, 'd' => 3, \
      'e' => 4, 'f' => 5, 'g' => 6, 'h' => 7
    }
    [@row_vals[row], @col_vals[col]]
  end

  def move_piece(start, finish)
    dest_piece = @grid[finish[0]][finish[1]]
    @fallen << dest_piece unless dest_piece == ' '
    @grid[finish[0]][finish[1]] = @grid[start[0]][start[1]]
    @grid[start[0]][start[1]] = ' '
    @last_move = [@grid[finish[0]][finish[1]], start, finish]
  end

  def flip
    @grid.map!(&:reverse).reverse!
  end
end

#board = Board.new
#board.display