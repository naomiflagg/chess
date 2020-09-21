class Piece
  require 'pry'
  attr_accessor :color, :symbol

  def initialize
  end

  def valid?(move, board)
    return false unless move[0].between?(0, 7) && move[1].between?(0, 7)

    current_occupant = board[move[0]][move[1]]
    # Determine color of occupant in target square, to ensure not one of current player's
    curr_occ_color = current_occupant == ' ' ? 'green' : current_occupant.color
    return false if curr_occ_color == @color

    true
  end
end

class Pawn < Piece
  def initialize(color)
    @color = color
    @symbol = color == 'white' ? "\u{2659}" : "\u{265F}"
  end

  def poss_moves(row, col, board)
    moves = []
    move = [row - 1, col]
    moves << move if board[move[0]][move[1]] == ' '
    # Allow pawn to move two forward if in starting position
    move = [row - 2, col]
    moves << move if row == 6 && !moves.empty? && board[move[0]][move[1]] == ' '
    # Pawn can move diagonally forward if other player's piece is there
    diags = [[row - 1, col - 1], [row - 1, col + 1]]
    diags.each do |diag|
      moves << diag if valid?(diag, board) && board[diag[0]][diag[1]] != ' '
    #en passant
    #end of board turn in to other piece
    end
    moves
  end
end

class Knight < Piece
  def initialize(color)
    @color = color
    @symbol = color == 'white' ? "\u{2658}" : "\u{265E}"
  end

  def poss_moves(row, col, board)
    moves = [
      [row - 2, col - 1], [row - 2, col + 1], [row - 1, col - 2], [row - 1, col + 2],
      [row + 1, col - 2], [row + 1, col + 2], [row + 2, col - 1], [row + 2, col + 1]
    ]
    moves.select do |move|
      valid?(move, board)
    end
  end
end

class Bishop < Piece
  def initialize(color)
    @color = color
    @symbol = color == 'white' ? "\u{2657}" : "\u{265D}"
  end
  
  def poss_moves(row, col, board)
    moves = []
    shifts = [[1, 1], [-1, 1], [1, -1], [-1, -1]]
    shifts.each do |shift|
      (1..7).each do |n|
        move = [row + (n * shift[0]), col + (n * shift[1])]
        if valid?(move, board)
          current_occupant = board[move[0]][move[1]]
          moves << move
          break unless current_occupant == ' '
        else
          break
        end
      end
    end
    moves
  end
end

class Rook < Piece
  attr_accessor :moved

  def initialize(color)
    @color = color
    @symbol = color == 'white' ? "\u{2656}" : "\u{265C}"
  end

  def poss_moves(row, col, board)
    moves = []
    shifts = [[1, 0], [0, 1], [-1, 0], [0, -1]]
    shifts.each do |shift|
      (1..7).each do |n|
        move = [row + (n * shift[0]), col + (n * shift[1])]
        if valid?(move, board)
          current_occupant = board[move[0]][move[1]]
          moves << move
          break unless current_occupant == ' '
        else
          break
        end
      end
    end
    moves
  end
end

class Queen < Piece
  def initialize(color)
    @color = color
    @symbol = color == 'white' ? "\u{2655}" : "\u{265B}"
  end

  def poss_moves(row, col, board)
    moves = []
    shifts = [[1, 0], [0, 1], [-1, 0], [0, -1], [1, 1], [-1, 1], [1, -1], [-1, -1]]
    shifts.each do |shift|
      (1..7).each do |n|
        move = [row + (n * shift[0]), col + (n * shift[1])]
        if valid?(move, board)
          current_occupant = board[move[0]][move[1]]
          moves << move
          break unless current_occupant == ' '
        else
          break
        end
      end
    end
    moves
  end
end

class King < Piece
  attr_accessor :moved

  def initialize(color)
    @color = color
    @symbol = color == 'white' ? "\u{2654}" : "\u{265A}"
  end

  def poss_moves(row, col, board)
    moves = [
      [row + 1, col], [row + 1, col + 1], [row + 1, col - 1], [row, col + 1],
      [row - 1, col], [row - 1, col + 1], [row - 1, col - 1], [row, col - 1]
    ]
    moves.select do |move|
      valid?(move, board)
    end
  end
end