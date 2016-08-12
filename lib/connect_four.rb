class ConnectFour
	attr_accessor :board, :players, :current

	class Player
		attr_accessor :name, :symbol, :is_winner, :score

		def initialize(name, symbol)
			@name, @symbol = name, symbol
			@is_winner = false
			@score = 0
		end
	end

	def initialize
		@board = create_board(6,7)
		@players = create_players(2)

		@turn = 0
		@current = @players.sample
	end

	def start
		piece_location = nil
		until game_over?(piece_location)
			draw_board
			piece_location = take_turn(@current)
			@current = next_player(@current)
		end
		draw_board
	end


	private

	#Create empty board with num_rows, and num_columns
	def create_board(num_rows, num_columns)
		empty_cell = ' '
		row = []
		num_columns.times {row << empty_cell}
		board = []
		num_rows.times {board << Array.new(row)}

		board
	end

	#Create num players with names/symbols from stdin
	def create_players(num)
		players = []
		chosen = Hash.new(false)

		num.times do |index| 
			num = index + 1

			puts "Player #{num}, please enter your name:"
			name = gets.chomp
			puts; puts "And your symbol?:"; puts
			symbols = get_symbols
			present_symbols(symbols)
			symbol = gets.chomp

			until symbol.to_i.between?(1,symbols.length) && !chosen[symbol]
				puts 'incorrect choice, please input a number for an unchosen symbol'; puts
				symbol = gets.chomp
			end
			chosen[symbol] = true
			symbol = symbols[symbol.to_i - 1]
			players << Player.new(name, symbol)
		end
		players
	end

	def get_symbols
		symbols = []

		symbol = "\u2620"
		16.times do |num|
			symbols << symbol
			symbol = symbol.next
		end
		symbols
	end

	def present_symbols(symbols)
		symbols.each_with_index do |symbol, index|
			number = index + 1
			if number < 10 
				print "#{number.to_s}:  #{symbol}" + (' ' * 5) 
			elsif number < 100
				print "#{number.to_s}: #{symbol}" + (' ' * 5) 
			end
			puts if (number) % 8 == 0
		end
		puts
	end

	def take_turn(player)
		puts "#{player.name}, where would you like to drop your tile?"
		choice = gets.chomp.to_i - 1

		until choice.between?(0,6) && !column_full?(choice)
			puts "Please choose an appropriate number"
			choice = gets.chomp.to_i - 1
		end

		row_index = nil
		@board.each_with_index do |row, index|
			if row[choice] == ' '
				row[choice] = player.symbol
				row_index = index
				break
			end
		end

		@turn += 1
		return [row_index, choice]
	end

	def column_full?(choice)
		@board.last[choice] != ' '
	end

	def next_player(player)
		next_player = @players[@players.index(player) + 1]
		next_player = @players[0] if next_player.nil?

		next_player
	end

	def game_over?(loc)
		return false if loc.nil?

		result = false
		symbol = @board[loc[0]][loc[1]]
		adjacent_array = adjacents(symbol, loc[0], loc[1])
		adjacent_array.each do |adj|
			result = check_win(adj, symbol)
			break if result
		end
		result
	end

	def check_win(piece_info, symbol, count = 1)
		p piece_info
		return true if count >= 3

		done = false
		direction = piece_info.last
		loc_row = piece_info[0]
		loc_cell = piece_info[1]

		case direction
		when :up_left
			loc_row += 1
			loc_cell -= 1
		when :up 
			loc_row += 1
		when :up_right 
			loc_row += 1
			loc_cell += 1
		when :right 
			loc_cell += 1
		when :down_right 
			loc_row -= 1
			loc_cell += 1
		when :down 
			loc_row -= 1
		when :down_left 
			loc_row -= 1
			loc_cell -= 1
		when :left 
			loc_cell -= 1
		end

		if @board[loc_row][loc_cell] == symbol
			done = check_win([loc_row, loc_cell, direction], symbol, count + 1)
			return done
		else
			return false
		end
	end

	def adjacents(symbol, row_index, cell_index)
		adjacents = []
		#upper left case
		if @board[row_index + 1][cell_index - 1] == symbol &&
			row_index.between?(0, 4) && cell_index.between?(1,6)

			adjacents << [row_index + 1, cell_index - 1, :up_left]
		end

		#upper case
		if @board[row_index + 1][cell_index] == symbol &&
			row_index.between?(0, 4)

			adjacents << [row_index + 1, cell_index, :up]
		end

		#upper right case
		if @board[row_index + 1][cell_index + 1] == symbol &&
			row_index.between?(0, 4) && cell_index.between?(0,5)

			adjacents << [row_index + 1, cell_index + 1, :up_right]
		end

		#right case
		if @board[row_index][cell_index + 1] == symbol &&
			cell_index.between?(0,5)

			adjacents << [row_index, cell_index + 1, :right]
		end

		#lower right case
		if @board[row_index - 1][cell_index + 1] == symbol &&
			row_index.between?(1, 5) && cell_index.between?(0,5)

			adjacents << [row_index - 1, cell_index + 1, :down_right]
		end

		#lower case
		if @board[row_index - 1][cell_index] == symbol &&
			row_index.between?(1, 5)

			adjacents << [row_index - 1, cell_index, :down]
		end

		#lower left case
		if @board[row_index - 1][cell_index - 1] == symbol &&
			row_index.between?(1, 5) && cell_index.between?(1,6)

			adjacents << [row_index - 1, cell_index - 1, :down_left]
		end

		#left case
		if @board[row_index][cell_index - 1] == symbol &&
			cell_index.between?(1,6)

			adjacents << [row_index, cell_index - 1, :left]
		end

		adjacents
	end

	def draw_board
		puts;puts;
		index = 0
		num_spaces = 29
		players.each do |player|
			if index % 2 == 0
				print "#{player.name}: #{player.symbol}" + (" " * num_spaces)
			else
				print "#{player.name}: #{player.symbol}\n"
			end
			index += 1
		end; puts

		print " " * 8
		1.upto(@board[0].length) { |n| print "#{n}   " }; puts

		row_border = '-----------------------------'
		@board.reverse.each do |row|
			print " " * 6
			puts row_border
			print " " * 6
			print "|"
			row.each do |cell|
				print " #{cell} |"
			end
			puts
		end
		print " " * 6; puts row_border
	end

	def empty?
		@turn == 0
	end

	def full?
		@turn == @board.length * @board[0].length
	end

end

game = ConnectFour.new
game.start