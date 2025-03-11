class_name Baddy
extends Control
signal baddy_attacks(direction: Vector2)
signal baddy_damaged
signal died
signal toggle_visible

enum BaddyType { ROGUE, KNIGHT, MAGE, BARB, FARMER }
enum BaddyBehavior {CHILL, CONFIDENT, SEEKING, STARTLED, ATTACKING, FRIGHTENED}

var baddy_type: BaddyType = BaddyType.FARMER
var grid_position: Vector2 = Vector2(0,0)
var texture = null
var scene = null

var behavior = BaddyBehavior.CHILL
var aggression_area = 6
var behavior_change_freq = 2
var behavior_turns = 0
var num_variations = 1
var attack_frequency = 2
var damage = 1
var variation = 0

var hp = 4

var variation_coords: Array[Vector2] = [Vector2(0,0)]

var SPRITE_SHEET = preload("res://assets/textures/32rogues/rogues.png")
const FRAME_SIZE = Vector2(GameState.TILE_SIZE, GameState.TILE_SIZE)

func _init(pos: Vector2i, baddy_type: BaddyType = BaddyType.FARMER):
	grid_position = pos
	position= pos
	self.baddy_type = baddy_type

func _ready() -> void:
	position = (grid_position * GameState.TILE_SIZE) + Vector2(GameState.TILE_SIZE / 2, GameState.TILE_SIZE / 2)
	texture = get_texture_for_type()

func get_texture_for_type() -> AtlasTexture:
	var texture = AtlasTexture.new()
	texture.atlas = SPRITE_SHEET
	texture.region = get_region_for_type()
	return texture
	
func any_items():
	for item in GameState.items:
		if item.for_baddies and grid_position.distance_to(item.grid_position) <= aggression_area:
			return true
	return false
	
func any_player():
	return GameState.player_position.distance_to(grid_position) <= aggression_area


func take_damage(amount):
	hp -= amount
	emit_signal("baddy_damaged")
	if not is_alive():
		die()

func is_alive():
	return hp > 0

func die():
	emit_signal("died")
	pass

func set_behavior(behavior):
	self.behavior_turns = 0
	self.behavior = behavior

func change_behavior():
	var is_player = any_player()
	var is_item = any_items()
	if behavior == BaddyBehavior.CHILL:
		if is_player:
			set_behavior(BaddyBehavior.STARTLED)
	elif behavior == BaddyBehavior.STARTLED:
		if is_item:
			set_behavior(BaddyBehavior.SEEKING)
		elif is_player:
			set_behavior(BaddyBehavior.CONFIDENT)
	elif behavior == BaddyBehavior.SEEKING:
		if not is_item:
			if is_player:
				set_behavior(BaddyBehavior.CONFIDENT)
			else:
				set_behavior(BaddyBehavior.CHILL)
	elif behavior == BaddyBehavior.CONFIDENT:
		if not is_player:
			if not is_item:
				set_behavior(BaddyBehavior.CHILL)
			else:
				set_behavior(BaddyBehavior.SEEKING)
	more_behavior(is_player, is_item)

func more_behavior(any_player, any_items):
	pass

func take_turn():
	var dir: Vector2 = Vector2(0,0)
	behavior_turns += 1
	if behavior_turns > behavior_change_freq:
		if behavior == BaddyBehavior.ATTACKING:
			set_behavior(BaddyBehavior.SEEKING)
		change_behavior()

	if behavior == BaddyBehavior.CHILL:
		dir = get_random_direction()
	elif behavior == BaddyBehavior.CONFIDENT:
		dir = dir_to_player()
	elif behavior == BaddyBehavior.SEEKING:
		dir = dir_to_item()
	
	var new_position = self.grid_position + dir
	if GameState.baddy_can_move_here(new_position):
		self.grid_position = new_position
	elif new_position == GameState.player_position:
		self.set_behavior(BaddyBehavior.ATTACKING)
		GameState.attack_player(self)
		emit_signal("baddy_attacks",dir)
	
func get_random_direction():
	var rand = GameState.rng_next_int()%4
	var dirs = [Vector2(-1,0),Vector2(0,-1),Vector2(0,1),Vector2(-1,0)]
	var dir_options = []
	for dir in dirs:
		if GameState.baddy_can_move_here(grid_position+dir):
			dir_options.append(dir)
	if dirs.size() > 0:
		return dirs[GameState.rng_next_int()%dirs.size()]
	return Vector2(0,0)

func dir_to_player():
	if GameState.player_position.distance_to(grid_position) > aggression_area:
			return Vector2(0,0)
	var path = GameState.get_ai_path(grid_position,GameState.player_position)
	if path.size() > 1:
		return path[1]-grid_position
	return Vector2(0,0)

func dir_to_item() -> Vector2:
	"""Returns the direction toward the nearest reachable item."""
	var item = find_nearest_reachable_item()
	if item:
		var path = GameState.get_ai_path(grid_position, item.grid_position)
		if path.size() > 1:
			return path[1] - grid_position  # Move toward the next step in the path
	return Vector2(0, 0)  # No valid path, don't move


func find_nearest_reachable_item() -> Item:
	"""Finds the closest item that the baddy can reach."""
	var nearest_item = null
	var shortest_distance = INF  # Start with infinite distance

	for item in GameState.items:
		if item.for_baddies:
			if item.grid_position.distance_to(grid_position) > aggression_area:
				continue
			var path = GameState.get_ai_path(grid_position, item.grid_position)
			if path.size() > 1 and path.size() < shortest_distance:
				nearest_item = item
				shortest_distance = path.size()

	return nearest_item


func get_region_for_type() -> Rect2:
	var coords = variation_coords[self.variation%self.num_variations]
	return Rect2(FRAME_SIZE.x*coords.x, FRAME_SIZE.y*coords.y, FRAME_SIZE.x, FRAME_SIZE.y)
