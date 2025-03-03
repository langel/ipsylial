class_name Dungeon
extends Node


var levels = 9
var width = 144
var height = 96


const DEFAULT_RNG_POS = 0x13371ee7
var pos: int = DEFAULT_RNG_POS
var seedval: int = 0x1ee71337
var rng = load("res://scripts/rng.gd").new()
func rng_next_int() -> int:
	pos += 1
	return rng.rng(pos, seedval)

	
func gen_empty_map() -> Array:
	var data = []
	for l in levels:
		data.append([])
		for x in width:
			data[l].append([])
			for y in height:
				data[l][x].append(0)
	return data
	
func gen_terrain(data: Array):
	# level 1
	level_carve_rect(data[0], Rect2(20, 20, 20, 20))
	# level 2
	level_carve_elipse(data[1], Rect2(20,20,100,70))
	# level 3
	level_carve_ovoid(data[2], Rect2(20,20,50,70))
	# level 4
	level_carve_rounded(data[3], Rect2(30,20,90,50))
	# level 5
	level_carve_path(data[4], Vector2(20,20), Vector2(100,70))
	# level 6
	level_carve_corridor(data[5], Vector2(20,20), Vector2(100,70))
	# level 7
	level_carve_rounded(data[6], Rect2(5,5,width-10,height-10))
	level_add_rubble(data[6], Rect2(10, 10, 40, 40), 500)
	level_add_rubble(data[6], Rect2(0,0,width,height), 100)
	# level 8
	level_carve_rounded(data[7], Rect2(width/2-30,height/2-10,60,20))
	level_carve_elipse(data[7], Rect2(10,10,20,20))
	level_carve_elipse(data[7], Rect2(width-30,10,20,30))
	level_carve_elipse(data[7], Rect2(10,60,20,20))
	level_carve_elipse(data[7], Rect2(width-30,height-30,20,20))
	level_add_rubble(data[7], Rect2(10, 10, width-20, height-20), 1000)
	level_carve_corridor(data[7], Vector2(15,15), Vector2(width/2-20,height/2-5))
	level_carve_path(data[7], Vector2(width/2,height/2), Vector2(width-20,height-20))
	
func level_carve_ovoid(data: Array, rect: Rect2):
	var mid = rect.size.x / 2
	for y in rect.size.y:
		var length = sin((y / rect.size.y)*PI)
		length *= length
		length *= mid
		for x in length:
			if (x+rect.position.x+mid < width and y+rect.position.y < height):
				data[x+rect.position.x+mid][y+rect.position.y] = 1
				data[(mid-x)+rect.position.x][y+rect.position.y] = 1
	
func level_carve_elipse(data: Array, rect: Rect2):
	var mid = rect.size.x / 2
	var y_pos = 0;
	for a in 180:
		var length = ceil(sin((a/180.0)*PI) * mid)
		var y = (cos((a/180.0)*PI) * 0.5 + 0.5) * rect.size.y
		if (y > y_pos + 0.5):
			y += 1
			for x in length:
				if (x+rect.position.x+mid < width and y+rect.position.y < height):
					data[x+rect.position.x+mid][y+rect.position.y] = 1
					data[(mid-x)+rect.position.x][y+rect.position.y] = 1
	
func level_carve_rounded(data: Array, rect: Rect2):
	var mid = rect.size.x / 2
	for a in 180:
		var length = ceil((sin((a/180.0)*PI) * 0.5 + 0.5) * mid)
		var y = (cos((a/180.0)*PI) * 0.5 + 0.5) * rect.size.y
		for x in length:
			if (x+rect.position.x+mid < width and y+rect.position.y < height):
				data[x+rect.position.x+mid][y+rect.position.y] = 1
				data[(mid-x)+rect.position.x][y+rect.position.y] = 1

func level_carve_rect(data: Array, rect: Rect2):
	for x in rect.size.x:
		for y in rect.size.y:
			data[x+rect.position.x][y+rect.position.y] = 1

func level_carve_path(data: Array, start: Vector2, end: Vector2):
	for x in (end.x - start.x):
		data[x + start.x][start.y] = 1
	for y in (end.y - start.y):
		data[end.x][y + start.y] = 1
		
func level_carve_corridor(data: Array, start: Vector2, end: Vector2):
	var ratio = float(end.y - start.y) / float(end.x - start.x)
	var y_pos = float(start.y)
	for x in (end.x - start.x):
		data[x + start.x][int(y_pos)] = 1;
		data[x + start.x + 1][int(y_pos)] = 1;
		data[x + start.x - 1][int(y_pos)] = 1;
		data[x + start.x][int(y_pos) + 1] = 1;
		data[x + start.x][int(y_pos) - 1] = 1;
		y_pos += ratio

func level_add_rubble(data: Array, rect: Rect2, amount: int):
	for i in amount:
		data[rect.position.x+(rng_next_int()%int(rect.size.x))][rect.position.y+(rng_next_int()%int(rect.size.y))] = 0
