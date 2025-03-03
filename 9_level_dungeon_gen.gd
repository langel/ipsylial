extends Node2D

var dung: Dungeon
var data = []

var colors = [
	Color.BLACK,
	Color.BISQUE,
	Color.SADDLE_BROWN,
	Color.SANDY_BROWN
]

var sine_test = 0.01
var sine2 = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dung = Dungeon.new()
	data = dung.gen_empty_map()
	dung.gen_terrain(data)
	

func _draw():
	for l in range(data.size()):
		var l_x = (l % 3) * dung.width * 2.7 + 110
		var l_y = floor(l / 3) * dung.height * 2.4 + 30
		for x in range(dung.width):
			for y in range(dung.height):
				draw_rect(Rect2(x*2+l_x,y*2+l_y,2,2), colors[data[l][x][y]])
	sine_test += 0.17
	sine2 += 1
	sine2 %= 100
	$"debug".text = str(cos((sine2/100.0)*PI)*50).pad_decimals(3)
			
	
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
