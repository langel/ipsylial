class_name Baddy
extends Control

enum BaddyType { BLORX, FURD, DRAKE }
enum BaddyBehavior {CHILL, CONFIDENT, SEEKING, STARTLED}

var baddy_type: BaddyType = BaddyType.BLORX
var grid_position: Vector2 = Vector2(0,0)
var texture = null
var behavior = BaddyBehavior.CHILL
var scene = null
var aggression_area = 6
const SPRITE_SHEET = preload("res://assets/textures/32rogues/animals.png") 
const FRAME_SIZE = Vector2(GameState.TILE_SIZE, GameState.TILE_SIZE)
var behavior_change_freq = 2
var behavior_turns = 0
func _init(pos: Vector2i, baddy_type: BaddyType = BaddyType.BLORX):
	grid_position = pos
	position= pos
	self.baddy_type = baddy_type

func _ready() -> void:
	position = (grid_position * GameState.TILE_SIZE) + Vector2(GameState.TILE_SIZE / 2, GameState.TILE_SIZE / 2)
	texture = get_texture_for_type(baddy_type)

func get_texture_for_type(baddy_type: BaddyType) -> AtlasTexture:
	var texture = AtlasTexture.new()
	texture.atlas = SPRITE_SHEET
	texture.region = get_region_for_type(baddy_type)
	return texture
	
func any_items():
	for item in GameState.items:
		if grid_position.distance_to(item.grid_position) <= aggression_area:
			return true
	return false
	
func any_player():
	return GameState.player_position.distance_to(grid_position) <= aggression_area

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

func take_turn():
	var dir: Vector2 = Vector2(0,0)
	behavior_turns += 1
	if behavior_turns > behavior_change_freq:
		change_behavior()
		
	if behavior == BaddyBehavior.CHILL:
		dir = get_random_direction()
	elif behavior == BaddyBehavior.CONFIDENT:
		dir = dir_to_player()
	
	var new_position = self.grid_position + dir
	if GameState.baddy_can_move_here(new_position):
		self.grid_position = new_position

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
	var path = GameState.get_ai_path(grid_position,GameState.player_position)
	if path.size() > 1:
		return path[1]-grid_position
	return Vector2(0,0)

func get_region_for_type(baddy_type: BaddyType) -> Rect2:
	match baddy_type:
		BaddyType.BLORX:
			return Rect2(0, 0, FRAME_SIZE.x, FRAME_SIZE.y)
		BaddyType.FURD:
			return Rect2(32, 0, FRAME_SIZE.x, FRAME_SIZE.y)  # Next frame in the sheet
		BaddyType.DRAKE:
			return Rect2(64, 0, FRAME_SIZE.x, FRAME_SIZE.y)  # Adjust based on your sprite sheet layout
	return Rect2(32, 0, FRAME_SIZE.x, FRAME_SIZE.y)

func get_random_baddy_type() -> BaddyType:
	var enum_values = BaddyType.values()  # Get an array of all enum values
	return enum_values[GameState.rng_next_int() % enum_values.size()]
