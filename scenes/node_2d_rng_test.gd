extends Node2D

var temp: int = 0

var dynamic_label: Label = Label.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"label test".text = "@"
	dynamic_label.text = "&"
	dynamic_label.add_theme_color_override("font_color", Color("eed122"))
	add_child(dynamic_label)

func _draw():
	for n in 64:
		temp = GameState.rng_next_int()
		draw_line(Vector2(temp & 255, (temp >> 8) & 255), Vector2((temp & 255) + 1, (temp >> 8) & 255), Color.BLACK, 1.0)
		draw_line(Vector2(((temp >> 16) & 255), (temp >> 24) & 255), Vector2(((temp >> 16) & 255) + 1, (temp >> 24) & 255), Color.RED, 1.0)
		temp = GameState.rng_next_int()
		draw_line(Vector2(temp & 255, (temp >> 8) & 255), Vector2((temp & 255) + 1, (temp >> 8) & 255), Color.GREEN, 1.0)
		draw_line(Vector2(((temp >> 16) & 255), (temp >> 24) & 255), Vector2(((temp >> 16) & 255) + 1, (temp >> 24) & 255), Color.BLUE, 1.0)
		draw_string(ThemeDB.fallback_font, 
			Vector2((GameState.pos >> 8) % 256 - 8, 64), 
			"@", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(0xee, 0xd1, 0x21))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$"label test".position.x += 0.25
	if ($"label test".position.x >= 256): $"label test".position.x -= 256
	$"label test".position.y += 0.33
	if ($"label test".position.y >= 256): $"label test".position.y -= 256
	dynamic_label.position.x += 1.25
	if (dynamic_label.position.x >= 256): dynamic_label.position.x -= 256
	dynamic_label.position.y += 1.33
	if (dynamic_label.position.y >= 256): dynamic_label.position.y -= 256
	queue_redraw()
	pass
