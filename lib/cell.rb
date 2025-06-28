class Cell
  attr_accessor :x, :y, :value, :merged, :moved

  COLOR_MAPPING = {
    2    => { color: :black, background: :light_blue },
    4    => { color: :black, background: :light_yellow },
    8    => { color: :black, background: :light_green },
    16   => { color: :black, background: :light_cyan },
    32   => { color: :black, background: :light_magenta },
    64   => { color: :black, background: :light_red },
    128  => { color: :black, background: :blue },
    256  => { color: :black, background: :red },
    512  => { color: :black, background: :magenta },
    1024 => { color: :black, background: :yellow },
    2048 => { color: :black, background: :cyan },
    4096 => {color: :black, background: :green },
    # 2 => {color: :black, background: :light_black },
    # 2 => {color: :black, background: :light_blue },
    # 2 => {color: :black, background: :light_magenta },
    # 2 => {color: :black, background: :light_cyan },
    # 2 => {color: :black, background: :grey },
    # 2 => {color: :black, background: :gray },
    # 2 => {color: :black, background: :black },
  }

  def reset
    @merged = false
    @moved = false
  end

  def initialize(x, y, color = nil)
    @x = x
    @y = y
    @color = color
    @value = 0
  end

  # def render_cell
  #   return '[  ]'.colorize(color: :gray, background: :gray) if @value.zero?

  #   @value.to_s.rjust(4, ' ').colorize(**COLOR_MAPPING[@value])
  # end

  def render_cell
    if @value.zero?
      return [
        '     ',
        '     ',
        '     '
      ].map { |c| c.colorize(color: :white, background: :gray) }
    end
    # return '[  ]'.colorize(color: :gray, background: :gray) if @value.zero?

    return [
      '     ',
      @value.to_s.center(5),
      '     '
    ].map { |c| c.colorize(**COLOR_MAPPING[@value]) }
  end

  def empty?
    @value.zero?
  end

  def to_s
    "#{@x}:#{@y}-#{@value}"
  end

  def long_s
    "X:#{@x}, Y:#{@y}, Value:#{@value}"
  end

  def inspect
    to_s
  end
end
