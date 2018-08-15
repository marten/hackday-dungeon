#!/usr/bin/env ruby
#
require "json"
require "random"

class Entity
  JSON.mapping(
    id: String
  )
end

class World
  JSON.mapping(
    entities: Hash(String, Entity)
  )
end

world = World.from_json(STDIN)

r = Random.new

if r.next_bool
  puts "move_north"
else
  puts "ranged_west"
end
