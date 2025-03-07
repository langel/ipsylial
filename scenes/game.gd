extends Node

@onready var ground_tile_map = $Grid/Ground
@onready var entity_layer = $EntityLayer
@onready var player = $EntityLayer/Player
@onready var fog_layer = $Grid/FogOfWar  # Layer for fog effect

var turn = 0
const BADDY_SCENE = preload("res://scenes/baddy.tscn")
const LOS_RANGE = 12  # Max line of sight range

func _ready() -> void:
	GameState.start_game()
	print("Clearing tilemap on load...")
	ground_tile_map.clear()
	fill_map_tiles()
	_on_player_moved(GameState.player_position)
	GameState.player_moved.connect(_on_player_moved)
	GameState.turn_ended.connect(_on_turn_ended)

	spawn_baddies()
	initialize_fog_layer()

	# Bind update_zoom event from Camera2D
	$Camera2D.connect("update_zoom", Callable(self, "_on_update_zoom"))

func _on_update_zoom():
	"""Recalculate fog layer visibility when zoom level changes."""
	update_los()

func _input(event):
	if !GameState.turn_active:
		return  

	var move_dir = Vector2i.ZERO

	if Input.is_action_just_pressed("move_right"):
		move_dir = Vector2i(1, 0)
	elif Input.is_action_just_pressed("move_left"):
		move_dir = Vector2i(-1, 0)
	elif Input.is_action_just_pressed("move_down"):
		move_dir = Vector2i(0, 1)
	elif Input.is_action_just_pressed("move_up"):
		move_dir = Vector2i(0, -1)
	elif Input.is_action_just_pressed("escape"):
		GameState.disable_fog = not GameState.disable_fog
		update_los()

	if move_dir != Vector2i.ZERO:
		move_player(move_dir)

func _on_player_moved(new_position: Vector2i):
	player.position = new_position * GameState.TILE_SIZE + Vector2i(GameState.TILE_SIZE / 2, GameState.TILE_SIZE / 2)
	update_los()

func move_player(move_dir: Vector2):
	var moved = GameState.move_player(move_dir)
	var destination = GameState.player_position + move_dir
	if not moved:
		if GameState.pos_has_baddy(destination):
			attack_baddy(destination)
		else:
			return
	GameState.end_turn()

func attack_baddy(destination):
	var found_baddy: Baddy = null
	for baddy in GameState.baddies:
		if baddy.grid_position == destination:
			found_baddy = baddy
			break
	if found_baddy == null:
		return

	# Play attack animation before applying damage
	await animate_attack(destination)

	# Apply damage after animation
	found_baddy.take_damage(GameState.player_damage)

func animate_attack(target_pos: Vector2) -> void:
	var original_position = player.position
	var direction = (target_pos - GameState.player_position).normalized() * 4  # Small push in direction of attack

	# Create animation
	var tween = create_tween()
	tween.tween_property(player, "position", original_position + direction, 0.08).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(player, "scale", Vector2(1.2, 1.2), 0.08).set_trans(Tween.TRANS_ELASTIC)

	tween.tween_property(player, "position", original_position, 0.08).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(player, "scale", Vector2(1, 1), 0.08).set_trans(Tween.TRANS_ELASTIC)

	# Wait for animation to complete
	await tween.finished



func _on_turn_ended():
	drawScore()
	turn += 1
	await run_ai_turn()
	update_los()
	GameState.turn_active = true  
	drawScore()

func run_ai_turn():
	for baddy in GameState.baddies:
		if not baddy.is_alive():
			continue
		baddy.take_turn()
		baddy.scene.position = (baddy.grid_position * GameState.TILE_SIZE)
		baddy.scene.update_state()
	pass
	await get_tree().create_timer(0.01).timeout

func drawScore():
	var game_status_scene = $CanvasLayer/GameStatus

	game_status_scene.display_hp = GameState.hp
	game_status_scene.display_turn = turn
	game_status_scene.display_floor = 1
	game_status_scene.update_labels()

func spawn_baddies():
	for baddy in GameState.baddies:
		var baddy_instance = BADDY_SCENE.instantiate()
		baddy_instance.update_baddy(baddy)
		baddy_instance.position = (baddy.grid_position * GameState.TILE_SIZE)
		entity_layer.add_child(baddy_instance)

func get_random_floor_tile():
	var coords = [0,6]
	var roll = GameState.rng_next_int() % 30
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
	for i in range(0, GameState.map.height):
		for j in range(0, GameState.map.width):
			var texture_coords = Vector2i(0,8)
			if (GameState.map.tiles[j][i].type == Tile.TileType.FLOOR):
				texture_coords = get_random_floor_tile()
			ground_tile_map.set_cell(Vector2i(j, i), 1, texture_coords, 0)

# ----------------------------
# LINE OF SIGHT (LOS) SYSTEM
# ----------------------------

