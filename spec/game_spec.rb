require './lib/game.rb'

describe Game do
  let(:game) { Game.new }

  describe '#initialize' do
    it 'creates player objects' do
      expect(game.player1).to be_an_instance_of(Player)
    end

    it 'sets current player to be player1' do
      expect(game.current_player).to eq(game.player1)
    end
  end

  describe '#add_pieces_to_board' do
    it 'creates a board object' do
      game.add_pieces_to_board
      expect(game.board).to be_an_instance_of(Board)
    end
  end

  describe '#display_instructions' do
    it 'displays game instructions' do
      expect { game.display_instructions }.to \
        output(/#{Regexp.quote('Welcome to chess!')}/).to_stdout
    end
  end

  describe '#change_player_name' do
    it "sets players' names based on input" do
      allow(game).to receive(:gets).and_return('Naomi')
      game.change_player_name(game.player1)
      expect(game.player1.name).to eq('Naomi')
    end
  end

  describe '#request_piece' do
    before do
      allow(game).to receive(:loop).and_yield.and_yield
    end

    context 'user inputs a letter number sequence' do
      before do
        allow(game).to receive(:gets).and_return('E2')
      end

      it 'sets piece coordinates' do
        game.request_piece
        expect(game.coord).to eq([6, 4])
      end

      it 'breaks the loop' do
        expect(game).to receive(:gets).once
        game.request_piece
      end
    end

    context "user inputs an incorrect value or coordinates for other player's piece" do
      it 'continues to loop' do
        allow(game).to receive(:gets).and_return('a', 'c7')
        expect(game).to receive(:gets).exactly(:twice)
        game.request_piece
      end
    end
  end

  describe '#switch_player' do
    it 'toggles the value of @current_player between player1 and player2' do
      game.current_player = game.player1
      game.switch_player
      expect(game.current_player).to eq(game.player2)
    end
  end
end