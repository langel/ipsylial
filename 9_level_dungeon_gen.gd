extends Node2D

var dung: Dungeon
var data = []

var colors = [
	Color.LIME_GREEN,
	Color.HOT_PINK,
	Color.BISQUE,
	Color.DARK_GREEN,
	Color.SADDLE_BROWN,
	Color.SANDY_BROWN,
	Color.BLACK,
	Color.CORNFLOWER_BLUE,
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#DisplayServer.window_set_size(Vector2(1280,920))
	dung = Dungeon.new()
	data = dung.gen_empty_map()
	dung.gen_terrain(data)
	

func _draw():
	var s = 1 # scale
	for l in range(data.size()):
		var l_x = (l % 3) * dung.width * (s + 0.7) + 110
		var l_y = floor(l / 3) * dung.height * (s + 0.4) + 30
		for x in range(dung.width):
			for y in range(dung.height):
				draw_rect(Rect2(x*s+l_x,y*s+l_y,s,s), colors[data[l][x][y]])
			
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if !GameState.turn_active:
		return  
	elif Input.is_action_just_pressed("escape"):
		get_tree().quit()
	elif Input.is_action_just_pressed("space"):
		data = dung.gen_empty_map()
		dung.gen_terrain(data)
		queue_redraw()
