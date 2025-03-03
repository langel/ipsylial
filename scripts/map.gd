class_name Map
extends Node

var height: int = 0
var width: int = 0
var tiles: Array = []


func _init(height: int = 10, width: int = 10):
	self.height = height
	self.width = width
	self.build_map()
	
func build_map():
	tiles = []
	for j in range(0,width):
		tiles.append([])
	for i in range(0,height):
		for j in range(0, width):
			var type =  Tile.TileType.AIR if (GameState.rng_next_int()%5 == 0) else Tile.TileType.FLOOR
			tiles[j].append(Tile.new(j,i,type))
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
