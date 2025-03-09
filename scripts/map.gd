class_name Map
extends Node

const tile_types = Tile.types

var height: int = 0
var width: int = 0
var depth: int = 0
var dungeon: Array = []
var tiles: Array = []
var tilemap: Array = []

func _init(height: int = 10, width: int = 10, num_upstairs = 2, num_downstairs=2, level=0):
	var dung = Dungeon.new()
	self.height = dung.height
	self.width = dung.width
	self.dungeon = dung.gen_terrain(dung.gen_empty_map())
	for z in dung.depth:
		self.tilemap.append([])
		for x in self.width:
			self.tilemap[z].append([])
			for y in self.height:
				self.tilemap[z][x].append(Tile.new(x, y, self.dungeon[z][x][y]))
				
			
	
func set_depth(depth: int):
	self.depth = depth
	self.tiles = self.tilemap[self.depth]
			
func load_level_grid_tiles(depth: int, grid: TileMapLayer):
	self.set_depth(depth)
	grid.clear()
	for i in range(0, height):
		for j in range(0, width):
			grid.set_cell(Vector2i(j, i), 1, self.tiles[j][i].texture_coords, 0)
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
