#!/usr/bin/env node
/*
Hackday Dungeon - JS Bot
------------------------

Sample bot script for the Zooniverse Hackday Dungeon. This script reads a JSON
file from stdin, figures out a course of action for the player's bot based on
the state of the game world, and tells the game engine its choice of actions.

Input: game state (JSON string, stdin)
Output: bot commands (string, stdout)

See project wiki for full documentation.

********************************************************************************
 */

//Game logic.
//----------------------------------------------------------------
function calculateActions(gameStateJson) {
  //TODO: Do something!
  return 'nothing nothing';
}
//----------------------------------------------------------------

//Simple file reader.
//----------------------------------------------------------------
var inputData = '';
var readline = require('readline');
var rlInterface = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false  //Prevents input from being echoed to the terminal.
});

rlInterface.on('line', (inputLine) => { inputData += inputLine + '\r\n' });
rlInterface.on('close', () => {
  try {
    var actions = calculateActions(JSON.parse(inputData));
    process.stdout.write(actions + '\r\n');
  } catch (err) {
    process.stdout.write('error\r\n');
  }
});
//----------------------------------------------------------------
