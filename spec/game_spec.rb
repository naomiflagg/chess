require './lib/game.rb'

describe Game do
  let(:game) { Game.new }
  let(:board) { game.board }

  describe '#initialize' do
    it 'creates a board object' do
      expect(board).to be_an_instance_of(Board)
    end

    it 'sets current player to be player1' do
      expect(game.current_player).to eq(game.player1)
    end

    it 'creates player objects with king instance variables' do
      expect(game.player1.king.class).to eq(King)
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
        expect(game.start).to eq([6, 4])
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

  describe '#request_destination' do
    let(:poss_moves) { [[0, 4], [1, 6]] }

    before do
      allow(game).to receive(:loop).and_yield.and_yield
    end

    context 'user inputs a letter number sequence' do
      before do
        allow(game).to receive(:gets).and_return('g7')
        game.start = [1, 3]
      end

      it 'returns an array of array indices if array contained in possible moves' do
        expect(game.request_destination(poss_moves)).to eq([1, 6])
      end

      it 'breaks the loop' do
        expect(game).to receive(:gets).once
        game.request_destination(poss_moves)
      end
    end

    context 'user inputs an incorrect value' do
      it 'continues to loop' do
        allow(game).to receive(:gets).and_return('a', 'h9')
        expect(game).to receive(:gets).exactly(:twice)
        game.request_destination(poss_moves)
      end
    end
  end
  
  describe '#request_promotion' do
    before do
      allow(game).to receive(:gets).and_return('queen')
    end

    it 'changes the pawn to the requested piece' do
      piece = board.grid[6][2]
      game.request_promotion(piece)
      expect(board.grid[6][2].class).to eq(Queen)
    end
  end

  describe '#switch_player' do
    before do
      game.current_player = game.player1
      game.switch_player
    end

    it 'toggles the value of @current_player between player1 and player2' do
      expect(game.current_player).to eq(game.player2)
    end

    it 'toggles the value of @opposing between player1 and player2' do
      expect(game.opposing_player).to eq(game.player1)
    end
  end
end