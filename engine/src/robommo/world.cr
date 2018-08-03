class World
  include JSON::Serializable

  property width : Int32
  property height : Int32
  property age : Int32
  property entities : Hash(UUID, Entity)

  def initialize(@width, @height, @age = 0, @entities = {} of UUID => Entity)
  end

  def entities
    @entities.values
  end

  def at(coord)
    entities.select do |entity|
      entity.coord == coord
    end
  end

  def hitscan(coord : Coord, direction : Direction)
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
    next_entities = @entities.dup
    next_entities[entity.id] = entity
    World.new(@width, @height, @age, next_entities)
  end

  def increase_age
    World.new(@width, @height, @age + 1, @entities)
  end

  def step
    actions = collect_actions
    world = self

    actions.each do |action|
      world = action.act(world)
    end

    world.increase_age
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
