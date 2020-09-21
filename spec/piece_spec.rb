require './lib/piece.rb'

describe Pawn do
  let(:pawn) { Pawn.new('white') }
  let(:game) { Game.new }

  describe '#poss_moves' do
    context 'pawn is at starting position (row 6)'
    it 'returns an array of two possible moves when no piece in front of it' do
      expect(pawn.poss_moves(6, 3, game.board.grid)).to \
        eq([[5, 3], [4, 3]])
    end
    it 'returns an array of one move when a piece is blocking second option' do
      game.board.grid[4][3] = Pawn.new('black')
      expect(pawn.poss_moves(6, 3, game.board.grid)).to eq([[5, 3]])
    end
    it "returns an array of diagonal move when other player's piece is there" do
      game.board.grid[5][3] = Pawn.new('white')
      game.board.grid[5][2] = Knight.new('black')
      expect(pawn.poss_moves(6, 3, game.board.grid)).to eq([[5, 2]])
    end
  end
end

describe Knight do
  let(:knight) { Knight.new('white') }
  let(:game) { Game.new }

  describe '#initialize' do
    it 'creates an object with a color variable' do
      expect(knight.color).to eq('white')
    end
  end

  describe '#poss_moves' do
    it 'returns an array of possible moves given current coordinates and board' do
      expect(knight.poss_moves(3, 6, game.board.grid)).to \
        eq([[1, 5], [1, 7], [2, 4], [4, 4], [5, 5], [5, 7]])
    end
  end
end

describe Bishop do
  let(:bishop) { Bishop.new('white') }
  let(:game) { Game.new }

  describe '#poss_moves' do
    it 'returns an array of four possible moves given the board conditions' do
      game.board.move_piece([6, 4], [4, 4])
      game.board.move_piece([6, 2], [4, 2])
      game.board.move_piece([6, 6], [4, 6])
      expect(bishop.poss_moves(7, 5, game.board.grid)).to \
        eq([[6, 6], [5, 7], [6, 4], [5, 3]])
    end
  end
end

describe Rook do
  let(:rook) { Rook.new('white') }
  let(:game) { Game.new }

  describe '#poss_moves' do
    it 'returns an array of seven possible moves given the board conditions' do
      game.board.move_piece([6, 7], [3, 4])
      game.board.move_piece([7, 6], [5, 5])
      expect(rook.poss_moves(7, 7, game.board.grid)).to \
        eq([[6, 7], [5, 7], [4, 7], [3, 7], [2, 7], [1, 7], [7, 6]])
    end
  end
end

describe Queen do
  let(:queen) { Queen.new('white') }
  let(:game) { Game.new }

  describe '#poss_moves' do
    it 'returns an array of seven possible moves given the board conditions' do
      game.board.grid[4][3] = Pawn.new('white')
      expect(queen.poss_moves(4, 1, game.board.grid)).to eq(
        [[5, 1], [4, 2], [3, 1], [2, 1], [1, 1], [4, 0],
         [5, 2], [3, 2], [2, 3], [1, 4], [5, 0], [3, 0]]
      )
    end
  end
end

describe King do
  let(:king) { King.new('white') }
  let(:game) { Game.new }

  describe '#poss_moves' do
    it 'returns an array of seven possible moves given the board conditions' do
      game.board.grid[4][0] = Pawn.new('black')
      king.moved = true
      expect(king.poss_moves(5, 1, game.board.grid)).to eq(
        [[5, 2], [4, 1], [4, 2], [4, 0], [5, 0]]
      )
    end
  end
end