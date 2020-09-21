require './lib/game.rb'

describe Game do
  let(:game) { Game.new }
  let(:board) { game.board }

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
      expect(board).to be_an_instance_of(Board)
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

  describe '#causes_check?' do
    it "returns true if potential move leaves current player's king in check" do
      board.move_piece([7, 4], [4, 4])
      board.grid[2][2] = Queen.new('black')
      expect(game.causes_check?(game.kingw, [4, 4], [4, 5])).to be_falsey
    end

    it "returns falsey if potential move leaves curren't player's king out of check" do
      board.move_piece([7, 4], [4, 4])
      board.grid[2][2] = Queen.new('black')
      expect(game.causes_check?(game.kingw, [4, 4], [3, 3])).to be true
    end
  end

  describe '#check?' do
    it 'returns true if king is in check' do
      board.move_piece([7, 4], [4, 4])
      board.grid[2][2] = Queen.new('black')
      expect(game.check?(game.kingw)).to be true
    end

    it 'returns true if king is in check' do
      board.move_piece([6, 5], [5, 5])
      board.move_piece([6, 6], [4, 6])
      board.move_piece([0, 3], [4, 7])
      expect(game.check?(game.kingw)).to be true
    end
  end

  describe '#checkmate?' do
    it 'returns true if king is in checkmate' do
      board.move_piece([1, 5], [2, 5])
      board.move_piece([1, 6], [3, 6])
      board.move_piece([7, 3], [3, 7])
      expect(game.checkmate?).to be true
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
        game.coord = [1, 3]
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
  
  describe '#add_castle_moves' do
    before(:each) do
      game.selected_piece = game.kingw
      game.poss_moves = []
      board.grid[7][5] = ' '
      board.grid[7][6] = ' '
      board.grid[7][1] = ' '
      board.grid[7][2] = ' '
      board.grid[7][3] = ' '
    end

    context 'when rook is unmoved, and spaces between rook and king are blank' do
      it 'adds castle option to possible moves' do
        game.add_castle_moves
        expect(game.poss_moves).to eq([[7, 6], [7, 2]])
      end
    end

    context 'when rook is moved on right but not left' do
      it 'adds castle options for left but not right' do
        board.grid[7][7].moved = true
        game.add_castle_moves
        expect(game.poss_moves).to eq([[7, 2]])
      end
    end

    context 'spaces between rook and king are not empty' do
      it 'does not add castle options' do
        board.grid[7][5] = Pawn.new('black')
        board.grid[7][3] = Pawn.new('white')
        expect { game.add_castle_moves }.to_not change{ game.poss_moves }
      end
    end
  end

  describe '#castle' do
    it 'moves rook depending on target destination for king' do
      board.move_piece([7, 5], [3, 5])
      board.move_piece([7, 6], [4, 6])
      game.selected_piece = board.grid[7][4]
      game.dest = [7, 6]
      game.castle
      expect(board.grid[7][5].class).to eq(Rook)
    end
  end

  describe '#add_en_passant_move' do
    it 'adds en passant move when last move was pawn moving 2 from start' do
      game.poss_moves = []
      pawn = board.grid[6][4]
      board.move_piece([6, 4], [4, 4])
      game.last_move = [pawn, [6, 4], [4, 4]]
      game.selected_piece = board.grid[6][5]
      board.move_piece([6, 5], [3, 5])
      game.coord = [4, 5]
      game.add_en_passant_move
      expect(game.poss_moves). to eq([[3, 4]])
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