require "ANSI"

class TTYRenderer
  include ANSI

  def render(world : World)
    puts "Age: #{world.age}"
    puts

    entities = world.entities

    puts "+" * (world.width + 2)

    (0..(world.height - 1)).each do |y|
      print '+'

      (0..(world.width - 1)).each do |x|
        entity = entities.find { |entity| entity.coord.x == x && entity.coord.y == y }

        if entity
          print entity.to_s
        else
          print " "
        end
      end

      print '+'
      print "\n"
    end

    puts "+" * (world.width + 2)
    puts
    puts
    puts
    puts
    puts
    puts
  end
end
