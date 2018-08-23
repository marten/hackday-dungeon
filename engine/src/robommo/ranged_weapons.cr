class RangedWeapon
  include JSON::Serializable
end

class Bow < RangedWeapon
  getter damage = 10

  def aim_north(world : World, from : Coord)
    [Coord.new(from.x, 0)]
  end

  def aim_east(world : World, from : Coord)
    [Coord.new(world.width - 1, from.y)]
  end

  def aim_south(world : World, from : Coord)
    [Coord.new(from.x, world.height - 1)]
  end

  def aim_west(world : World, from : Coord)
    [Coord.new(0, from.y)]
  end
end
