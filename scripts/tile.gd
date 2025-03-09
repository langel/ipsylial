class_name Tile
extends Node

enum types {
	acid,
	door,
	floor,
	forrest,
	stair_down,
	stair_up,
	wall,
	water,
}

var x: int = 0
var y: int = 0
var obfuscate: float = 0.0
var texture_coords: Vector2i
var traversable: bool = false
var type: types = types.floor  # Default type

func _init(x: int, y: int, type: types = types.floor):
	self.x = x
	self.y = y
	self.type = type
	var coords = [0,6]
	match type:
		types.acid:
			coords = [GameState.rng_next_int()%11, 27]
			self.obfuscate = 0.5
		types.door:
			coords = [3,16]
			self.traversable = true
			# closed = [2,16]
		types.floor:
			self.traversable = true
			var roll = GameState.rng_next_int() % 30
			match roll:
				9:
					coords = [1,6]
				8:
					coords = [2,6]
				7:
					coords = [3,6]
				6:
					coords = [1,7]
				5:
					coords = [2,7]
				4:
					coords = [3,7]
		types.forrest:
			self.obfuscate = 0.2
			coords = [1 + GameState.rng_next_int() % 2, 25]
		types.stair_down:
			self.traversable = true
			coords = [7,16]
		types.stair_up:
			self.traversable = true
			coords = [8,16]
		types.wall:
			self.obfuscate = 1.0
			var roll = GameState.rng_next_int() % 6
			coords = [0, roll]
		types.water:
			self.obfuscate = 0
			coords = [GameState.rng_next_int()%11, 26]
	self.texture_coords = Vector2i(coords[0],coords[1])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
