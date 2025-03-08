extends Node

signal player_moved(new_position: Vector2i)
signal turn_ended
signal player_damaged(damage: int)
signal new_item(item: Item)

const DEFAULT_RNG_POS = 0x13371ee7
const TILE_SIZE: int = 32

var disable_fog = false

var hp = 15
var max_hp = 15
var player_position: Vector2 = Vector2(0, 0)
var player_damage = 1
var player_los = 12

var map: Map
var baddies: Array[Baddy] = []
var items: Array[Item] = []
var astar: AStar2D = AStar2D.new()
var pos: int = DEFAULT_RNG_POS
var seedval: int = 0x1ee71337
var rng = load("res://scripts/rng.gd").new()

var turn_active: bool = true

func start_game() -> void:
	"""Initializes the game and places the player on a traversable tile."""
	hp = 15
	player_damage = 1
	map = new_map()
	build_pathfinding_grid()
	baddies = new_baddies()
	items = new_items()

	# Find a valid player spawn position
	player_position = get_random_traversable_position()
	#player_position = Vector2(1,1)

	# Connect death signals for all baddies	
	for baddy in baddies:
		if not baddy.died.is_connected(_on_baddy_died):
			baddy.died.connect(_on_baddy_died.bind(baddy))
	

func get_random_traversable_position() -> Vector2:
	"""Finds a random traversable tile for the player to spawn."""
	while true:
		var x = rng_next_int() % map.width
		var y = rng_next_int() % map.height
		var pos = Vector2(x, y)

		# Ensure the tile is walkable and doesn't contain a baddy
		if is_tile_valid(pos) and map.tiles[x][y].traversable and not pos_has_baddy(pos):
			return pos  # Found a valid position
	return Vector2(0,0)


func new_baddies():
	var baddies: Array[Baddy] = []
	var baddy_factory = BaddyFactory.new()
	var num_baddies = 105 + rng_next_int()%10
	for i in range(0,num_baddies):
		var baddy: Baddy = baddy_factory.new_baddy(baddy_factory.get_random_baddy_type())
		baddy.grid_position = Vector2(rng_next_int()%map.width,rng_next_int()%map.height)
		baddies.append(baddy)
	for i in Baddy.BaddyType.values():
		for j in range(0,25):
			var baddy: Baddy = baddy_factory.new_baddy(i)
			baddy.grid_position = Vector2(rng_next_int()%map.width,rng_next_int()%map.height)
			baddies.append(baddy)
		
		
	return baddies

func new_items():
	var items: Array[Item] = []
	var num_items = 5+(map.width*map.height)/36
	var item_distribution = {Item.ItemType.BRAZIER_OFF: 10, Item.ItemType.APPLE: 10, Item.ItemType.POTION_BLUE: 5, Item.ItemType.SWORD:5, Item.ItemType.SHIELD_1: 5, Item.ItemType.SHIELD_2: 3, Item.ItemType.SHIELD_3: 1}
	var distribution_sum = 0
	for item_type in item_distribution.keys():
		distribution_sum += item_distribution[item_type]
	for i in range(0,num_items):
		var pos = Vector2(rng_next_int()%map.width,rng_next_int()%map.height)
		if player_can_move_here(pos):
			var item = roll_item(item_distribution)
			item.grid_position=pos
			items.append(item)
	return items

func roll_item(item_distribution):
	var distribution_sum = 0
	var item = Item.new()
	for item_type in item_distribution.keys():
		distribution_sum += item_distribution[item_type]
	var item_roll = GameState.rng_next_int()%distribution_sum
	var roll_sum = 0
	for item_type in item_distribution.keys():
		roll_sum += item_distribution[item_type]
		if item_roll < roll_sum:
			item.type = item_type
			break
	match item.type:
		Item.ItemType.BRAZIER_OFF:
			pass
		Item.ItemType.APPLE:
			pass
		Item.ItemType.POTION_BLUE:
			pass
		Item.ItemType.SWORD:
			item.for_baddies = true
			pass
		Item.ItemType.SHIELD_1:
			item.for_baddies = true
			pass
		Item.ItemType.SHIELD_2:
			item.for_baddies = true
			pass
	return item

func _on_baddy_died(baddy: Baddy):
	""" Removes a dead baddy from the baddies list. """
	if baddy in baddies:
		baddies.erase(baddy)
	
	#roll for a drop
	if GameState.rng_next_int()%4 >= 0:
		var item = Item.new()
		item.grid_position = baddy.grid_position
		item.type = Item.ItemType.APPLE if GameState.rng_next_int()%2 > 0 else Item.ItemType.POTION_BLUE if GameState.rng_next_int()%2 > 0 else Item.ItemType.SWORD
		items.append(item)
		emit_signal("new_item",item)


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
	emit_signal("player_damaged",baddy.damage)
	hp -= baddy.damage
	if hp <= 0:
		die()
	pass

func die():
	pass

func is_tile_valid(pos: Vector2) -> bool:
	""" Check if a tile position is within map bounds """
	return pos.x >= 0 and pos.y >= 0 and pos.x < GameState.map.width and pos.y < GameState.map.height

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
	for item in items:
		if item.grid_position == baddy_pos and not item.traversable:
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
	for item in items:
		if item.grid_position == baddy_pos and not item.traversable:
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
