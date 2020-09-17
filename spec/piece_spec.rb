require './lib/piece.rb'

describe Knight do
  let(:knight) { Knight.new('white') }

  describe '#initialize' do
    it 'creates an object with a color variable' do
      expect(knight.color).to eq('white')
    end
  end

  #describe '#poss_moves' do
    #let(:board) { double('board') }
   # it 'returns an array of possible moves' do
      
    #  expect(knight.poss_moves(board, [3, 6])).to \
     #   eq([[1, 5], [1, 7], [2, 4], [4, 4], [5, 5], [5, 7]])
    #end
  #end
end