func initialize_fog_layer():
	""" Create fog overlay for each tile """
	# Remove any existing fog tiles before reinitializing
	for child in fog_layer.get_children():
		fog_layer.remove_child(child)
		child.queue_free()

	# Create a fog tile (ColorRect) for each tile in the grid
	for i in range(GameState.map.height):
		for j in range(GameState.map.width):
			var rect = ColorRect.new()
			rect.size = Vector2(GameState.TILE_SIZE, GameState.TILE_SIZE)
			rect.color = Color(0, 0, 0, 0.8)  # Semi-transparent black fog
			rect.position = Vector2(j, i) * GameState.TILE_SIZE
			fog_layer.add_child(rect)

	# Update the fog layer to reveal initial LOS
	update_los()


func update_los():
	"""Optimized visibility update based on player's line of sight and camera culling."""

	if GameState.disable_fog:
		fog_layer.visible = false
		for baddy in GameState.baddies:
			if baddy.scene != null:
				baddy.scene.visible = true 
		return

	fog_layer.visible = true  # Ensure fog layer is visible

	# Get properly scaled camera bounds
	var camera_rect = get_camera_bounds().grow(10*GameState.TILE_SIZE)
	print("Camera rect is " + str(camera_rect))
	# Get visible tiles within LOS range
	var visible_tiles = get_tiles_in_los()
	var los_area = Rect2(GameState.player_position - Vector2(LOS_RANGE, LOS_RANGE), Vector2(LOS_RANGE * 2, LOS_RANGE * 2))

	# Update fog tiles (considering zoom)
	for fog_rect in fog_layer.get_children():
		var tile_pos = fog_rect.position / GameState.TILE_SIZE

		# Fog should render if it's within the corrected camera bounds
		if camera_rect.has_point(fog_rect.position):
			# Only hide fog in LOS, but keep it rendered if outside LOS
			fog_rect.visible = tile_pos not in visible_tiles
		else:
			# Cull fog outside camera view for performance
			fog_rect.visible = false  

	# Hide or show baddies based on LOS and camera culling
	for baddy in GameState.baddies:
		if baddy.scene == null:
			continue
		if camera_rect.has_point(baddy.scene.position):  
			# Baddies should only be visible if they're inside LOS
			baddy.scene.visible = baddy.grid_position in visible_tiles
		else:
			# Cull baddies outside the camera view
			baddy.scene.visible = false  



func get_camera_bounds() -> Rect2:
	"""Returns the world-space bounds of the Camera2D, properly handling zoom."""
	var camera: Camera2D = $Camera2D  # Directly reference the correct camera
	var viewport_size = get_viewport().size  # Get the viewport's actual size (Vector2i)

	# Convert Vector2i to Vector2 for correct calculations and divide by zoom
	var half_screen_size = (Vector2(viewport_size) / 2) / camera.zoom

	var top_left = camera.position - half_screen_size
	var size = half_screen_size * 2

	return Rect2(top_left, size)  # Return world-space bounds adjusted for zoom




func get_tiles_in_los() -> Array:
	"""Computes field of view (FOV) using a circular area and checks for obstructions."""
	var los_tiles = []
	var origin = GameState.player_position

	# Iterate over all tiles within a circular area
	for x in range(-LOS_RANGE, LOS_RANGE + 1):
		for y in range(-LOS_RANGE, LOS_RANGE + 1):
			var target_pos = origin + Vector2(x, y)

			# Ensure we stay within the valid map area
			if not is_tile_valid(target_pos):
				continue

			# Ensure the tile is within a circular range
			if target_pos.distance_to(origin) > LOS_RANGE:
				continue

			# Check if the direct path from origin to target_pos is blocked
			if not is_path_blocked(origin, target_pos):
				los_tiles.append(target_pos)

	return los_tiles


func is_path_blocked(start: Vector2, end: Vector2) -> bool:
	"""Checks if the direct line from start to end is blocked by a wall using Bresenham's algorithm."""
	var diff = end - start
	var steps = max(abs(diff.x), abs(diff.y))
	
	# Step increment for each axis
	var step_x = diff.x / steps
	var step_y = diff.y / steps

	var current_pos = start

	# Iterate over the line, checking each step
	for i in range(steps):
		current_pos += Vector2(step_x, step_y)

		# Round to the nearest tile position
		var tile_pos = Vector2(round(current_pos.x), round(current_pos.y))

		# If we hit a wall, return True (path is blocked)
		if is_tile_wall(tile_pos):
			return true

	return false  # Path is clear


func is_tile_valid(pos: Vector2) -> bool:
	""" Check if a tile position is within map bounds """
	return pos.x >= 0 and pos.y >= 0 and pos.x < GameState.map.width and pos.y < GameState.map.height

func is_tile_wall(pos: Vector2) -> bool:
	""" Check if a given tile is a wall """
	return GameState.map.tiles[pos.x][pos.y].type == Tile.TileType.WALL or GameState.map.tiles[pos.x][pos.y].type == Tile.TileType.AIR
