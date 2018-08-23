require "json"
require "./entities"

class Script
  def initialize(cmd : String)
    @cmd = cmd
  end

  def run(state, entity) : Array(Actions::PlayerAction)
    # print "Calling #{@cmd} with #{state.to_json}"
    result = [] of Actions::PlayerAction

    Process.run(@cmd) do |process|
      if !process.terminated?
        process.input.puts(state.to_json)
        process.input.close

        errors = process.error.gets_to_end

        if errors.empty?
          output = process.output.gets_to_end.strip
          # puts " returned #{output.inspect}"
          action = find_action_class(output)
          result << action.new(entity)
        else
          STDERR.puts "Errors: #{errors}"
          result << Actions::ProgramError.new(entity)
        end
      else
        # puts "Process crashed"
        result << Actions::ProgramError.new(entity)
      end
    end

    if result.empty?
      result << Actions::Nothing.new(entity)
    end

    result
  end

  def find_action_class(string)
    case string
    when "nothing"
      Actions::Nothing
    when "move_north"
      Actions::MoveNorth
    when "move_east"
      Actions::MoveEast
    when "move_south"
      Actions::MoveSouth
    when "move_west"
      Actions::MoveWest
    when "duck"
      Actions::Duck
    when "melee_north"
      Actions::MeleeNorth
    when "melee_east"
      Actions::MeleeEast
    when "melee_south"
      Actions::MeleeSouth
    when "melee_west"
      Actions::MeleeWest
    when "ranged_north"
      Actions::RangedNorth
    when "ranged_east"
      Actions::RangedEast
    when "ranged_south"
      Actions::RangedSouth
    when "ranged_west"
      Actions::RangedWest
    else
      Actions::Nothing
    end
  end

end
