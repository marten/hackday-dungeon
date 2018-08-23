require "json"
require "./events"

module Actions
  abstract class Base
  end

  abstract class PlayerAction < Base
    COLLISION_DAMAGE = 10
    OUT_OF_BOUNDS_DAMAGE = 50

    def initialize(@entity : Player)
    end

    def entity
      @entity
    end

    abstract def act(world) : Array(GameEvent)
  end

  class Nothing < PlayerAction
    def act(world)
      [] of GameEvent
    end
  end

  class ProgramError < PlayerAction
    def act(world)
      [GameEvent::ProgramError.new(entity)]
    end
  end

  class Spawn < PlayerAction
    def act(world)
      world.update_entity(entity)
      [GameEvent::Spawned.new(entity)]
    end
  end

  abstract class Move < PlayerAction
    def move_to(world, coord)
      from = entity.coord
      entities_at_destination = world.at(coord)
      collider = entities_at_destination.find { |other| entity.collides_with?(other) }

      events = [] of GameEvent

      if coord.inside?(world)
        if collider
          entity.health = entity.health - COLLISION_DAMAGE
          events << GameEvent::Collision.new(entity, collider, COLLISION_DAMAGE)
        else
          entity.move_to(coord)
          events << GameEvent::Move.new(entity, from, coord)
        end
      else
        entity.health = entity.health - OUT_OF_BOUNDS_DAMAGE
        events << GameEvent::OutOfBounds.new(entity, OUT_OF_BOUNDS_DAMAGE)
      end

      if entity.dead?
        events << GameEvent::Death.new(entity, entity)
      end

      events
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

  class Duck < PlayerAction
    def act(world)
      if entity.is_a? Player
        entity.ducked = true
        [GameEvent::Duck.new(entity)]
      else
        [] of GameEvent
      end
    end
  end

  abstract class AttackAction(T) < PlayerAction
    def attack_with(world, aimed_coords, weapon)
      coords = [] of Coord
      hits = [] of T::Hit
      deaths = [] of GameEvent::Death

      aimed_coords.each do |coord|
        hit_entities = yield(coord)

        if hit_entities.any?
          hit_entity = find_first_hit(hit_entities)
          coords << hit_entity.coord

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

    abstract def find_first_hit(hit_entities)
  end

  abstract class Melee < AttackAction(GameEvent::Melee)
    def attack(world, aimed_coords : Array(Coord))
      if entity.is_a?(Player)
        attack_with(world, aimed_coords, entity.melee_weapon) do |coord|
          world.at(coord)
        end
      else
        [] of GameEvent
      end
    end

    def find_first_hit(hit_entities)
      hit_entities.find { |ent| ent.alive? }
    end
  end

  abstract class Ranged < AttackAction(GameEvent::Ranged)
    def attack(world, aimed_coords : Array(Coord))
      if entity.is_a?(Player)
        attack_with(world, aimed_coords, entity.ranged_weapon) do |coord|
          world.hitscan(@entity.coord, coord)
        end
      else
        [] of GameEvent
      end
    end

    def find_first_hit(hit_entities)
      hit_entities.find do |entity| 
        entity.alive? && (entity.is_a?(Player) && !entity.ducked?)
      end
    end
  end

  class MeleeNorth < Melee
    def act(world)
      return [] of GameEvent unless @entity.is_a?(Player)
      coords = entity.melee_weapon.aim_north(world, @entity.coord)
      attack(world, coords)
    end
  end

  class MeleeEast < Melee
    def act(world)
      return [] of GameEvent unless @entity.is_a?(Player)
      coords = entity.melee_weapon.aim_east(world, @entity.coord)
      attack(world, coords)
    end
  end

  class MeleeSouth < Melee
    def act(world)
      return [] of GameEvent unless @entity.is_a?(Player)
      coords = entity.melee_weapon.aim_south(world, @entity.coord)
      attack(world, coords)
    end
  end

  class MeleeWest < Melee
    def act(world)
      return [] of GameEvent unless @entity.is_a?(Player)
      coords = entity.melee_weapon.aim_west(world, @entity.coord)
      attack(world, coords)
    end
  end

  class RangedNorth < Ranged
    def act(world)
      return [] of GameEvent unless @entity.is_a?(Player)
      attack(world, @entity.ranged_weapon.aim_north(world, @entity.coord))
    end
  end

  class RangedEast < Ranged
    def act(world)
      return [] of GameEvent unless @entity.is_a?(Player)
      attack(world, @entity.ranged_weapon.aim_east(world, @entity.coord))
    end
  end

  class RangedSouth < Ranged
    def act(world)
      return [] of GameEvent unless @entity.is_a?(Player)
      attack(world, @entity.ranged_weapon.aim_south(world, @entity.coord))
    end
  end

  class RangedWest < Ranged
    def act(world)
      if @entity.is_a?(Player)
        attack(world, @entity.ranged_weapon.aim_west(world, @entity.coord))
      else
        [] of GameEvent
      end
    end
  end
end
