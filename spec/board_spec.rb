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
  end

  describe '#find_coord' do
    it 'returns the grid coordinates given the letter, number input' do
      expect(@board.find_coord('e2')).to eq([6, 4])
    end
  end
end