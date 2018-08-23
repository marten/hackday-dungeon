require "./robommo/*"
require "json"
require "uuid"

class GameEngine
  def initialize(@match : Match)
  end

  def simulate(number_of_rounds : Int32)
    world = @match.map.to_world
    round = Round.new(0, world)
    @match.players.each do |player|
      action = Action::Spawn.new(player)
      round.process_action(action)
    end
    @match.add_round(round)

    number_of_rounds.times do
      round = round.next_round
      actions = round.entities.map { |entity| entity.next_action(round.initial_world) }
      actions = sort(actions)
      actions.each do |action|
        round.process_action(action)
      end
      @match.add_round(round)
    end
  end

  def sort(actions)
    actions
  end
end

class Map
  def initialize(@width : Int32, @height : Int32)
  end

  def to_world
    World.new(@width, @height)
  end
end

class Match
  include JSON::Serializable

  @[JSON::Field(ignore: true)]
  property map : Map
  @[JSON::Field(ignore: true)]
  property players : Array(Player)
  property rounds : Array(Round)

  def initialize(@map, @players)
    @rounds = [] of Round
  end

  def start
    world = map.to_world
    players.each do |player|
      world.update_entity(player)
    end
    world
  end

  def add_round(round)
    @rounds << round
  end
end

class Round
  include JSON::Serializable

  property initial_world : World
  property number : Int32
  property events : Array(GameEvent)
  property world : World

  def initialize(@number, world)
    @initial_world = world.clone
    @world = world.clone
    @events = [] of GameEvent
  end

  def entities
    @world.entities
  end

  def process_action(action : Action)
    new_events = action.act(@world)
    @events.concat(new_events)
  end

  def next_round
    Round.new(@number + 1, @world.clone)
  end

  def final_world
    @world.clone
  end
end

class PlayerConfig
  property scriptname : String

  def initialize(@scriptname)
  end
end

map = Map.new(10, 10)

players = [
  Player.new(UUID.random, Coord.new(2, 2), "../bots/nothing"),
  Player.new(UUID.random, Coord.new(2, 4), "../bots/nothing"),
  Player.new(UUID.random, Coord.new(7, 3), "../bots/simple")
]

match = Match.new(map, players)

engine = GameEngine.new(match)
engine.simulate(20)

puts
puts match.to_json
