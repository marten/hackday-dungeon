class Coord
  include JSON::Serializable

  getter x : Int32
  getter y : Int32

  def initialize(@x : Int32, @y : Int32)
  end

  def ==(other)
    other.x == x && other.y == y
  end

  def inside?(world)
    @x >= 0 && @x < world.width && @y >= 0 && @y < world.height
  end

  def to(other : Coord) : Array(Coord)
    x0 = x
    y0 = y
    x1 = other.x
    y1 = other.y
    coords = [] of Coord

    steep = ((y1-y0).abs) > ((x1-x0).abs)

    if steep
      x0,y0 = y0,x0
      x1,y1 = y1,x1
    end

    if x0 > x1
      x0,x1 = x1,x0
      y0,y1 = y1,y0
    end

    deltax = x1-x0
    deltay = (y1-y0).abs
    error = (deltax / 2).to_i
    curr_y = y0
    ystep = nil

    if y0 < y1
      ystep = 1
    else
      ystep = -1
    end

    (x0..x1).each do |curr_x|
      next if curr_x == x && curr_y == y
      if steep
        coords << Coord.new(curr_y, curr_x) #{:x => y, :y => x}
      else
        coords << Coord.new(curr_x, curr_y) #{:x => x, :y => y}
      end

      error -= deltay
      if error < 0
        curr_y += ystep
        error += deltax
      end
    end

    if other.x < x
      coords.reverse
    else
      coords
    end
  end

  def neighbour(direction : Direction) : Coord
    case direction
    when Direction::North then north()
    when Direction::East  then east()
    when Direction::South then south()
    when Direction::West  then west()
    else raise("Unknown Direction")
    end
  end

  def north
    Coord.new(@x, @y - 1)
  end

  def east
    Coord.new(@x + 1, @y)
  end

  def south
    Coord.new(@x, @y + 1)
  end

  def west
    Coord.new(@x - 1, @y)
  end
end
