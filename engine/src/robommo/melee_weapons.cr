abstract class MeleeWeapon
  include JSON::Serializable

  abstract def aim_north(world : World, from : Coord) : Array(Coord)
  abstract def aim_east(world : World, from : Coord) : Array(Coord)
  abstract def aim_south(world : World, from : Coord) : Array(Coord)
  abstract def aim_west(world : World, from : Coord) : Array(Coord)
end

class Sword < MeleeWeapon
  getter damage = 5

  def aim_north(world : World, from : Coord)
    [from.north]
  end

  def aim_east(world : World, from : Coord)
    [from.east]
  end

  def aim_south(world : World, from : Coord)
    [from.south]
  end

  def aim_west(world : World, from : Coord)
    [from.west]
  end
end

class GroundStomp < MeleeWeapon
  getter damage = 3

  def aim_north(world, from)
    [] of Coord
  end
  def aim_east(world, from)
    [] of Coord
  end
  def aim_south(world, from)
    [] of Coord
  end
  def aim_west(world, from)
    [] of Coord
  end
end
