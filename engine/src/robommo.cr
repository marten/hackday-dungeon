require "./robommo/*"
require "json"
require "uuid"

world = World.new(50, 10)
world.spawn(1, 1, "bin/bot-nothing")
world.spawn(3, 1, "bin/bot-nothing")
world.spawn(5, 1, "bin/bot-nothing")
world.spawn(7, 1, "bin/bot-nothing")
world.spawn(9, 1, "bin/bot-nothing")
world.spawn(25, 5, "bin/bot-simple")

renderer = TTYRenderer.new

renderer.render(world)

20.times do
  world = world.step
  renderer.render(world)
end
