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
