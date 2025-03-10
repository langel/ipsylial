extends Node2D

const TITLE_SCENE_PATH = "res://scenes/main.tscn"

@onready var image = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
# Calculate scale factors
	var texture_size = image.texture.get_size() 
	var screen_w = ProjectSettings.get("display/window/size/viewport_width")
	var screen_h = ProjectSettings.get("display/window/size/viewport_height")
# Calculate scale factors
	var scale_x = screen_w / texture_size.x
	var scale_y = screen_h / texture_size.y
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
