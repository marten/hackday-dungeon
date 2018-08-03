#!/usr/bin/env ruby
#
require "json"


class Entity
  JSON.mapping(
    id: String
  )
end

class World
  JSON.mapping(
    age: Int32,
    entities: Hash(String, Entity)
  )
end

world = World.from_json(STDIN)

if world.age % 2 == 0
  puts "move_north"
else
  puts "ranged_west"
end
