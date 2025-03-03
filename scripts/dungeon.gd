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

func data_write(data: Array, x: int, y: int, val: int):
	if (x >= 0 and x < width and y >= 0 and y < height):
		data[x][y] = val
	
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
	level_carve_path(data[4], Vector2(100,70), Vector2(20,20))
	# level 6
	level_carve_corridor(data[5], Vector2(100,70), Vector2(20,20))
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
	# level 9
	level_carve_hallway(data[8], Vector2(72, 10), true, 2, 9, Vector2(5,3), Vector2(2,3))
	level_carve_hallway(data[8], Vector2(32, 10), true, 3, 13, Vector2(5,3), Vector2(7,7))
	level_carve_hallway(data[8], Vector2(115, 7), true, 1, 27, Vector2(3,3), Vector2(17,5))
	level_carve_hallway(data[8], Vector2(10, 70), false, 5, 17, Vector2(3,7), Vector2(5, 5))
	
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
			data_write(data, x+rect.position.x, y+rect.position.y, 1)

func level_carve_path(data: Array, start: Vector2, end: Vector2):
	var x_start
	var x_end
	var y_start
	var y_end
	if (start.x < end.x):
		x_start = start.x
		x_end = end.x
	else:
		x_start = end.x
		x_end = start.x
	if (start.y < end.y):
		y_start = start.y
		y_end = end.y
	else:
		y_start = end.y
		y_end = start.y
	for x in (x_end - x_start):
		data[x + x_start][y_start] = 1
	for y in (y_end - y_start):
		data[x_end][y + y_start] = 1
		
func level_carve_corridor(data: Array, start: Vector2, end: Vector2):
	var x_start
	var x_end
	var y_start
	var y_end
	if (start.x < end.x):
		x_start = start.x
		x_end = end.x
	else:
		x_start = end.x
		x_end = start.x
	if (start.y < end.y):
		y_start = start.y
		y_end = end.y
	else:
		y_start = end.y
		y_end = start.y
	var x_dist = x_end - x_start
	var y_dist = y_end - y_start
	var ratio = float(x_dist) / float(y_dist)
	push_warning(ratio)
	if (ratio < 1.0 and ratio != 0):
		var y_pos = float(y_start)
		for x in (x_end - x_start):
			data[x + x_start][int(y_pos)] = 1;
			data[x + x_start + 1][int(y_pos)] = 1;
			data[x + x_start - 1][int(y_pos)] = 1;
			data[x + x_start][int(y_pos) + 1] = 1;
			data[x + x_start][int(y_pos) - 1] = 1;
			y_pos += ratio
	else:
		var x_pos = float(x_start)
		for y in (y_end - y_start):
			data[int(x_pos)][y + y_start] = 1;
			data[int(x_pos) + 1][y + y_start] = 1;
			data[int(x_pos) - 1][y + y_start] = 1;
			data[int(x_pos)][y + y_start + 1] = 1;
			data[int(x_pos)][y + y_start - 1] = 1;
			x_pos += ratio

func level_add_rubble(data: Array, rect: Rect2, amount: int):
	for i in amount:
		data[rect.position.x+(rng_next_int()%int(rect.size.x))][rect.position.y+(rng_next_int()%int(rect.size.y))] = 0
		
func level_carve_hallway(data: Array, start: Vector2, vertical: bool, hall_width: int, room_count: int, room_min: Vector2, room_rng: Vector2):
	var pos
	if (vertical): # going downwards
		var max_y = 0
		# do east rooms
		pos = 0
		for i in floor(room_count/2):
			var room_w = room_min.x + (rng_next_int()%int(room_rng.x))
			var room_h = room_min.y + (rng_next_int()%int(room_rng.y))
			var room = Rect2(start.x - 1 - room_w, start.y + pos, room_w, room_h)
			level_carve_rect(data, room)
			data[room.position.x + room_w][room.position.y + rng_next_int()%int(room_h-2)+1] = 1; # door
			pos += room_h + 1
		max_y = pos
		# do west rooms
		pos = 0
		for i in ceil(room_count/2):
			var room_w = room_min.x + (rng_next_int()%int(room_rng.x))
			var room_h = room_min.y + (rng_next_int()%int(room_rng.y))
			var room = Rect2(start.x + hall_width + 1, start.y + pos, room_w, room_h)
			level_carve_rect(data, room)
			data[room.position.x - 1][room.position.y + rng_next_int()%int(room_h-2)+1] = 1; # door
			pos += room_h + 1
		# tie them together
		if (max_y < pos):
				max_y = pos
		level_carve_rect(data, Rect2(start.x, start.y, hall_width, max_y-1))
	else: # going rightwards
		var max_x = 0
		# do north rooms
		pos = 0
		for i in floor(room_count/2):
			var room_w = room_min.x + (rng_next_int()%int(room_rng.x))
			var room_h = room_min.y + (rng_next_int()%int(room_rng.y))
			var room = Rect2(start.x + pos, start.y - room_h - 1, room_w, room_h)
			level_carve_rect(data, room)
			data[room.position.x + rng_next_int()%int(room_w-2)+1][room.position.y + room_h] = 1; # door
			pos += room_w + 1
		max_x = pos
		# do south rooms
		pos = 0
		for i in ceil(room_count/2):
			var room_w = room_min.x + (rng_next_int()%int(room_rng.x))
			var room_h = room_min.y + (rng_next_int()%int(room_rng.y))
			var room = Rect2(start.x + pos, start.y + hall_width + 1, room_w, room_h)
			level_carve_rect(data, room)
			data[room.position.x + rng_next_int()%int(room_w-2)+1][room.position.y - 1] = 1; # door
			pos += room_w + 1
		# tie them together
		if (max_x < pos):
				max_x = pos
		level_carve_rect(data, Rect2(start.x, start.y, max_x-1, hall_width))
		pass
