class_name Map
extends Node

const tile_types = Tile.types

var height: int = 0
var width: int = 0
var tiles: Array = []
var level = 0
var num_upstairs = 2
var num_downstairs = 2

func _init(height: int = 10, width: int = 10, num_upstairs = 2, num_downstairs=2, level=0):
	self.height = height
	self.width = width
	self.build_map()
	
func build_map():
	tiles = []
	for j in range(0,width):
		tiles.append([])
	for i in range(0,height):
		for j in range(0, width):
			var type =  tile_types.wall if (GameState.rng_next_int()%12 == 0) else tile_types.floor
			tiles[j].append(Tile.new(j,i,type))
			
func load_level_grid_tiles(level: Array, grid: TileMapLayer):
	for i in range(0, height):
		for j in range(0, width):
			grid.set_cell(Vector2i(j, i), 1, tiles[j][i].texture_coords, 0)
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
