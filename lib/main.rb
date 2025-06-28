require 'tty-prompt'
require 'colorize'
require_relative 'cell'

class Main
    def initialize
      @board_width = 4
      @board_height = 4
      @reader = TTY::Reader.new(interrupt: :exit)
      @cursor = TTY::Cursor
      @debug = false
    end

    def initialize_grid
      @grid = Array.new(@board_height) { Array.new(@board_width) }
      @board_height.times do |x|
        @board_width.times do |y|
          @grid[x][y] = Cell.new(x, y, :black)
        end
      end
    end

    def start
      initialize_grid
      # p @grid
      2.times { generate_tile }
      @on_move_tiles = lambda {
        return unless @grid.flatten.any?(&:moved)

        success = generate_tile
        end_game unless success
        print @cursor.clear_lines((@board_height * 4) + 1, :up)
        print_grid
      }
      # check_neighbors(1, 1)
      print_grid

      key_mapping = {
        up:    [:up, 'w', 'k'],
        down:  [:down, 's', 'j'],
        left:  [:left, 'a', 'h'],
        right: [:right, 'd', 'l']
      }
      @reader.on(:keypress) do |event|
        input_val = event.key.name == :alpha ? event.value : event.key.name
        val = key_mapping.select { |_, v| v.include?(input_val) }.keys.first
        send(:move_tiles, val) unless val.nil?
        if event.value == 'p'
          puts 'clearing lines'
          print @cursor.clear_lines(5, :up)
          @cursor.clear_screen_up
        end
      end
      loop do
        @reader.read_keypress
      end
    end

    #     Moving 2:1-2 to neighbor {:collision_cell=>nil, :collision_minus_1=>0:1-0}
    # Moving 3:1-2 to neighbor {:collision_cell=>2:1-2, :collision_minus_1=>3:1-2}

    def shift_cell(cell, direction)
      collision = get_neighbors(cell, direction)
      puts "Moving #{cell} to neighbor #{collision}" if @debug

      if collision[:collision_cell].nil?
        puts 'Hit wall' if @debug
        collision[:collision_minus_1].value = cell.value
        cell.value = 0 if collision[:collision_minus_1] != cell
      elsif collision[:collision_cell].value == cell.value && !collision[:collision_cell].merged
        puts 'merging' if @debug
        cell.value = 0
        collision[:collision_cell].value *= 2
        collision[:collision_cell].merged = true # Dont double merge
      else
        puts 'Hit other cell' if @debug
        collision[:collision_minus_1].value = cell.value
        cell.value = 0 if collision[:collision_minus_1] != cell
      end

      print_grid('after shift') if @debug
    end

    def move_tiles(direction)
      case direction
      when :up
        @grid.each_with_index do |x, _i|
          x.each do |y|
            next if y.empty?

            shift_cell(y, :up)
          end
        end
      when :down
        @grid.reverse_each do |x|
          x.each do |y|
            next unless y.value > 0

            shift_cell(y, direction)
          end
        end
      when :left
        @grid.each do |x|
          x.each do |y|
            next unless y.value > 0

            shift_cell(y, direction)
          end
        end
      when :right
        @grid.each do |x|
          x.reverse_each do |y, _i|
            next unless y.value > 0

            shift_cell(y, direction)
          end
        end
      end
      @on_move_tiles&.call
      @grid.flatten.each(&:reset)
    end

    def print_grid(msg = 'YAY')
      if @debug
        puts "-----------------#{msg}--------------------"
        @grid.each_with_index do |x, i|
          if @debug
            puts "#{i} - #{x}"
          else
            puts "#{i} - #{x.map(&:value)}"
          end
        end
        puts '----------------------------------------'
      else
        @grid.each do |x|
          print '-' * (@board_width * 7) + "\n"
          3.times do |i|
            line = ''
            x.each do |y|
              line += "|#{y.render_cell[i]}|"
            end
            line += "\n"
            print line
          end
        end
        # @grid.each_with_index do |x, _i|
        #   x.each do |y|
        #     print "|#{y.render_cell}|"
        #   end
        #   print "\n"
        # end
      end
    end

    def get_neighbors(cell, direction, results: { collision_cell: nil, collision_minus_1: nil })
      # puts 'checking dir'
      # puts "Orig cell #{cell.long_s}"
      # puts @board_width
      # puts @board_height
      n_cell = case direction
               when :up
                 @grid[cell.x - 1][cell.y] unless (cell.x - 1).negative?
               when :down
                 @grid[cell.x + 1][cell.y] unless (cell.x + 1) >= @board_height
               when :left
                 @grid[cell.x][cell.y - 1] unless (cell.y - 1) < 0
               when :right
                 @grid[cell.x][cell.y + 1] unless (cell.y + 1) > @board_width
               end

      results[:collision_minus_1] = cell
      results[:collision_cell] = n_cell
      return results if n_cell.nil?
      return results unless n_cell.empty?

      get_neighbors(n_cell, direction, results:)
      results
    end

    def end_game
      puts '!!!!!! AHHHHHHHH ITS OVER!!!!!!'
    end

    def generate_tile
      available_cells = @grid.flatten.select { |v| v.empty? }
      return false if available_cells.empty?

      p available_cells if @debug
      available_cells.sample.value = pick_number
      true
    end

    def pick_number
      return 2 if rand < 0.9

      4
    end
end
