require "json"
require "uuid"
require "uuid/json"
require "./coord"
require "./scripts"
require "./actions"

alias ID = UUID

abstract class Entity
  include JSON::Serializable
  include JSON::Serializable::Strict

  property id : ID
  property coord : Coord

  def initialize(@id : ID, @coord)
  end

  abstract def next_action(world : World) : Action
  abstract def to_s

  def move_to(coord : Coord)
    @coord = coord
  end

  def collides_with?(other)
    true
  end
end

class Player < Entity
  @[JSON::Field(ignore: true)]
  property script : Script

  property health : Int32 = 100
  property ducked : Bool = false
  property(melee_weapon) { Sword.new }
  property(ranged_weapon) { Bow.new }

  def initialize(@id, @coord, script, @health = 100, @ducked = false)
    super(@id, @coord)
    if script.is_a?(Script)
      @script = script
    else
      @script = Script.new(script)
    end
  end

  def clone
    Player.new(@id, @coord, @script, health, ducked)
  end

  def next_action(game_state)
    action_class = @script.run(game_state)
    action_class.new(self)
  end
end
