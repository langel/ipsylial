extends Node

const MAP_SCENE_PATH = "res://scenes/game.tscn"

@onready var title_image = $title_image

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# start button hook it up
	var start_button = $MainMenu/PlayButton
	var map_button = $MainMenu/MapButton

	map_button.connect("pressed", Callable(self, "_on_MapButton_pressed"))
	
	var screen_size = get_viewport().size  # Get window size
	var texture_size = title_image.texture.get_size() # Get original sprite size
# Calculate scale factors
	var scale_x = screen_size.x / texture_size.x
	var scale_y = screen_size.y / texture_size.y
	# Apply scale
	title_image.scale = Vector2(scale_x, scale_y)
	title_image.centered = false
	title_image.position = Vector2(0,0)
	
	var start_label = $press_key
	start_label.set_position(Vector2(95,300))
	start_label.text = "press any direction to start"
	
	var credits_label = $credits
	credits_label.set_position(Vector2(55,405))
	credits_label.text = "a 7DRL submission 2025  •  code: kigu + langel  •  grafx: 32rogues by Seth"

	pass # Replace with function body.
	
func _draw():
	pass
	
func _input(event):
	if Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_right"):	
		var start_label = $press_key
		start_label.text = "generating dungeon . . ."
		await get_tree().create_timer(0.1).timeout
		$press_key.queue_redraw()
		await GameState.start_game()
		get_tree().change_scene_to_file(MAP_SCENE_PATH)
	

	
func _on_MapButton_pressed():
	# Load and switch to the game scene when the button is pressed
	GameState.start_game()
	get_tree().change_scene_to_file(MAP_SCENE_PATH)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
