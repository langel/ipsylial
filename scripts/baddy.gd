class_name Baddy
extends Control

enum BaddyType { BLORX, FURD, DRAKE }

var baddy_type: BaddyType = BaddyType.BLORX
var texture = null

const SPRITE_SHEET = preload("res://assets/textures/32rogues/animals.png") 
const FRAME_SIZE = Vector2(GameState.TILE_SIZE, GameState.TILE_SIZE)

func _init(pos: Vector2i, baddy_type: BaddyType = BaddyType.BLORX):
	position = pos
	self.baddy_type = baddy_type

func _ready() -> void:
	position = (position * GameState.TILE_SIZE) + Vector2(GameState.TILE_SIZE / 2, GameState.TILE_SIZE / 2)
	texture = get_texture_for_type(baddy_type)
func get_texture_for_type(baddy_type: BaddyType) -> AtlasTexture:
	var texture = AtlasTexture.new()
	texture.atlas = SPRITE_SHEET
	texture.region = get_region_for_type(baddy_type)
	return texture

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
