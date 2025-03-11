extends Node

signal player_moved(new_position: Vector2i)
signal turn_ended
signal player_damaged(damage: int)
signal new_item(item: Item)
signal player_died()

const DEFAULT_RNG_POS = 0x13371ee7
const TILE_SIZE: int = 32
const tile_types = Tile.types

var disable_fog = false

var hp = 15
var max_hp = 15
var player_position: Vector2 = Vector2(0, 0)
var player_damage = 1
var player_los = 12
var alive = true

var map: Map
var depth: int
var baddies: Array[Baddy] = []
var items: Array[Item] = []
var astar: AStar2D = AStar2D.new()
var pos: int = DEFAULT_RNG_POS
var seedval: int = 0x1ee71337
var rng = load("res://scripts/rng.gd").new()

var turn_active: bool = true
var astar_maps: Array = []  # Array to store AStar2D for each depth

func start_game() -> void:
	"""Initializes the game and prepares pathfinding grids for all depths."""
	depth = 0
	hp = 15
	player_damage = 1
	map = Map.new()
	map.set_depth(0)

	astar_maps.clear()
	for z in range(map.dungeon.size()):
		astar_maps.append(build_pathfinding_grid(z))  # Build AStar for each level

	baddies = new_baddies()
	items = new_items()
	alive = true
	# Find a valid player spawn position
	player_position = get_random_traversable_position()
	for z in range(map.dungeon.size() - 1):  # Ignore last level (no stairs down needed)
		validate_stairs_down(z)

func validate_stairs_down(depth: int) -> void:
	"""Ensures that every map (except the last one) has a `stair_down` tile.
	   - Depth 0: Ensures `stair_down` is reachable from `player_position`
	   - Depth > 0: Ensures `stair_down` is reachable from `stair_up`
	"""
	var stair_down_positions = get_stair_down_positions_for_depth(depth)
	if stair_down_positions.size() > 0:
		return  # Stairs already exist, no need to modify.

	print("No stair_down found in depth", depth, "- Adding one!")

	# Find all traversable floor tiles
	var valid_floor_tiles = []
	for x in range(map.width):
		for y in range(map.height):
			var tile_pos = Vector2(x, y)
			if is_tile_valid(tile_pos) and map.tiles[x][y].traversable:
				valid_floor_tiles.append(tile_pos)

	if valid_floor_tiles.is_empty():
		print("Warning: No valid floor tiles found for stair placement at depth", depth)
		return

	# Determine the reference position for path validation
	var reference_positions = []
	if depth == 0:
		reference_positions.append(player_position)  # First depth must connect to player spawn
	else:
		var stair_up_position = get_stair_up_position_for_depth(depth)
		if stair_up_position != Vector2(-1, -1):  
			reference_positions.append(stair_up_position)  # Other depths connect to `stair_up`

	# Find a reachable floor tile
	var selected_tile = null
	for tile in valid_floor_tiles:
		for ref_pos in reference_positions:
			if is_path_valid_at_depth(ref_pos, tile, depth):
				selected_tile = tile
				break
		if selected_tile:
			break  # Stop once we find a valid tile

	# If no reachable tile was found, just pick any floor tile (fallback)
	if not selected_tile:
		print("Warning: No path to a valid stair position. Assigning randomly.")
		selected_tile = valid_floor_tiles[rng_next_int() % valid_floor_tiles.size()]

	# Convert selected tile into a stair_down
	map.tilemap[depth][int(selected_tile.x)][int(selected_tile.y)].type = Tile.types.stair_down


func get_stair_down_positions_for_depth(depth: int) -> Array:
	"""Returns a list of all stair_down tile positions for a specific depth."""
	var stair_down_positions = []
	for x in range(map.width):
		for y in range(map.height):
			if map.tilemap[depth][x][y].type == Tile.types.stair_down:
				stair_down_positions.append(Vector2(x, y))
	return stair_down_positions

func get_stair_up_position_for_depth(depth: int) -> Vector2:
	"""Finds the position of a `stair_up` tile in a given depth, or returns Vector2(-1, -1) if not found."""
	for x in range(map.width):
		for y in range(map.height):
			if map.tilemap[depth][x][y].type == Tile.types.stair_up:
				return Vector2(x, y)
	return Vector2(-1, -1)  # No stair_up found

