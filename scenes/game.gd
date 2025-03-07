extends Node

@onready var ground_tile_map = $Grid/Ground
@onready var entity_layer = $EntityLayer
@onready var player = $EntityLayer/Player  
var turn = 0

const BADDY_SCENE = preload("res://scenes/baddy.tscn")

func _ready() -> void:
	GameState.start_game()
	print("Clearing tilemap on load...")
	ground_tile_map.clear()
	fill_map_tiles()
	_on_player_moved(GameState.player_position)
	GameState.player_moved.connect(_on_player_moved)
	GameState.turn_ended.connect(_on_turn_ended)

	spawn_baddies()

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
		get_tree().quit()

	if move_dir != Vector2i.ZERO:
		GameState.move_player(move_dir)

func _on_player_moved(new_position: Vector2i):
	player.position = new_position * GameState.TILE_SIZE + Vector2i(GameState.TILE_SIZE / 2, GameState.TILE_SIZE / 2)

func _on_turn_ended():
	drawScore()
	turn += 1
	await run_ai_turn()
	GameState.turn_active = true  
	drawScore()

func run_ai_turn():
	for baddy in GameState.baddies:
		baddy.take_turn()
		baddy.scene.position = (baddy.grid_position * GameState.TILE_SIZE)
		baddy.scene.update_state()
	pass
	await get_tree().create_timer(0.01).timeout

func drawScore():
	var label = $CanvasLayer/Label
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
