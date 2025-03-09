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
var traversable: bool = true
var type: types = types.floor  # Default type

func _init(x: int, y: int, type: types = types.floor):
	self.x = x
	self.y = y
	self.type = type
	if type != types.floor:
		traversable = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
