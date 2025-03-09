extends Node

@onready var ground_tile_map = $Grid/Ground
@onready var entity_layer = $EntityLayer
@onready var player = $EntityLayer/Player
@onready var fog_layer = $Grid/FogOfWar  # Layer for fog effect

var turn = 0
const BADDY_SCENE = preload("res://scenes/baddy.tscn")
const ITEM_SCENE = preload("res://scenes/item.tscn")


func _ready() -> void:
	set_physics_process(false)
	ground_tile_map.set_physics_process(false)
	ground_tile_map.set_physics_process_internal(false)
	entity_layer.set_physics_process(false)
	fog_layer.set_physics_process(false)
	GameState.start_game()
	GameState.map.load_level_grid_tiles(0, ground_tile_map)
	print("Clearing tilemap on load...")
	_on_player_moved(GameState.player_position)
	GameState.player_moved.connect(_on_player_moved)
	GameState.turn_ended.connect(_on_turn_ended)

	spawn_baddies()
	spawn_items()
	initialize_fog_layer()

	# Bind update_zoom event from Camera2D
	$Camera2D.connect("update_zoom", Callable(self, "_on_update_zoom"))
	GameState.connect("player_damaged", Callable(self, "_on_player_damaged"))
	GameState.connect("new_item", Callable(self, "_on_new_item"))

	$Camera2D._on_player_moved(GameState.player_position)
	
	update_los()

func _on_new_item(item: Item):
	var item_instance = ITEM_SCENE.instantiate()
	item_instance.position = item.grid_position * GameState.TILE_SIZE
	set_item_animation(item_instance, item.type)  # Assign animation
	entity_layer.add_child(item_instance)
	item.scene = item_instance

func _on_player_damaged(damage: int):
	spawn_floating_text("-"+str(damage),Color.CRIMSON,player.position)

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
	var destination = GameState.player_position
	
	if not moved:
		destination += move_dir
		if GameState.pos_has_baddy(destination):
			attack_baddy(destination)
		else:
			return
	else:
		var pos_tile = GameState.map.tiles[destination.x][destination.y]
		if pos_tile.type == Tile.types.stair_down:
			GameState.depth += 1
			GameState.map.load_level_grid_tiles(GameState.depth, ground_tile_map)
		if pos_tile.type == Tile.types.stair_up:
			GameState.depth -= 1
			GameState.map.load_level_grid_tiles(GameState.depth, ground_tile_map)
	# Check if the player stepped on an item
	var found_item = get_item_at_position(destination)
	if found_item:
		handle_item_trigger(found_item)

	GameState.end_turn()

func get_item_at_position(position: Vector2) -> Item:
	"""Returns the item at the given position, or null if none exists."""
	for item in GameState.items:
		if item.grid_position == position:
			return item
	return null

func heal_player(heal_amount):
	GameState.hp += heal_amount
	GameState.hp = GameState.max_hp if GameState.hp > GameState.max_hp else GameState.hp

func handle_item_trigger(item: Item):
	"""Handles player interaction with an item."""

	if item.type == Item.ItemType.BRAZIER_OFF:
		# Change item type to BRAZIER_ON
		item.type = Item.ItemType.BRAZIER_ON
		set_item_animation(item.scene, item.type)  # Update animation
	
	elif item.type == Item.ItemType.APPLE:
		# Heal player and remove the item
		var heal_amount = GameState.rng_next_int() % 6 + 3  # Random number between 3-8
		heal_player(heal_amount)

		# Remove the apple from the game
		remove_item_from_game(item)
		spawn_floating_text("+" + str(heal_amount), Color.DARK_GREEN, item.scene.position)

	elif item.type == Item.ItemType.POTION_BLUE:
		# Increase player LOS range
		GameState.player_los += 1

		# Remove potion from game
		remove_item_from_game(item)
		spawn_floating_text("+1 LOS", Color(0, 0.5, 1), item.scene.position)  # Blue floating text

	elif item.type == Item.ItemType.SWORD:
		# Increase player damage
		GameState.player_damage += 1

		# Remove sword from game
		remove_item_from_game(item)
		spawn_floating_text("+1 DMG", Color(0, 0.5, 1), item.scene.position)  # Blue floating text
	
	elif item.type == Item.ItemType.SHIELD_1:
		# Increase player damage
		GameState.max_hp += 2
		GameState.hp += 2

		# Remove sword from game
		remove_item_from_game(item)
		spawn_floating_text("+2 MAX HP", Color(0, 0.5, 1), item.scene.position)  # Blue floating text
	elif item.type == Item.ItemType.SHIELD_2:
		# Increase player damage
		GameState.max_hp += 5
		GameState.hp += 5

		# Remove sword from game
		remove_item_from_game(item)
		spawn_floating_text("+5 MAX HP", Color(0, 0.5, 1), item.scene.position)  # Blue floating text
	elif item.type == Item.ItemType.SHIELD_3:
		# Increase player damage
		GameState.max_hp += 10
		GameState.hp += 10

		# Remove sword from game
		remove_item_from_game(item)
		spawn_floating_text("+10 MAX HP", Color(0, 0.5, 1), item.scene.position)  # Blue floating text

func spawn_floating_text(text: String, color: Color, position: Vector2):
	"""Spawns floating text above the given position, animates it upwards, and fades it out."""
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 16)  # Make text larger
	label.set_anchors_preset(Control.PRESET_CENTER_TOP)  # Ensure correct positioning
	label.z_index = 100  # Ensure it's above everything else

	# Convert world position to screen position if needed
	label.position = position - Vector2(0, 16)  # Offset upwards
	entity_layer.add_child(label)  # Add to entity layer

	# Animate text movement and fade-out
	var tween = create_tween()
	tween.tween_property(label, "position", label.position + Vector2(0, -18), 1.2).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.2).set_trans(Tween.TRANS_LINEAR)

	# Delete label after animation
	await tween.finished
	label.queue_free()



