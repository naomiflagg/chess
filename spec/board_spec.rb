require './lib/board.rb'

describe Board do
  let(:game) { Game.new }
  let(:board) { game.board }
  let(:grid) { board.grid }
  let(:king) { game.current_player.king }

  describe '#initialize' do
    it 'creates an 8 x 8 array' do
      expect(grid.size).to eq(8)
    end

    it 'creates grid variable of type array' do
      expect(grid).to be_instance_of Array
    end
  end

  describe '#display' do
    it 'displays the board in its current form' do
      expect { board.display }.to \
        output(/#{Regexp.quote('a   b   c   d   e   f   g   h')}/).to_stdout
    end

    it 'displays the fallen pieces when there are any' do
      board.fallen << Pawn.new('black')
      expect { board.display }.to output(/#{Regexp.quote('The fallen:')}/).to_stdout
    end
  end

  describe '#find_coord' do
    it 'returns the grid coordinates given the letter, number input' do
      expect(board.find_coord('e2')).to eq([6, 4])
    end
  end


  describe '#add_castle_moves' do
    let(:piece) { game.current_player.king }
    let(:start) { [7, 3] }
    let(:poss_moves) { [] }
    before(:each) do
      grid[7][5] = ' '
      grid[7][6] = ' '
      grid[7][1] = ' '
      grid[7][2] = ' '
      grid[7][3] = ' '
    end

  context 'when rook is unmoved, and spaces between rook and king are blank' do
    it 'adds castle option to possible moves' do
      board.add_castle_moves(piece, start, poss_moves)
      expect(poss_moves).to eq([[7, 6], [7, 2]])
    end
  end

  context 'when rook is moved on right but not left' do
    it 'adds castle options for left but not right' do
      grid[7][7].moved = true
      board.add_castle_moves(piece, start, poss_moves)
      expect(poss_moves).to eq([[7, 2]])
    end
  end

  context 'spaces between rook and king are not empty' do
    it 'does not add castle options' do
      grid[7][5] = Pawn.new('black')
      grid[7][3] = Pawn.new('white')
      expect { board.add_castle_moves(piece, start, poss_moves) }.to_not \
        change{ poss_moves }
    end
  end
end

describe '#castle' do
  it 'moves rook depending on target destination for king' do
    board.move_piece([7, 5], [3, 5])
    board.move_piece([7, 6], [4, 6])
    piece = board.grid[7][4]
    finish = [7, 6]
    board.castle(piece, finish)
    expect(grid[7][5].class).to eq(Rook)
  end
end

describe '#add_en_passant_move' do
  it 'adds en passant move when last move was pawn moving 2 from start' do
    poss_moves = []
    board.move_piece([6, 5], [3, 5])
    board.move_piece([6, 4], [4, 4])
    board.add_en_passant_move([4, 5], poss_moves)
    expect(poss_moves). to eq([[3, 4]])
  end
end

  describe '#causes_check?' do
    it "returns true if potential move leaves current player's king in check" do
      board.move_piece([7, 4], [4, 4])
      grid[2][2] = Queen.new('black')
      expect(board.causes_check?(king, [4, 4], [4, 5])).to be_falsey
    end

    it "returns falsey if potential move leaves curren't player's king out of check" do
      board.move_piece([7, 4], [4, 4])
      grid[2][2] = Queen.new('black')
      expect(board.causes_check?(king, [4, 4], [3, 3])).to be true
    end
  end

  describe '#check?' do
    it 'returns true if king is in check' do
      board.move_piece([7, 4], [4, 4])
      grid[2][2] = Queen.new('black')
      expect(board.check?(king)).to be true
    end

    it 'returns true if king is in check' do
      board.move_piece([6, 5], [5, 5])
      board.move_piece([6, 6], [4, 6])
      board.move_piece([0, 3], [4, 7])
      expect(board.check?(king)).to be true
    end
  end

  describe '#checkmate?' do
    it 'returns true if king is in checkmate' do
      board.move_piece([1, 5], [2, 5])
      board.move_piece([1, 6], [3, 6])
      board.move_piece([7, 3], [3, 7])
      expect(board.checkmate?).to be true
    end
  end

  describe '#move_piece' do
    before do
      board.fallen = []
      grid[2][5] = Knight.new('white')
      board.move_piece([1, 3], [2, 5])
    end

    it 'substitutes the element at grid finish with element at grid start' do
      expect(grid[2][5]).to be_instance_of Pawn
    end

    it 'creates an empty square the moving piece starts' do
      expect(grid[1][3]).to eq(' ')
    end

    it 'adds an eliminated piece to fallen array' do
      expect(board.fallen.size).to eq(1)
    end
  end

  describe '#flip' do
    it 'flips the board' do
      last = grid[7][7]
      board.flip
      expect(grid[0][0]).to eq(last)
    end
  end
end