func is_path_valid_at_depth(start: Vector2, end: Vector2, depth: int) -> bool:
	"""Checks if there's a valid path from start to end at a given depth."""
	var astar = astar_maps[depth]  # Use AStar for the specific depth
	var start_id = get_astar_id(start)
	var end_id = get_astar_id(end)

	if astar.has_point(start_id) and astar.has_point(end_id):
		var path = astar.get_point_path(start_id, end_id)
		return path.size() > 1

	return false


func get_random_traversable_position() -> Vector2:
	"""Finds a random traversable tile that has a valid path to a stair_down tile."""
	var valid_positions = []
	var stair_down_positions = get_stair_down_positions()

	if stair_down_positions.is_empty():
		print("No stair_down tiles found! Cannot determine valid spawn points.")
		return Vector2(0, 0)  # Default to 0,0 if there's no valid position

	# Collect all valid tiles that can reach at least one stair_down
	for x in range(map.width):
		for y in range(map.height):
			var pos = Vector2(x, y)
			if is_tile_valid(pos) and map.tiles[x][y].traversable and not pos_has_baddy(pos):
				for stair_pos in stair_down_positions:
					if is_path_valid(pos, stair_pos):
						valid_positions.append(pos)
						break  # Stop checking once we find one valid stair connection

	# Pick a random position from the valid list
	if valid_positions.size() > 0:
		return valid_positions[rng_next_int() % valid_positions.size()]
	else:
		print("Warning: No valid spawn positions found.")
		return Vector2(0, 0)  # Default fallback

func get_stair_down_positions() -> Array:
	"""Returns a list of all stair_down tile positions."""
	var stair_down_positions = []
	for x in range(map.width):
		for y in range(map.height):
			if map.tiles[x][y].type == Tile.types.stair_down:
				stair_down_positions.append(Vector2(x, y))
	return stair_down_positions


func new_baddies() -> Array[Baddy]:
	"""Generates baddies efficiently by precomputing valid spawn locations first.
	   - Depth 0-1: Farmers (weak)
	   - Depth 2-3: Farmers, Rogues
	   - Depth 4-5: Farmers, Rogues, Barbarians, Knights
	   - Depth 6: Wizards appear
	   - Depth 7: More aggressive scaling
	   - Depth 8-9: Baddies gain more HP & damage.
	"""

	var baddies: Array[Baddy] = []
	var baddy_factory = BaddyFactory.new()

	# Gather all valid tiles once instead of random-checking multiple times
	var valid_tiles = []
	for x in range(map.width):
		for y in range(map.height):
			var pos = Vector2(x, y)
			if is_tile_valid(pos) and map.tiles[x][y].traversable:
				valid_tiles.append(pos)

	if valid_tiles.is_empty():
		print("Warning: No valid spawn locations for baddies!")
		return baddies

	# Define spawn pool per depth
	var spawn_pool = []
	if depth <= 1:
		spawn_pool = [Baddy.BaddyType.FARMER]
	elif depth <= 3:
		spawn_pool = [Baddy.BaddyType.FARMER, Baddy.BaddyType.ROGUE]
	elif depth <= 5:
		spawn_pool = [Baddy.BaddyType.FARMER, Baddy.BaddyType.ROGUE, Baddy.BaddyType.BARB, Baddy.BaddyType.KNIGHT]
	elif depth == 6:
		spawn_pool = [Baddy.BaddyType.FARMER, Baddy.BaddyType.ROGUE, Baddy.BaddyType.BARB, Baddy.BaddyType.KNIGHT, Baddy.BaddyType.MAGE]
	elif depth == 7:
		spawn_pool = [Baddy.BaddyType.ROGUE, Baddy.BaddyType.BARB, Baddy.BaddyType.KNIGHT, Baddy.BaddyType.MAGE]
	elif depth >= 8:
		spawn_pool = [Baddy.BaddyType.BARB, Baddy.BaddyType.KNIGHT, Baddy.BaddyType.MAGE]

	# Determine number of baddies for depth scaling
	var num_baddies = (12 + depth * 5) + (rng_next_int() % ((depth+1)*8))  # Increasing abundance per level

	# Spawn baddies
	for i in range(num_baddies):
		var baddy_type = spawn_pool[rng_next_int() % spawn_pool.size()]
		var baddy = baddy_factory.new_baddy(baddy_type)
		baddy.grid_position = valid_tiles[rng_next_int() % valid_tiles.size()]

		# **Scaling Difficulty**
		# - Increase HP slightly for each level
		# - Increase Damage at Depth 8 and 9
		baddy.hp += depth  # +1 HP per depth
		if depth >= 8:
			baddy.damage += (depth - 7)  # Damage boost on Depth 8 (+1) and Depth 9 (+2)
			
	# Connect death signals for all baddies
	#for baddy in baddies:
		if not baddy.died.is_connected(_on_baddy_died):
			baddy.died.connect(_on_baddy_died.bind(baddy))

		baddies.append(baddy)

	return baddies

