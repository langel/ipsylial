extends Node2D

var rng = load("res://rng.gd").new()

const seedval: int = 0x1ee71337
var pos: int = 0x13371ee7
var temp: int = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _draw():
	for n in 3024:
		pos += 1
		temp = rng.rng(pos, seedval)
		draw_line(Vector2(temp & 255, (temp >> 8) & 255), Vector2((temp & 255) + 1, (temp >> 8) & 255), Color.BLACK, 1.0)
		draw_line(Vector2(((temp >> 16) & 255), (temp >> 24) & 255), Vector2(((temp >> 16) & 255) + 1, (temp >> 24) & 255), Color.RED, 1.0)
		pos += 1
		temp = rng.rng(pos, seedval)
		draw_line(Vector2(temp & 255, (temp >> 8) & 255), Vector2((temp & 255) + 1, (temp >> 8) & 255), Color.GREEN, 1.0)
		draw_line(Vector2(((temp >> 16) & 255), (temp >> 24) & 255), Vector2(((temp >> 16) & 255) + 1, (temp >> 24) & 255), Color.BLUE, 1.0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
