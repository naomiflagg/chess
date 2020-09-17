class Piece
  attr_accessor :color, :symbol

  def initialize
  end

  def poss_moves(moves)
    # Select for moves that are on the board
    moves.select do |move|
      move[0].between?(0, 7) && move[1].between?(0, 7)
    end
  end
end

class Pawn < Piece
  def initialize(color)
    @color = color
    @symbol = color == 'white' ? "\u{2659}" : "\u{265F}"
  end

  def poss_moves(row, col, board)
    moves = [[row - 1, col]]
    moves << [row - 2, col] if row == 6
    super(moves)
  end
end

class Knight < Piece
  def initialize(color)
    @color = color
    @symbol = color == 'white' ? "\u{2658}" : "\u{265E}"
  end

  def poss_moves(row, col, _board)
    moves = [
      [row - 2, col - 1], [row - 2, col + 1], [row - 1, col - 2], [row - 1, col + 2],
      [row + 1, col - 2], [row + 1, col + 2], [row + 2, col - 1], [row + 2, col + 1]
    ]
    super(moves)
  end
end

class Bishop < Piece
  def initialize(color)
    @color = color
    @symbol = color == 'white' ? "\u{2657}" : "\u{265D}"
  end
  
  def poss_moves(row, col, board)
  end
end

class Rook < Piece
  def initialize(color)
    @color = color
    @symbol = color == 'white' ? "\u{2656}" : "\u{265C}"
  end
  
  def poss_moves(row, col, board)
  end
end

class Queen < Piece
  def initialize(color)
    @color = color
    @symbol = color == 'white' ? "\u{2655}" : "\u{265B}"
  end
  
  def poss_moves(row, col, board)
  end
end

class King < Piece
  def initialize(color)
    @color = color
    @symbol = color == 'white' ? "\u{2654}" : "\u{265A}"
  end
  
  def poss_moves(row, col, board)
  end
end