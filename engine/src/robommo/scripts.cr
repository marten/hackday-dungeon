require "json"
require "./entities"

class Script
  def initialize(cmd : String)
    @cmd = cmd
  end

  def run(state, entity) : Array(Action)
    # print "Calling #{@cmd} with #{state.to_json}"
    result = [] of Action

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
          result << Action::ProgramError.new(entity)
        end
      else
        # puts "Process crashed"
        result << Action::ProgramError.new(entity)
      end
    end

    if result.empty?
      result << Action::Nothing.new(entity)
    end

    result
  end

  def find_action_class(string)
    case string
    when "nothing"
      Action::Nothing
    when "move_north"
      Action::MoveNorth
    when "move_east"
      Action::MoveEast
    when "move_south"
      Action::MoveSouth
    when "move_west"
      Action::MoveWest
    when "duck"
      Action::Duck
    when "melee_north"
      Action::MeleeNorth
    when "melee_east"
      Action::MeleeEast
    when "melee_south"
      Action::MeleeSouth
    when "melee_west"
      Action::MeleeWest
    when "ranged_north"
      Action::RangedNorth
    when "ranged_east"
      Action::RangedEast
    when "ranged_south"
      Action::RangedSouth
    when "ranged_west"
      Action::RangedWest
    else
      Action::Nothing
    end
  end

end
