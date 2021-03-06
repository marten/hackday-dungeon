#!/usr/bin/env ruby
# coding: utf-8

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

game = JSON.parse(ARGF.read)

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
    world["entities"].transform_values {|entity| Entity.new(entity) }
  end

  def entity(id)
    entities[id]
  end

  def at(x, y)
    world['entities'].select do |id, ent|
      ent["coord"]['x'] == x and ent['coord']['y'] == y
    end.values
  end
end

class Entity
  def initialize(data)
    @data = data
  end

  def row_col
    return [@data['coord']['y'], @data['coord']['x']]
  end
end

class Round
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def initial_world
    World.new @data['initial_world']
  end

  def number
    @data['number']
  end

  def events
    @data['events'].map {|event| Event.new(self, event) }
  end

  def entity(id)
    initial_world.entity(id)
  end
end

class Event
  attr_reader :round, :data

  def initialize(round, data)
    @round = round
    @data = data
  end

  def [](key)
    @data[key]
  end

  def type
    @data['type']
  end

  def entity
    round.entity(@data['entity'])
  end
end

def render(ents)
  return "  " if ents.size == 0

  case ents.first['what']
  when 'Player'
    BOT_SYMBOL
  when 'Wall'
    "XX"
  end
end

for round_data in game["rounds"]
  round = Round.new(round_data)
  world = round.initial_world
  room = []

  for row in 0..world.height
    room[row] = []

    for col in 0..world.width
      room[row] << render(world.at(col, row))
    end
  end


  table = TTY::Table.new(room)
  puts "\e[H\e[2J"
  puts "Round: #{round.number}, initial state"
  puts table.render :unicode
  sleep 2

  round.events.each_with_index do |event, idx|
    begin
      puts "\e[H\e[2J"
      puts "Round: #{round.number}, event: #{idx}"

      case event.type
      when 'spawn'
        row, col = event['at']['y'], event['at']['x']
        table[row][col] = 'XX'
      when 'ranged'
        row, col = event.entity.row_col
        table[row][col] = '🏹'
      end

      puts table.render :unicode
      ap event.data
      sleep 2
    rescue
      ap event
      raise
    end
  end
end
