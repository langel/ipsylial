extends Camera2D

@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.3
@export var max_zoom: float = 3.0

var target_zoom: Vector2 = Vector2(1, 1)

func _ready():
	make_current()  # Ensure this camera is active
	target_zoom = zoom  # Set initial zoom target

func _process(delta):
	if Input.is_action_just_pressed("zoom_out"):
		target_zoom *= 1.0 - zoom_step
	elif Input.is_action_just_pressed("zoom_in"):
		target_zoom *= 1.0 + zoom_step

	target_zoom = target_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	zoom = zoom.lerp(target_zoom, 5.0 * delta)  # Smooth zooming