func remove_item_from_game(item: Item):
	"""Removes an item from the game both in GameState and in the scene."""
	if item in GameState.items:
		GameState.items.erase(item)  # Remove from game logic
	
	# Remove item from the scene
	if item.scene:
		item.scene.queue_free()


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

		# Move and update state
		baddy.take_turn()
		baddy.scene.position = (baddy.grid_position * GameState.TILE_SIZE)
		baddy.scene.update_state()

		# Check if the baddy is on an item that allows interaction
		var item = get_item_at_position(baddy.grid_position)
		if item and item.for_baddies:
			handle_baddy_item_interaction(baddy, item)

	await get_tree().create_timer(0.01).timeout
	
func handle_baddy_item_interaction(baddy: Baddy, item: Item):
	"""Handles interactions between baddies and items flagged as 'for_baddies'."""
	match item.type:
		Item.ItemType.SWORD:
			# Baddy gets stronger!
			baddy.damage += 1
			spawn_floating_text("+1 DMG", Color(0.5, 0, 1), baddy.scene.position)

			# Remove sword from the game
			remove_item_from_game(item)
		Item.ItemType.SHIELD_1:
			# Baddy gets stronger!
			baddy.hp += 2
			spawn_floating_text("+2 HP", Color.GOLD, baddy.scene.position)

			remove_item_from_game(item)
		Item.ItemType.SHIELD_2:
			# Baddy gets stronger!
			baddy.hp += 4
			spawn_floating_text("+4 HP", Color.GOLD, baddy.scene.position)

			remove_item_from_game(item)
		Item.ItemType.SHIELD_3:
			# Baddy gets stronger!
			baddy.hp += 7
			spawn_floating_text("+7 HP", Color.GOLD, baddy.scene.position)

			remove_item_from_game(item)




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

func spawn_items():
	"""Instantiate item scenes and place them in the world."""
	for item in GameState.items:
		var item_instance = ITEM_SCENE.instantiate()
		item_instance.position = item.grid_position * GameState.TILE_SIZE
		set_item_animation(item_instance, item.type)  # Assign animation
		entity_layer.add_child(item_instance)
		item.scene = item_instance

func set_item_animation(item_instance: Node2D, item_type: int):
	"""Assigns the correct animation to an item based on its type."""
	var sprite = item_instance.get_node("AnimatedSprite2D")
	var animation_name = item_type_to_string(item_type)  # Convert enum to string
	if sprite.sprite_frames.has_animation(animation_name):
		sprite.play(animation_name)  # Play the correct animation

func item_type_to_string(item_type: int) -> String:
	"""Converts an ItemType enum to a lowercase string."""
	return Item.ItemType.keys()[item_type].to_lower()


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
		for item in GameState.items:
			if item.scene != null:
				item.scene.visible = true 
		return

	fog_layer.visible = true  # Ensure fog layer is visible

	# Get properly scaled camera bounds
	var camera_rect = get_camera_bounds().grow(10*GameState.TILE_SIZE)

	# Get visible tiles within LOS range
	var visible_tiles = get_tiles_in_los()
	var los_area = Rect2(GameState.player_position - Vector2(GameState.player_los, GameState.player_los), Vector2(GameState.player_los * 2, GameState.player_los * 2))

	# Update fog tiles (considering zoom)F
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
	for item in GameState.items:
		if item.scene == null:
			continue
		if camera_rect.has_point(item.scene.position):  
			# Baddies should only be visible if they're inside LOS
			item.scene.visible = item.grid_position in visible_tiles
		else:
			# Cull baddies outside the camera view
			item.scene.visible = false



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
	"""Computes field of view (FOV) using a circular area and includes lit braziers."""
	var los_tiles = []
	var origin = GameState.player_position

	# Compute player's LOS
	for x in range(-GameState.player_los, GameState.player_los + 1):
		for y in range(-GameState.player_los, GameState.player_los + 1):
			var target_pos = origin + Vector2(x, y)

			# Ensure we stay within the valid map area
			if not GameState.is_tile_valid(target_pos):
				continue

			# Ensure the tile is within a circular range
			if target_pos.distance_to(origin) > GameState.player_los:
				continue

			# Check if the direct path from origin to target_pos is blocked
			if not is_path_blocked(origin, target_pos):
				los_tiles.append(target_pos)

	# Braziers provide light through walls
	var brazier_los = GameState.player_los / 2

	# Iterate over all items to check for lit braziers
	for item in GameState.items:
		if item.type == Item.ItemType.BRAZIER_ON:
			for x in range(-brazier_los, brazier_los + 1):
				for y in range(-brazier_los, brazier_los + 1):
					var target_pos = item.grid_position + Vector2(x, y)

					# Ensure we stay within the valid map area
					if not GameState.is_tile_valid(target_pos):
						continue

					# Ensure the tile is within the brazier's light radius
					if target_pos.distance_to(item.grid_position) > brazier_los:
						continue

					# No path blocking check—light passes through walls
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
	for i in range(1,steps):
		current_pos += Vector2(step_x, step_y)

		# Round to the nearest tile position
		var tile_pos = Vector2(round(current_pos.x), round(current_pos.y))

		# If we hit a wall, return True (path is blocked)
		if is_tile_blocking(tile_pos) and get_tile_obf(tile_pos) >= .5:
			return true

	return false  # Path is clear


func get_tile_obf(pos: Vector2) -> float:
	return GameState.map.tiles[pos.x][pos.y].obfuscate

func is_tile_blocking(pos: Vector2) -> bool:
	""" Check if a given tile is a wall """
	return !GameState.map.tiles[pos.x][pos.y].traversable