func new_items():
	var items: Array[Item] = []
	var num_items = 5+(map.width*map.height)/50*(depth+1)
	var item_distributions = []
	item_distributions.append({Item.ItemType.BRAZIER_OFF: 10, Item.ItemType.APPLE: 10, Item.ItemType.POTION_BLUE: 5, Item.ItemType.SWORD:5, Item.ItemType.SHIELD_1: 5})
	item_distributions.append({Item.ItemType.BRAZIER_OFF: 10, Item.ItemType.APPLE: 10, Item.ItemType.POTION_BLUE: 5, Item.ItemType.SWORD:5, Item.ItemType.SHIELD_1: 5})
	item_distributions.append({Item.ItemType.BRAZIER_OFF: 10, Item.ItemType.APPLE: 10, Item.ItemType.POTION_BLUE: 5, Item.ItemType.SWORD:5, Item.ItemType.SHIELD_1: 5})
	item_distributions.append({Item.ItemType.BRAZIER_OFF: 10, Item.ItemType.APPLE: 10, Item.ItemType.POTION_BLUE: 5, Item.ItemType.SWORD:5, Item.ItemType.SHIELD_2: 5})
	item_distributions.append({Item.ItemType.BRAZIER_OFF: 10, Item.ItemType.APPLE: 10, Item.ItemType.POTION_BLUE: 5, Item.ItemType.SWORD:5, Item.ItemType.SHIELD_2: 5, Item.ItemType.SHIELD_3: 3})
	item_distributions.append({Item.ItemType.BRAZIER_OFF: 10, Item.ItemType.APPLE: 10, Item.ItemType.POTION_BLUE: 5, Item.ItemType.SWORD:5, Item.ItemType.SHIELD_2: 5, Item.ItemType.SHIELD_3: 3})
	item_distributions.append({Item.ItemType.BRAZIER_OFF: 10, Item.ItemType.APPLE: 10, Item.ItemType.POTION_BLUE: 5, Item.ItemType.SWORD:5, Item.ItemType.SHIELD_2: 5, Item.ItemType.SHIELD_3: 3})
	item_distributions.append({Item.ItemType.BRAZIER_OFF: 10, Item.ItemType.APPLE: 10, Item.ItemType.POTION_BLUE: 5, Item.ItemType.SWORD:5, Item.ItemType.SHIELD_3: 3})
	item_distributions.append({Item.ItemType.BRAZIER_OFF: 10, Item.ItemType.APPLE: 10, Item.ItemType.POTION_BLUE: 5, Item.ItemType.SWORD:5, Item.ItemType.SHIELD_3: 5, Item.ItemType.KEY: 3})

	var distribution_sum = 0
	var item_distribution = item_distributions[depth]
	for item_type in item_distribution.keys():
		distribution_sum += item_distribution[item_type]
	for i in range(0,num_items):
		if distribution_sum > 101:
			continue
		var pos = Vector2(rng_next_int()%map.width,rng_next_int()%map.height)
		if player_can_move_here(pos):
			var item = roll_item(item_distribution)
			item.grid_position=pos
			items.append(item)
			distribution_sum += 1
	
	if depth == 8:
		var pos = Vector2(rng_next_int()%map.width,rng_next_int()%map.height)
		while not player_can_move_here(pos):
			pos = Vector2(rng_next_int()%map.width,rng_next_int()%map.height)
		var item = Item.new()
		item.type = Item.ItemType.KEY
		items.append(item)
	return items
	
