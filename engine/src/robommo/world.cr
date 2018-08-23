class World
  include JSON::Serializable

  property width : Int32
  property height : Int32
  property entities : Hash(ID, Entity)

  def initialize(@width, @height, @entities = {} of ID => Entity)
  end

  def clone
    World.new(@width, @height, @entities.clone)
  end

  def entities
    @entities.values
  end

  def at(coord)
    entities.select do |entity|
      entity.coord == coord
    end
  end

  def hitscan(from : Coord, to : Coord) : Array(Entity)
    coords = from.to(to)

    coords.flat_map do |coord|
      at(coord)
    end
  end

  def hitscan(coord : Coord, direction : Direction) : Array(Entity)
    coord = coord.neighbour(direction)
    entities = at(coord)

    while coord = coord.neighbour(direction)
      break unless coord.inside?(self)
      entities += at(coord)
    end

    entities
  end

  def spawn(x, y, script)
    id = UUID.random
    coord = Coord.new(x, y)
    @entities[id] = Player.new(id, coord, script)
  end

  def update_entity(entity)
    @entities[entity.id] = entity
  end

  def step
    actions = collect_actions
    world = self

    actions.each do |action|
      world = action.act(world)
    end
  end

  def collect_actions
    actions = [] of Action

    players.each do |player|
      action = player.next_action(self)
      actions << action
    end

    actions
  end

  def players
    players = [] of Player

    entities.each do |entity|
      if entity.is_a?(Player)
        players << entity
      end
    end

    players
  end
end
