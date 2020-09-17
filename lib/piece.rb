class Piece
  require 'pry'
  attr_accessor :color, :symbol

  def initialize
  end

  def poss_moves(moves, board)
    # Select for moves that are on the board
    moves.select do |move|
      current_occupant = board[move[0]][move[1]]
      # Determine color of occupant in target square, to ensure not one of current player's
      curr_occ_color = current_occupant == ' ' ? 'green' : current_occupant.color
      move[0].between?(0, 7) && move[1].between?(0, 7) && curr_occ_color != @color
    end
  end

  def valid?(move, board)
    return false unless move[0].between?(0, 7) && move[1].between?(0, 7)

    current_occupant = board[move[0]][move[1]]
    # Determine color of occupant in target square, to ensure not one of current player's
    curr_occ_color = current_occupant == ' ' ? 'green' : current_occupant.color
    return false if curr_occ_color == @color
    #if would cause check
    true
  end
end

class Pawn < Piece
  def initialize(color)
    @color = color
    @symbol = color == 'white' ? "\u{2659}" : "\u{265F}"
  end

  def poss_moves(row, col, board)
    moves = [[row - 1, col]]
    
    #pawn can move two if in row 6, but not if there's a
    #pawn in the way. 
    #pawn can't move if anything in the way.
    #if row == 6 && board[row - 1][col] == ' '
     # moves << [row - 2, col]
    #end
    super(moves, board)
    #en passant
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
  def initialize(color)
    @color = color
    @symbol = color == 'white' ? "\u{2654}" : "\u{265A}"
  end
  
  def poss_moves(row, col, board)
  #cant go through check
  end
end