func update_depth():
	"""Changes level depth and switches to the appropriate pathfinding grid."""
	astar = astar_maps[depth]  # Switch to the correct AStar2D instance
	rebuild_level_state()  # Rebuild baddies and items for the new level

func rebuild_level_state():
	"""Rebuilds baddies and items when switching levels."""
	baddies.clear()
	items.clear()

	baddies = new_baddies()
	items = new_items()


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


func move_player(direction: Vector2):
	if !turn_active:
		return false

	var new_pos = player_position + direction

	if new_pos.x < 0 or new_pos.x >= map.width or new_pos.y < 0 or new_pos.y >= map.height:
		return false
	if not map.tiles[new_pos.x][new_pos.y].traversable:
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
	emit_signal("player_died")
	alive = false
	pass

func is_tile_valid(pos: Vector2) -> bool:
	""" Check if a tile position is within map bounds """
	return pos.x >= 0 and pos.y >= 0 and pos.x < GameState.map.width and pos.y < GameState.map.height

func get_ai_path(start: Vector2, end: Vector2) -> Array:
	"""Returns the A* path from start to end using the correct pathfinding grid."""
	var astar = astar_maps[depth]  # Get AStar for current depth
	var start_id = get_astar_id(start)
	var end_id = get_astar_id(end)

	if astar.has_point(start_id) and astar.has_point(end_id):
		return astar.get_point_path(start_id, end_id)

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


func build_pathfinding_grid(depth: int) -> AStar2D:
	"""Builds and returns an AStar2D pathfinding grid for a specific level."""
	var astar = AStar2D.new()

	for x in range(map.width):
		for y in range(map.height):
			var tile_pos = Vector2i(x, y)
			if map.tilemap[depth][x][y].traversable:
				var id = get_astar_id(tile_pos)
				astar.add_point(id, tile_pos)

	for x in range(map.width):
		for y in range(map.height):
			var tile_pos = Vector2i(x, y)
			var id = get_astar_id(tile_pos)

			if astar.has_point(id):
				for neighbor in get_neighbors(tile_pos):
					var neighbor_id = get_astar_id(neighbor)
					if astar.has_point(neighbor_id):
						astar.connect_points(id, neighbor_id)

	return astar


func validate_traversable_tiles(stair_down_positions: Array[Vector2]):
	""" Marks any traversable tile as non-traversable if it has no valid path to a `stair_down` tile. """
	if stair_down_positions.is_empty():
		print("No stair_down tiles found! Skipping path validation.")
		return

	for x in range(map.width):
		for y in range(map.height):
			var tile_pos = Vector2(x, y)
			var tile = map.tiles[x][y]

			if not tile.traversable:
				continue  # Skip already non-traversable tiles

			# Check if there's a valid path to any `stair_down`
			var reachable = false
			for stair_pos in stair_down_positions:
				if is_path_valid(tile_pos, stair_pos):
					reachable = true
					break

			# If no valid path was found, mark tile as non-traversable
			if not reachable:
				tile.traversable = false
				print("Marking tile as non-traversable:", tile_pos)

func is_path_valid(start: Vector2, end: Vector2) -> bool:
	"""Checks if there's a valid path from start to end using A* pathfinding."""
	var astar = astar_maps[depth]  # Use the correct AStar instance for the current depth
	var start_id = get_astar_id(start)
	var end_id = get_astar_id(end)

	if astar.has_point(start_id) and astar.has_point(end_id):
		var path = astar.get_point_path(start_id, end_id)
		return path.size() > 1

	return false




func get_astar_id(tile_pos: Vector2i) -> int:
	return tile_pos.x * 1000 + tile_pos.y  # Unique ID for each tile

func get_neighbors(tile_pos: Vector2i) -> Array:
	return [
		tile_pos + Vector2i(1, 0),  # Right
		tile_pos + Vector2i(-1, 0), # Left
		tile_pos + Vector2i(0, 1),  # Down
		tile_pos + Vector2i(0, -1)  # Up
	]
