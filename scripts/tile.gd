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
var texture_coords: Vector2i
var traversable: bool = true
var type: types = types.floor  # Default type

func _init(x: int, y: int, type: types = types.floor):
	self.x = x
	self.y = y
	self.type = type
	if type != types.floor:
		traversable = false
	var coords = [0,6]
	match type:
		types.floor:
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
		types.wall:
			var roll = GameState.rng_next_int() % 6
			coords = [0, roll]
	self.texture_coords = Vector2i(coords[0],coords[1])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
