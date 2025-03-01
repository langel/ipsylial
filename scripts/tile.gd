class_name Tile
extends Node

var x: int = 0
var y: int = 0
var traversable: bool = true
enum TileType { FLOOR, AIR, WALL }
var type: TileType = TileType.FLOOR  # Default type

func _init(x: int, y: int, type: TileType = TileType.FLOOR):
	self.x = x
	self.y = y
	self.type = type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
