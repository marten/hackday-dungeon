require "json"

abstract class Action
  def self.from(string)
    case string
    when "nothing"
      Action::Nothing
    when "move_north"
      Action::MoveNorth
    when "move_east"
      Action::MoveEast
    when "move_south"
      Action::MoveSouth
    when "move_west"
      Action::MoveWest
    when "duck"
      Action::Duck
    when "melee_north"
      Action::MeleeNorth
    when "melee_east"
      Action::MeleeEast
    when "melee_south"
      Action::MeleeSouth
    when "melee_west"
      Action::MeleeWest
    when "ranged_north"
      Action::RangedNorth
    when "ranged_east"
      Action::RangedEast
    when "ranged_south"
      Action::RangedSouth
    when "ranged_west"
      Action::RangedWest
    else
      Action::Nothing
    end
  end

  def initialize(@entity : Entity)
  end

  def entity
    @entity
  end

  abstract def act(world)

  class Nothing < Action
    def act(world)
      return world
    end
  end

  abstract class Move < Action
    # TODO: bounds checking, collision checking, etc
    def move_to(world, coord)
      if coord.inside?(world)
        next_entity = entity.update({coord: coord})
        world.update_entity(next_entity)
      else
        next_entity = entity.update({health: entity.health - 1})
        world.update_entity(next_entity)
      end
    end
  end

  class MoveNorth < Move
    def act(world)
      move_to(world, entity.coord.north)
    end
  end

  class MoveEast < Move
    def act(world)
      move_to(world, entity.coord.east)
    end
  end

  class MoveSouth < Move
    def act(world)
      move_to(world, entity.coord.south)
    end
  end

  class MoveWest < Move
    def act(world)
      move_to(world, entity.coord.west)
    end
  end

  class Duck < Action
    def act(world)
      next_entity = entity.update({ducked: true})
      world = world.update_entity(next_entity)
      return world
    end
  end

  abstract class Melee < Action
  end

  class MeleeNorth < Melee
    def act(world)
      return world
    end
  end

  class MeleeEast < Melee
    def act(world)
      return world
    end
  end

  class MeleeSouth < Melee
    def act(world)
      return world
    end
  end

  class MeleeWest < Melee
    def act(world)
      return world
    end
  end

  abstract class Ranged < Action
  end

  class RangedNorth < Ranged
    def act(world)
      return world
    end
  end

  class RangedEast < Ranged
    def act(world)
      return world
    end
  end

  class RangedSouth < Ranged
    def act(world)
      return world
    end
  end

  class RangedWest < Ranged
    def act(world)
      hit_entities = world.hitscan(entity.coord, Direction::West)
      print "Player #{entity.id} uses #{entity.ranged_weapon.class} "

      if hit_entities.any?
        hit_entity = hit_entities.first
        damage = entity.ranged_weapon.damage
        new_health = hit_entity.health - damage

        puts "and hits #{hit_entity.id}, new health: #{new_health}"
        hit_entity = hit_entity.update({health: new_health})
        world.update_entity(hit_entity)
      else
        puts "but hits nothing"
        world
      end
    end
  end
end
