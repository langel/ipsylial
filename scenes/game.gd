extends Node


@onready var ground_tile_map = $Grid/Ground

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Clearing tilemap on load...")
	ground_tile_map.clear()  # Ensures no lingering tiles exist
	fill_map_tiles()
	pass # Replace with function body.

func get_random_floor_tile():
	var coords = [0,6]
	var roll = GameState.rng_next_int()%30
	if roll == 9:
		coords = [1,6]
	elif roll == 8:
		coords = [2,6]
	elif roll == 7:
		coords = [3,6]
	elif roll == 6:
		coords = [1,7]
	elif roll == 5:
		coords = [2,7]
	elif roll == 4:
		coords = [3,7]
	return Vector2i(coords[0],coords[1])

func fill_map_tiles():
	for i in range(0,GameState.map.height):
		for j in range(0,GameState.map.width):
			var texture_coords = Vector2i(0,8) #transparent
			if (GameState.map.tiles[j][i].type == Tile.TileType.FLOOR):
				texture_coords = get_random_floor_tile()
			ground_tile_map.set_cell(Vector2i(j,i), 1, texture_coords, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
