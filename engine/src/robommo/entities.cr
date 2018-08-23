require "json"
require "uuid"
require "uuid/json"
require "./base_types"
require "./coord"
require "./scripts"
require "./actions"
require "./melee_weapons"
require "./ranged_weapons"

abstract class Entity
  include JSON::Serializable
  include JSON::Serializable::Strict

  property id : ID
  property coord : Coord
  property what : String

  def initialize(@id : ID, @coord : Coord)
    @what = self.class.to_s
  end

  abstract def next_actions(world : World) : Array(Action)

  def move_to(coord : Coord)
    @coord = coord
  end

  def collides_with?(other)
    true
  end

  def alive?
    !dead?
  end

  def dead?
    true
  end
end

class Wall < Entity
  def next_actions(world)
    [] of Actions::Base
  end

  def clone
    self.class.new(id, coord)
  end
end

# Kills anything that steps on it
class PitOfDoom
end

# Restores health
class BlockOfCheese
end

class Player < Entity
  @[JSON::Field(ignore: true)]
  property script : Script

  property health : Int32 = 100
  property ducked : Bool = false

  @melee_weapon : MeleeWeapon
  @ranged_weapon : RangedWeapon

  def initialize(@id, @coord, script, @health = 100, @ducked = false)
    super(@id, @coord)
    @melee_weapon = Sword.new
    @ranged_weapon = Bow.new
    if script.is_a?(Script)
      @script = script
    else
      @script = Script.new(script)
    end
  end

  def melee_weapon
    @melee_weapon
  end

  def ranged_weapon
    @ranged_weapon
  end

  def collides_with?(other)
    if other.is_a?(Player)
      other.alive?
    else
      true
    end
  end

  def dead?
    @health <= 0
  end

  def ducked?
    @ducked
  end

  def clone
    Player.new(@id, @coord, @script, health, ducked)
  end

  def next_actions(world) : Array(Actions::PlayerAction)
    return [] of Actions::PlayerAction if dead?

    @script.run(world, self)
  end
end
