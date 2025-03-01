extends Node

const GAME_SCENE_PATH = "res://scenes/node_2d_rng_test.tscn"
const MAP_SCENE_PATH = "res://scenes/game.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# start button hook it up
	var start_button = $MainMenu/PlayButton
	var map_button = $MainMenu/MapButton

	start_button.connect("pressed", Callable(self, "_on_StartButton_pressed"))
	map_button.connect("pressed", Callable(self, "_on_MapButton_pressed"))

	pass # Replace with function body.

func _on_StartButton_pressed():
	# Load and switch to the game scene when the button is pressed
	GameState.start_game()
	get_tree().change_scene_to_file(GAME_SCENE_PATH)
	
func _on_MapButton_pressed():
	# Load and switch to the game scene when the button is pressed
	GameState.start_game()
	get_tree().change_scene_to_file(MAP_SCENE_PATH)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
