require './lib/board.rb'

describe Board do
  before(:all) do
    game = Game.new
    @board = game.board
    @grid = @board.grid
  end

  describe '#initialize' do
    it 'creates an 8 x 8 array' do
      expect(@grid.size).to eq(8)
    end

    it 'creates grid variable of type array' do
      expect(@grid).to be_instance_of Array
    end
  end

  describe '#display' do
    it 'displays the board in its current form' do
      expect { @board.display }.to \
        output(/#{Regexp.quote('a   b   c   d   e   f   g   h')}/).to_stdout
    end

    it 'displays the fallen pieces when there are any' do
      @board.fallen << Pawn.new('black')
      expect { @board.display }.to output(/#{Regexp.quote('The fallen:')}/).to_stdout
    end
  end

  describe '#find_coord' do
    it 'returns the grid coordinates given the letter, number input' do
      expect(@board.find_coord('e2')).to eq([6, 4])
    end
  end

  describe '#move_piece' do
    before(:all) do
      @grid[2][5] = Knight.new('white')
      @board.move_piece([1, 3], [2, 5])
    end

    it 'substitutes the element at grid finish with element at grid start' do
      expect(@grid[2][5]).to be_instance_of Pawn
    end
    
    it 'creates an empty square the moving piece starts' do
      expect(@grid[1][3]).to eq(' ')
    end

    it 'adds an eliminated piece to fallen array' do
      expect(@board.fallen.size).to eq(3)
    end
  end
end