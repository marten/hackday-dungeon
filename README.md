# Hackday dungeon

This is a game engine that lets a bunch of bots battle it out on a world map.

Your job is to write a script that will receive the state of the dungeon, and
output two actions per round. A round basically looks like this:

* Game engine serializes the current dungeon state to JSON
* Game engine calls each script, passing in the state and receiving two actions
  from the script
  * Script reads state from STDIN
  * Insert your AI script here
  * Script puts actions on STDOUT
* Game engine sorts these actions according to execution order rules
* Game engine evaluates the outcome of each of the actions, which results in
  the state for the next round

## Installation

The engine is written in Crystal, a Ruby-like programming language.

```
brew install crystal
cd engine
shards build
```

## Usage

```
./engine/bin/robommo
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here
