#!/usr/bin/env ruby

require 'bundler/inline'
require 'json'

gemfile do
  source 'https://rubygems.org'
  gem 'tty-table'
  gem 'tty-cursor'
  gem 'awesome_print'
end

cursor = TTY::Cursor

BOT_SYMBOL = '🤺'.freeze

game = JSON.parse(STDIN.read)

class World
  attr_reader :world
  def initialize(world)
    @world = world
  end

  def width
    world["width"]
  end

  def height
    world["height"]
  end

  def entities
    world["entities"]
  end

  def at(x, y)
    entities.select do |id, ent|
      ent["coord"]['x'] == x and ent['coord']['y'] == y
    end.values
  end
end

def render(ents)
  return " " if ents.size == 0
  BOT_SYMBOL
end

for round in game["rounds"]
  puts "\e[H\e[2J"
  world = World.new(round["initial_world"])
  room = []

  for row in 0..world.height
    room[row] = []

    for col in 0..world.width
      room[row] << render(world.at(col, row))
    end
  end

  table = TTY::Table.new(room)
  puts table.render :basic

  ap round
  sleep 2
end