#!/usr/bin/env ruby
#
require 'json'

input = JSON.parse(STDIN.read)

if input["age"] % 2 == 0
  puts "move_north"
else
  puts "ranged_west"
end
