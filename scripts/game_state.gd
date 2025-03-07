extends Node

signal player_moved(new_position: Vector2i)
signal turn_ended
signal player_damaged

const DEFAULT_RNG_POS = 0x13371ee7
const TILE_SIZE: int = 32

var disable_fog = false

var hp = 15
var player_position: Vector2 = Vector2(0, 0)
var player_damage = 1

var map: Map
var baddies: Array[Baddy] = []
var items: Array[Item] = []
var astar: AStar2D = AStar2D.new()
var pos: int = DEFAULT_RNG_POS
var seedval: int = 0x1ee71337
var rng = load("res://scripts/rng.gd").new()

var turn_active: bool = true

func start_game() -> void:
	player_position = Vector2i(0, 0)
	hp = 15
	map = new_map()
	build_pathfinding_grid()
	baddies = new_baddies()
	# Connect death signals for all baddies	
	for baddy in baddies:
		if not baddy.died.is_connected(_on_baddy_died):
			baddy.died.connect(_on_baddy_died.bind(baddy))

func new_baddies():
	var baddies: Array[Baddy] = []
	var baddy_factory = BaddyFactory.new()
	var num_baddies = 5 + rng_next_int()%10
	for i in range(0,num_baddies):
		var baddy: Baddy = baddy_factory.new_baddy(baddy_factory.get_random_baddy_type())
		baddy.grid_position = Vector2(rng_next_int()%map.width,rng_next_int()%map.height)
		baddies.append(baddy)
	for i in Baddy.BaddyType.values():
		for j in range(0,5):
			var baddy: Baddy = baddy_factory.new_baddy(i)
			baddy.grid_position = Vector2(rng_next_int()%map.width,rng_next_int()%map.height)
			baddies.append(baddy)
		
		
	return baddies
	
func _on_baddy_died(baddy: Baddy):
	""" Removes a dead baddy from the baddies list. """
	if baddy in baddies:
		baddies.erase(baddy)


func rng_next_int() -> int:
	pos += 1
	return rng.rng(pos, seedval)

func new_map() -> Map:
	return Map.new(128, 256)

func move_player(direction: Vector2):
	if !turn_active:
		return false

	var new_pos = player_position + direction

	if new_pos.x < 0 or new_pos.x >= map.width or new_pos.y < 0 or new_pos.y >= map.height:
		return false
	if map.tiles[new_pos.x][new_pos.y].type != Tile.TileType.FLOOR:
		return false
	if !player_can_move_here(new_pos):
		return false

	player_position = new_pos
	player_moved.emit(new_pos)
	return true


func pos_has_baddy(position: Vector2):
	for baddy in baddies:
		if baddy.grid_position == position:
			return true			
	return false

func end_turn():
	turn_active = false
	turn_ended.emit()

func attack_player(baddy: Baddy):
	emit_signal("player_damaged")
	hp -= baddy.damage
	if hp <= 0:
		die()
	pass

func die():
	pass

func get_ai_path(start: Vector2, end: Vector2) -> Array:
	var start_id = get_astar_id(start)
	var end_id = get_astar_id(end)

	if astar.has_point(start_id) and astar.has_point(end_id):
		var path = astar.get_point_path(start_id, end_id)
		return path

	return []

# pathfinding
func baddy_can_move_here(baddy_pos):
	if baddy_pos.x >= map.width or baddy_pos.y >= map.height or baddy_pos.x < 0 or baddy_pos.y < 0:
		return false
	if not map.tiles[baddy_pos.x][baddy_pos.y].traversable:
		return false
	for baddy in baddies:
		if baddy.grid_position == baddy_pos and baddy.is_alive():
			return false
	if player_position == baddy_pos:
		return false
	return true

func player_can_move_here(baddy_pos):
	if not map.tiles[baddy_pos.x][baddy_pos.y].traversable:
		return false
	for baddy in baddies:
		if baddy.grid_position == baddy_pos and baddy.is_alive():
			return false
	if player_position == baddy_pos:
		return false
	return true


func build_pathfinding_grid():
	astar.clear()

	for x in range(map.width):
		for y in range(map.height):
			var tile_pos = Vector2i(x, y)
			var tile_id = map.tiles[x][y].type

			# Only add walkable tiles (FLOOR)
			if tile_id == Tile.TileType.FLOOR:
				var id = get_astar_id(tile_pos)
				astar.add_point(id, tile_pos)

	# Connect neighboring tiles to form a graph
	for x in range(map.width):
		for y in range(map.height):
			var tile_pos = Vector2i(x, y)
			var id = get_astar_id(tile_pos)

			if astar.has_point(id):
				for neighbor in get_neighbors(tile_pos):
					var neighbor_id = get_astar_id(neighbor)
					if astar.has_point(neighbor_id):
						astar.connect_points(id, neighbor_id)

func get_astar_id(tile_pos: Vector2i) -> int:
	return tile_pos.x * 1000 + tile_pos.y  # Unique ID for each tile

func get_neighbors(tile_pos: Vector2i) -> Array:
	return [
		tile_pos + Vector2i(1, 0),  # Right
		tile_pos + Vector2i(-1, 0), # Left
		tile_pos + Vector2i(0, 1),  # Down
		tile_pos + Vector2i(0, -1)  # Up
	]
