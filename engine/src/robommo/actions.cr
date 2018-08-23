require "json"
require "./events"

abstract class Action
  COLLISION_DAMAGE = 10
  OUT_OF_BOUNDS_DAMAGE = 5

  def initialize(@entity : Entity)
  end

  def entity
    @entity
  end

  abstract def act(world) : Array(GameEvent)

  class Nothing < Action
    def act(world)
      [] of GameEvent
    end
  end

  class ProgramError < Action
    def act(world)
      [GameEvent::ProgramError.new(entity)]
    end
  end

  class Spawn < Action
    def act(world)
      world.update_entity(entity)
      [GameEvent::Spawned.new(entity)]
    end
  end

  abstract class Move < Action
    def move_to(world, coord)
      from = entity.coord
      entities_at_destination = world.at(coord)
      collider = entities_at_destination.find { |other| entity.collides_with?(other) }

      if coord.inside?(world)
        if collider
          entity.health = entity.health - COLLISION_DAMAGE
          [GameEvent::Collision.new(entity, collider, COLLISION_DAMAGE)]
        else
          entity.move_to(coord)
          [GameEvent::Move.new(entity, from, coord)]
        end
      else
        entity.health = entity.health - OUT_OF_BOUNDS_DAMAGE
        [GameEvent::OutOfBounds.new(entity, OUT_OF_BOUNDS_DAMAGE)]
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
      if entity.is_a? Player
        entity.ducked = true
        [GameEvent::Duck.new(entity)]
      else
        [] of GameEvent
      end
    end
  end

  abstract class AttackAction(T) < Action
    def attack_with(world, aimed_coords, weapon)
      coords = [] of Coord
      hits = [] of T::Hit
      deaths = [] of GameEvent::Death

      aimed_coords.each do |coord|
        hit_entities = yield(coord)

        if hit_entities.any?
          hit_entity = hit_entities.first
          coords << coord

          if hit_entity.is_a?(Player)
            damage = weapon.damage
            hit_entity.health -= damage

            if hit_entity.dead?
              deaths << GameEvent::Death.new(hit_entity, killed_by: entity)
            end

            hits << {entity: hit_entity.id, damage: damage}
          end
        else
          coords << coord
        end
      end

      ([T.new(@entity, coords, hits)] of GameEvent).concat(deaths)
    end
  end

  abstract class Melee < AttackAction(GameEvent::Melee)
    def attack(world, aimed_coords : Array(Coord))
      attack_with(world, aimed_coords, entity.melee_weapon) do |coord|
        world.at(coord)
      end
    end
  end

  abstract class Ranged < AttackAction(GameEvent::Ranged)
    def attack(world, aimed_coords : Array(Coord))
      attack_with(world, aimed_coords, entity.ranged_weapon) do |coord|
        world.hitscan(@entity.coord, coord)
      end
    end
  end

  class MeleeNorth < Melee
    def act(world)
      coords = entity.melee_weapon.aim_north(world, @entity.coord)
      attack(world, coords)
    end
  end

  class MeleeEast < Melee
    def act(world)
      coords = entity.melee_weapon.aim_east(world, @entity.coord)
      attack(world, coords)
    end
  end

  class MeleeSouth < Melee
    def act(world)
      coords = entity.melee_weapon.aim_south(world, @entity.coord)
      attack(world, coords)
    end
  end

  class MeleeWest < Melee
    def act(world)
      coords = entity.melee_weapon.aim_west(world, @entity.coord)
      attack(world, coords)
    end
  end

  class RangedNorth < Ranged
    def act(world)
      attack(world, @entity.ranged_weapon.aim_north(world, @entity.coord))
    end
  end

  class RangedEast < Ranged
    def act(world)
      attack(world, @entity.ranged_weapon.aim_east(world, @entity.coord))
    end
  end

  class RangedSouth < Ranged
    def act(world)
      attack(world, @entity.ranged_weapon.aim_south(world, @entity.coord))
    end
  end

  class RangedWest < Ranged
    def act(world)
      attack(world, @entity.ranged_weapon.aim_west(world, @entity.coord))
    end
  end
end
