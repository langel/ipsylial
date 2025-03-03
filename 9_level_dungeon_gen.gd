extends Node2D

var map: Map
var level_count = 9
var level_width = 144
var level_height = 96
var data = []

var colors = [
	Color.BLACK,
	Color.BISQUE,
	Color.SADDLE_BROWN,
	Color.SANDY_BROWN
]

const DEFAULT_RNG_POS = 0x13371ee7
var pos: int = DEFAULT_RNG_POS
var seedval: int = 0x1ee71337
var rng = load("res://scripts/rng.gd").new()
func rng_next_int() -> int:
	pos += 1
	return rng.rng(pos, seedval)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for l in level_count:
		data.append([])
		for x in level_width:
			data[l].append([])
			for y in level_height:
				data[l][x].append(rng_next_int() % 4)

func _draw():
	for l in range(data.size()):
		var l_x = (l % 3) * level_width * 2.7 + 110
		var l_y = floor(l / 3) * level_height * 2.4 + 30
		for x in range(data[l].size()):
			for y in range(data[l][x].size()):
				draw_rect(Rect2(x*2+l_x,y*2+l_y,2,2), colors[data[l][x][y]])
				
			
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if !GameState.turn_active:
		return  
	elif Input.is_action_just_pressed("escape"):
		get_tree().quit()
