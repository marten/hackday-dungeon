all: engine/bin/robommo bots

clean:
	rm engine/bin/robommo
	rm bots/nothing

engine/bin/robommo: engine/**/*
	cd engine && shards build

bots: bots/nothing

bots/nothing: bots/nothing.cr
	crystal bots/nothing.cr
