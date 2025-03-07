extends Camera2D
signal update_zoom

@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.3
@export var max_zoom: float = 3.0
@export var tile_size: int = 32

var target_zoom: Vector2 = Vector2(1, 1)

func _ready():
	make_current()
	target_zoom = zoom
	GameState.player_moved.connect(_on_player_moved)

func _process(delta):
	if Input.is_action_just_pressed("zoom_out"):
		target_zoom *= 1.0 - zoom_step
	elif Input.is_action_just_pressed("zoom_in"):
		target_zoom *= 1.0 + zoom_step
	else:
		return
	emit_signal("update_zoom")
	target_zoom = target_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	zoom = zoom.lerp(target_zoom, 5.0 * delta)
	

func _on_player_moved(new_position: Vector2i):
	position = (new_position * tile_size) + Vector2i(tile_size / 2, tile_size / 2)
