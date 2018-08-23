require "json"
require "./base_types"

class GameEvent
  def as_json
    {type: "unknown"}
  end

  def to_json(json : JSON::Builder)
    as_json.to_json(json)
  end

  class ProgramError < GameEvent
    def initialize(@entity : Entity)
    end

    def as_json
      {type: "program_error", entity: @entity.id}
    end
  end

  class Spawned < GameEvent
    def initialize(@entity : Entity)
    end

    def as_json
      {type: "spawn", entity: @entity.id, at: @entity.coord}
    end
  end

  class Duck < GameEvent
    def initialize(@entity : Entity)
    end

    def as_json
      {type: "duck", entity: @entity.id}
    end
  end

  class Move < GameEvent
    def initialize(@entity : Entity, @from : Coord, @to : Coord)
    end

    def as_json
      {type: "move", entity: @entity.id, from: @from, to: @to}
    end
  end

  class Collision < GameEvent
    def initialize(@entity : Entity, @collide_with : Entity, @damage : Int32)
    end

    def as_json
      {type: "collision", entity: @entity.id, collide_with: @collide_with.id}
    end
  end

  class OutOfBounds < GameEvent
    def initialize(@entity : Entity, @damage : Int32)
    end

    def as_json
      {type: "out_of_bounds", entity: @entity.id, damage: @damage}
    end
  end

  class Death < GameEvent
    def initialize(@entity : Entity, @killed_by : Entity)
    end

    def as_json
      {type: "death", entity: @entity.id, killed_by: @killed_by.id}
    end
  end

  alias Hit = {entity: ID, damage: Int32}

  class Melee < GameEvent
    def initialize(@entity : Entity, @coords : Array(Coord), @hits : Array(Hit))
    end

    def as_json
      {type: "melee", entity: @entity.id, coords: @coords, hits: @hits}
    end
  end

  class Ranged < GameEvent
    def initialize(@entity : Entity, @coords : Array(Coord), @hits : Array(Hit))
    end

    def as_json
      {type: "ranged", entity: @entity.id, coords: @coords, hits: @hits}
    end
  end
end

