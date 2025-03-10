extends Node2D

const TITLE_SCENE_PATH = "res://scenes/main.tscn"

@onready var image = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screen_size = get_viewport().size  # Get window size
	var texture_size = image.texture.get_size() # Get original sprite size
# Calculate scale factors
	var scale_x = screen_size.x / texture_size.x
	var scale_y = screen_size.y / texture_size.y
	# Apply scale
	image.scale = Vector2(scale_x, scale_y)
	#image.centered = false
	image.position = Vector2(0,0)
	
	
	await get_tree().create_timer(3.33).timeout
	get_tree().change_scene_to_file(TITLE_SCENE_PATH)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
