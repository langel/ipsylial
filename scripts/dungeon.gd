class_name Dungeon
extends Node

var tile := Tile.types


var depth = 9
var width = 144
var height = 96


const DEFAULT_RNG_POS = 0x13371ee7
var pos: int = DEFAULT_RNG_POS
var seedval: int = 0x1ee71337
var rng = load("res://scripts/rng.gd").new()
func rng_next_int() -> int:
	pos += 1
	return rng.rng(pos, seedval)
	
func rngmod(mod) -> int:
	pos += 1
	return rng.rng(pos, seedval)%int(mod)

func data_write(data: Array, x: int, y: int, val: int):
	if (x >= 0 and x < width and y >= 0 and y < height):
		data[x][y] = val
	
func gen_empty_map() -> Array:
	var data = []
	for z in depth:
		data.append([])
		for x in width:
			data[z].append([])
			for y in height:
				data[z][x].append(tile.wall)
	return data
	
	
func gen_terrain(data: Array) -> Array:
	pos = int(Time.get_unix_time_from_system()*1000)
	var rooms = []
	var stair
	var stairs = []
	var stairs_old = []
	var x = 0 # scratch registers
	var y = 0 
	var s = 0
	var d
	var r
	
	# level 1 - outside - walls are trees and flowers
	level_fill(data[0], tile.forrest)
	level_fill_ovoid(data[0], Rect2(width/2-17,height/2-17,34,34), tile.floor)
	# starting noise
	for i in 19:  #19
		x = rngmod(width/2)+width/5
		y = rngmod(height/2)+height/6
		level_carve_elipse(data[0], Rect2(x, y, rngmod(width/8)+width/16, rngmod(height/8)+width/16))
	level_noise(data[0], tile.wall, Rect2(0, 0, width, height), 1337)
	level_noise(data[0], tile.water, Rect2(width/4, height/4, width/2, height/2), 1337)
	level_noise(data[0], tile.forrest, Rect2(0, 0, width, height), 7878)
	# river
	y = height/2
	y += rngmod(160) - 80
	x = width/2	
	if (rngmod(2)):
		level_arc_fine(data[0], Vector2(x+100, y), 500, 1000, 90, 25, tile.water)
	else:
		level_arc_fine(data[0], Vector2(x-100, y), 0, 500, 90, 25, tile.water)
	# center
	level_fill_ovoid(data[0], Rect2(width/2-13,height/2-13,26,26), tile.forrest)
	level_fill_ovoid(data[0], Rect2(width/2-11,height/2-11,22,22), tile.floor)
	level_fill_ovoid(data[0], Rect2(width/2-9,height/2-9,18,18), tile.forrest)
	level_fill_ovoid(data[0], Rect2(width/2-5,height/2-5,10,10), tile.floor)
	# stair spaces
	s = 17
	# top left
	x = width/5 + rngmod(width/8)
	y = height/6 + rngmod(height/8)
	rooms.append(Rect2(x, y, s, s))
	level_fill_rounded(data[0], Rect2(x, y, s, s), tile.floor)
	level_fill_rounded(data[0], Rect2(x+4, y+4, s-8, s-8), tile.forrest)
	level_fill_rounded(data[0], Rect2(x+6, y+6, s-12, s-12), tile.floor)
	level_carve_path(data[0], Vector2(x+s/2, y+s/2), Vector2(width/2, height/2))
	level_carve_path(data[0], Vector2(x+s/2, y+s/2+1), Vector2(width/2-1, height/2))
	level_carve_corridor(data[0], Vector2(x+s/2, y+s/2), Vector2(width/2, height/2))
	stairs.append(Vector2(x+s/2, y+s/2))
	data_write(data[0], x+s/2, y+s/2, tile.stair_down)
	# top right
	x = width - width/5 - rngmod(width/8) - s
	y = height/6 + rngmod(height/8)
	rooms.append(Rect2(x, y, s, s))
	level_carve_rounded(data[0], Rect2(x, y, s, s))
	level_fill_rounded(data[0], Rect2(x+4, y+4, s-8, s-8), tile.forrest)
	level_fill_rounded(data[0], Rect2(x+6, y+6, s-12, s-12), tile.floor)
	level_carve_path(data[0], Vector2(x+s/2, y+s/2), Vector2(width/2, height/2))
	level_carve_path(data[0], Vector2(x+s/2, y+s/2+1), Vector2(width/2+1, height/2))
	level_carve_corridor(data[0], Vector2(x+s/2, y+s/2), Vector2(width/2, height/2))
	stairs.append(Vector2(x+s/2, y+s/2))
	data_write(data[0], x+s/2, y+s/2, tile.stair_down)
	# bottom right
	x = width - width/5 - rngmod(width/8) - s
	y = height - height/6 - rngmod(height/8) - s
	rooms.append(Rect2(x, y, s, s))
	level_carve_rounded(data[0], Rect2(x, y, s, s))
	level_fill_rounded(data[0], Rect2(x+4, y+4, s-8, s-8), tile.forrest)
	level_fill_rounded(data[0], Rect2(x+6, y+6, s-12, s-12), tile.floor)
	level_carve_path(data[0], Vector2(x+s/2, y+s/2), Vector2(width/2, height/2))
	level_carve_path(data[0], Vector2(x+s/2, y+s/2-1), Vector2(width/2+1, height/2))
	level_carve_corridor(data[0], Vector2(x+s/2, y+s/2), Vector2(width/2, height/2))
	stairs.append(Vector2(x+s/2, y+s/2))
	data_write(data[0], x+s/2, y+s/2, tile.stair_down)
	# bottom left
	x = width/5 + rngmod(width/8)
	y = height - height/6 - rngmod(height/8) - s
	rooms.append(Rect2(x, y, s, s))
	level_carve_rounded(data[0], Rect2(x, y, s, s))
	level_fill_rounded(data[0], Rect2(x+4, y+4, s-8, s-8), tile.forrest)
	level_fill_rounded(data[0], Rect2(x+6, y+6, s-12, s-12), tile.floor)
	level_carve_path(data[0], Vector2(x+s/2, y+s/2), Vector2(width/2, height/2))
	level_carve_path(data[0], Vector2(x+s/2, y+s/2-1), Vector2(width/2-1, height/2))
	level_carve_corridor(data[0], Vector2(x+s/2, y+s/2), Vector2(width/2, height/2))
	stairs.append(Vector2(x+s/2, y+s/2))
	data_write(data[0], x+s/2, y+s/2, tile.stair_down)
	
	
	# level 2
	#level_carve_elipse(data[1], Rect2(20,20,100,70))
	#level_arc(data[1], Vector2(width/2, height/2), 0, 90, 25, 9, tile.water)
	stairs_old = stairs
	stairs = []
	var stair_different = rngmod(4)
	s = stair_different
	stair = Vector2(stairs_old[s].x -2, stairs_old[s].y -2)
	stairs.append(stair)
	level_carve_hallway(data[1], Vector2(stair.x - 4, stair.y - 4), true, 12, 4, Vector2(3,3), Vector2(3,3))
	level_carve_hallway(data[1], Vector2(stair.x - 4, stair.y - 4), false, 12, 4, Vector2(3,3), Vector2(3,3))
	data_write(data[1], stairs_old[s].x, stairs_old[s].y, tile.stair_up)
	data_write(data[1], stair.x, stair.y, tile.stair_down)
	for i in 4:
		var temp_s = (s + i) % 4
		var next_s = (temp_s + 1) % 4
		if (temp_s == stair_different):
			continue
		if (temp_s == 0):
			level_carve_rect(data[1], Rect2(stairs_old[temp_s].x-5, stairs_old[temp_s].y-5, 11, 11))
			d = stairs_old[next_s].x - stairs_old[temp_s].x
			r = d / 5
			if (temp_s != (s+3)%4):
				level_carve_rect(data[1], Rect2(stairs_old[temp_s].x, stairs_old[temp_s].y-1, d, 3))
				level_carve_corridor(data[1], Vector2(stairs_old[temp_s].x+d, stairs_old[temp_s].y), Vector2(stairs_old[next_s].x+1, stairs_old[next_s].y+1))
				level_carve_hallway(data[1], Vector2(stairs_old[temp_s].x+11, stairs_old[temp_s].y-2), false, 5, r, Vector2(3,3), Vector2(3,3))
			data_write(data[1], stairs_old[temp_s].x, stairs_old[temp_s].y, tile.stair_up)
		if (temp_s == 1):
			level_carve_rect(data[1], Rect2(stairs_old[temp_s].x-5, stairs_old[temp_s].y-5, 11, 11))
			d = stairs_old[next_s].y - stairs_old[temp_s].y
			r = d / 5
			if (temp_s != (s+3)%4):
				level_carve_rect(data[1], Rect2(stairs_old[temp_s].x-1, stairs_old[temp_s].y, 3, d))
				level_carve_corridor(data[1], Vector2(stairs_old[temp_s].x+1, stairs_old[temp_s].y+d), Vector2(stairs_old[next_s].x, stairs_old[next_s].y+1))
				level_carve_hallway(data[1], Vector2(stairs_old[temp_s].x-2, stairs_old[temp_s].y+9), true, 5, r, Vector2(3,3), Vector2(3,3))
			data_write(data[1], stairs_old[temp_s].x, stairs_old[temp_s].y, tile.stair_up)
		if (temp_s == 2):
			level_carve_rect(data[1], Rect2(stairs_old[temp_s].x-5, stairs_old[temp_s].y-5, 11, 11))
			d = stairs_old[temp_s].x - stairs_old[next_s].x
			r = d / 5
			if (temp_s != (s+3)%4):
				level_carve_rect(data[1], Rect2(stairs_old[temp_s].x-d, stairs_old[temp_s].y-1, d, 3))
				level_carve_corridor(data[1], Vector2(stairs_old[temp_s].x-d, stairs_old[temp_s].y+1), Vector2(stairs_old[next_s].x+1, stairs_old[next_s].y))
				level_carve_hallway(data[1], Vector2(stairs_old[temp_s].x-d+11, stairs_old[temp_s].y-2), false, 5, r, Vector2(3,3), Vector2(3,3))
			data_write(data[1], stairs_old[temp_s].x, stairs_old[temp_s].y, tile.stair_up)
		if (temp_s == 3):
			level_carve_rect(data[1], Rect2(stairs_old[temp_s].x-5, stairs_old[temp_s].y-5, 11, 11))
			d = stairs_old[temp_s].y - stairs_old[next_s].y 
			r = d / 5
			if (temp_s != (s+3)%4):
				level_carve_rect(data[1], Rect2(stairs_old[temp_s].x-1, stairs_old[temp_s].y-d, 3, d))
				level_carve_corridor(data[1], Vector2(stairs_old[temp_s].x+1, stairs_old[temp_s].y-d), Vector2(stairs_old[next_s].x, stairs_old[next_s].y+1))
				level_carve_hallway(data[1], Vector2(stairs_old[temp_s].x-2, stairs_old[temp_s].y-d+9), true, 5, r, Vector2(3,3), Vector2(3,3))
			data_write(data[1], stairs_old[temp_s].x, stairs_old[temp_s].y, tile.stair_up)
		if (temp_s == (stair_different+2)%4):
			x = stairs_old[temp_s].x
			y = stairs_old[temp_s].y
			if (temp_s == 0):
				x -= 2
				y -= 2
			if (temp_s == 1):
				x += 2
				y -= 2
			if (temp_s == 2):
				x += 2
				y += 2
			if (temp_s == 3):
				x -= 2
				y += 2
			stair = Vector2(x, y)
			stairs.append(stair)
			data_write(data[1], stair.x, stair.y, tile.stair_down)
		
	
	
	# level 3
	#level_fill_ovoid(data[2], Rect2(20,20,50,70), tile.floor)
	stairs_old = stairs
	stairs = []
	stair = Vector2(stairs_old[0].x +2, stairs_old[0].y +2)
	stairs.append(stair);
	level_carve_hallway(data[2], Vector2(stair.x - 6, stair.y - 6), true, 13, 7, Vector2(3,3), Vector2(3,1))
	level_carve_hallway(data[2], Vector2(stair.x - 6, stair.y - 6), false, 13, 7, Vector2(3,3), Vector2(1,3))
	data_write(data[2], stairs_old[0].x, stairs_old[0].y, tile.stair_up)
	data_write(data[2], stair.x, stair.y, tile.stair_down)
	#2nd room
	level_noise(data[2], tile.water, Rect2(stairs_old[1].x - 25, stairs_old[1].y - 25, 50, 50), 3000)
	level_fill_ovoid(data[2], Rect2(stairs_old[1].x - 15, stairs_old[1].y - 15, 30, 30), tile.floor)
	level_noise(data[2], tile.water, Rect2(stairs_old[1].x - 15, stairs_old[1].y - 15, 30, 30), 27)
	stair = Vector2(stairs_old[1].x +2, stairs_old[1].y +2)
	level_carve_path(data[3], stairs_old[1], stair)
	data_write(data[2], stairs_old[1].x, stairs_old[1].y, tile.stair_up)
	data_write(data[2], stair.x, stair.y, tile.stair_down)
	stairs.append(stair);
	
	# level 4
	#level_carve_rounded(data[3], Rect2(30,20,90,50))
	stairs_old = stairs
	stairs = []
	stair = Vector2(stairs_old[0].x -2, stairs_old[0].y -2)
	stairs.append(stair);
	level_carve_hallway(data[3], Vector2(stair.x - 5, stair.y - 5), true, 14, 5, Vector2(3,3), Vector2(4,3))
	level_carve_hallway(data[3], Vector2(stair.x - 5, stair.y - 5), false, 14, 5, Vector2(3,3), Vector2(3,5))
	data_write(data[3], stairs_old[0].x, stairs_old[0].y, tile.stair_up)
	data_write(data[3], stair.x, stair.y, tile.stair_down)
	#2nd room
	level_noise(data[3], tile.water, Rect2(stairs_old[1].x - 25, stairs_old[1].y - 25, 50, 50), 3000)
	level_fill_ovoid(data[3], Rect2(stairs_old[1].x - 10, stairs_old[1].y - 10, 20, 20), tile.floor)
	level_noise(data[3], tile.water, Rect2(stairs_old[1].x - 10, stairs_old[1].y - 10, 20, 20), 157)
	stair = Vector2(stairs_old[1].x +2, stairs_old[1].y +2)
	level_carve_path(data[3], stairs_old[1], stair)
	data_write(data[3], stairs_old[1].x, stairs_old[1].y, tile.stair_up)
	data_write(data[3], stair.x, stair.y, tile.stair_down)
	stairs.append(stair);
	
	
	# level 5
	stairs_old = stairs
	stairs = []
	rooms = []
	for i in 9:
		if i == 0:
			rooms.append(Rect2(stairs_old[0].x - 5, stairs_old[0].y - 5, 10, 10))
		else:
			if i == 5:
				rooms.append(Rect2(stairs_old[1].x - 5, stairs_old[1].y - 5, 10, 10))
			else:
				rooms.append(Rect2(rngmod(width-30)+5, rngmod(height-25)+5, 5+rngmod(20), 5+rngmod(15)))
	for room in rooms:
		level_carve_elipse(data[4], room)
	level_noise(data[4], tile.water, Rect2(0, 0, width, height), 1111)
	for i in 9:
		if i != 0:
			level_carve_corridor(data[4], rooms[i-1].get_center(), rooms[i].get_center())
	data_write(data[4], stairs_old[0].x, stairs_old[0].y, tile.stair_up)
	data_write(data[4], stairs_old[1].x, stairs_old[1].y, tile.stair_up)
	stairs.append(Vector2(rooms[8].get_center().x, rooms[8].get_center().y))
	data_write(data[4], stairs[0].x, stairs[0].y, tile.stair_down)
		
		
	# level 6
	stairs_old = stairs
	stairs = []
	rooms = []
	for i in 12:
		if i == 0:
			rooms.append(Rect2(stairs_old[0].x - 5, stairs_old[0].y - 5, 10, 10))
		else:
				rooms.append(Rect2(rngmod(width-30)+5, rngmod(height-25)+5, 3+rngmod(7), 3+rngmod(5)))
	for room in rooms:
		level_carve_elipse(data[5], room)
	level_noise(data[5], tile.acid, Rect2(0, 0, width, height), 1111)
	level_noise(data[5], tile.water, Rect2(0, 0, width, height), 3111)
	for i in 12:
		if i != 0:
			level_carve_corridor(data[5], rooms[i-1].get_center(), rooms[i].get_center())
	data_write(data[5], stairs_old[0].x, stairs_old[0].y, tile.stair_up)
	stairs.append(Vector2(rooms[11].get_center().x, rooms[11].get_center().y))
	data_write(data[5], stairs[0].x, stairs[0].y, tile.stair_down)
	
	
	# level 7
	stairs_old = stairs
	stairs = []
	level_carve_rounded(data[6], Rect2(5,5,width-10,height-10))
	level_noise(data[6], tile.acid, Rect2(0,0,width,height), 3333)
	level_noise(data[6], tile.acid, Rect2(12,12,width-12,height-12), 3333)
	level_noise(data[6], tile.water, Rect2(0,0,width,height), 1111)
	for i in 24:
		level_carve_path(data[6], Vector2(rngmod(width-24)+12,rngmod(height-24)+12), Vector2(rngmod(width-24)+12,rngmod(height-24)+12))
	stairs.append(Vector2(width - stairs_old[0].x, height - stairs_old[0].y))
	level_carve_path(data[6], stairs_old[0], stairs[0])
	data_write(data[6], stairs_old[0].x, stairs_old[0].y, tile.stair_up)
	data_write(data[6], stairs[0].x, stairs[0].y, tile.stair_down)
		
	
	# level 8
	stairs_old = stairs
	stairs = []
	level_carve_hallway(data[7], Vector2(72, 10), true, 2, 9, Vector2(5,3), Vector2(2,3))
	level_carve_hallway(data[7], Vector2(32, 10), true, 3, 13, Vector2(5,3), Vector2(7,7))
	level_carve_hallway(data[7], Vector2(115, 7), true, 1, 27, Vector2(3,3), Vector2(17,5))
	level_carve_hallway(data[7], Vector2(10, 70), false, 5, 17, Vector2(3,7), Vector2(5, 5))
	level_carve_corridor(data[7], Vector2(stairs_old[0].x, stairs_old[0].y), Vector2(72,10))
	data_write(data[7], stairs_old[0].x, stairs_old[0].y, tile.stair_up)
	level_carve_corridor(data[7], Vector2(72, 10), Vector2(32, 10))
	level_carve_corridor(data[7], Vector2(72, 10), Vector2(115, 7))
	level_carve_corridor(data[7], Vector2(72, 10), Vector2(10, 70))
	# stair down
	level_carve_corridor(data[7], Vector2(72, 10), Vector2(width/2, height/2))
	stairs.append(Vector2(width/2, height/2))
	data_write(data[7], stairs[0].x, stairs[0].y, tile.stair_down)
	
	# level 9
	stairs_old = stairs
	level_carve_rounded(data[8], Rect2(width/2-30,height/2-10,60,20))
	level_carve_elipse(data[8], Rect2(10,10,20,20))
	level_carve_elipse(data[8], Rect2(width-30,10,20,30))
	level_carve_elipse(data[8], Rect2(10,60,20,20))
	level_carve_elipse(data[8], Rect2(width-30,height-30,20,20))
	level_noise(data[8], tile.wall, Rect2(10, 10, width-20, height-20), 1000)
	level_carve_corridor(data[8], Vector2(15,15), Vector2(width/2-20,height/2-5))
	level_carve_corridor(data[8], Vector2(width-15,15), Vector2(width/2+20,height/2-5))
	level_carve_path(data[8], Vector2(width/2,height/2), Vector2(width-20,height-20))
	level_carve_path(data[8], Vector2(width/2,height/2), Vector2(20,height-20))
	data_write(data[8], stairs_old[0].x, stairs_old[0].y, tile.stair_up)
	# donezo
	return data
	
	
func level_arc(data: Array, origin: Vector2, start: int, end: int, radius: int, width: int, tile_type: int):
	var d = start if (start < end) else end
	for i in width:
		if (start > end):
			for j in (start - end):
				data_write(data, origin.x + sin(((end+j)/360.0)*TAU)*(radius+i), origin.y + cos(((end+j)/360.0)*TAU)*(radius+i), tile_type)
		else:
			for j in (end - start):
				data_write(data, origin.x + sin(((start+j)/360.0)*TAU)*(radius+i), origin.y + cos(((start+j)/360.0)*TAU)*(radius+i), tile_type)
		
func level_arc_fine(data: Array, origin: Vector2, start: int, end: int, radius: int, width: int, tile_type: int):
	var d = start if (start < end) else end
	for i in width:
		if (start > end):
			for j in (start - end):
				data_write(data, origin.x + sin(((end+j)/1000.0)*TAU)*(radius+i), origin.y + cos(((end+j)/1000.0)*TAU)*(radius+i), tile_type)
		else:
			for j in (end - start):
				data_write(data, origin.x + sin(((start+j)/1000.0)*TAU)*(radius+i), origin.y + cos(((start+j)/1000.0)*TAU)*(radius+i), tile_type)
		
	
func level_fill(data: Array, type: int):
	for x in width:
		for y in height:
			data[x][y] = type
	pass
	
func level_noise(data: Array, type: int, rect: Rect2, amount: int):
	for i in amount:
		data_write(data, rect.position.x+(rng_next_int()%int(rect.size.x)), rect.position.y+(rng_next_int()%int(rect.size.y)), type)
		
func level_fill_ovoid(data: Array, rect: Rect2, tile_type: int):
	var mid = rect.size.x / 2
	for y in rect.size.y:
		var length = sin((y / rect.size.y)*PI)
		length *= length
		length *= mid
		for x in length:
			if (x+rect.position.x+mid < width and y+rect.position.y < height):
				data_write(data, x+rect.position.x+mid, y+rect.position.y, tile_type)
				data_write(data, (mid-x)+rect.position.x, y+rect.position.y, tile_type)
	
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
					data[x+rect.position.x+mid][y+rect.position.y] = tile.floor
					data[(mid-x)+rect.position.x][y+rect.position.y] = tile.floor
	
func level_fill_rounded(data: Array, rect: Rect2, tile_type: int):
	var mid = rect.size.x / 2
	for a in 180:
		var length = ceil((sin((a/180.0)*PI) * 0.5 + 0.5) * mid)
		var y = (cos((a/180.0)*PI) * 0.5 + 0.5) * rect.size.y
		for x in length:
			if (x+rect.position.x+mid < width and y+rect.position.y < height):
				data_write(data, x+rect.position.x+mid, y+rect.position.y, tile_type)
				data_write(data, (mid-x)+rect.position.x, y+rect.position.y, tile_type)
				
func level_carve_rounded(data: Array, rect: Rect2):
	var mid = rect.size.x / 2
	for a in 180:
		var length = ceil((sin((a/180.0)*PI) * 0.5 + 0.5) * mid)
		var y = (cos((a/180.0)*PI) * 0.5 + 0.5) * rect.size.y
		for x in length:
			if (x+rect.position.x+mid < width and y+rect.position.y < height):
				data[x+rect.position.x+mid][y+rect.position.y] = tile.floor
				data[(mid-x)+rect.position.x][y+rect.position.y] = tile.floor

func level_carve_rect(data: Array, rect: Rect2):
	for x in rect.size.x:
		for y in rect.size.y:
			data_write(data, x+rect.position.x, y+rect.position.y, tile.floor)

func level_carve_path(data: Array, start: Vector2, end: Vector2):
	if (start.x < end.x):
		for x in (end.x - start.x + 1):
			data_write(data, x + start.x, start.y, tile.floor)
	else:
		for x in (start.x - end.x):
			data_write(data, x + end.x, start.y, tile.floor)
	if (start.y < end.y):
		for y in (end.y - start.y):
			data_write(data, end.x, y + start.y, tile.floor)
	else:
		for y in (start.y - end.y):
			data_write(data, end.x, y + end.y, tile.floor)
		
func level_carve_corridor(data: Array, start: Vector2, end: Vector2):
	var diff = end - start
	var steps = max(abs(diff.x), abs(diff.y))
	var step_x = diff.x / steps
	var step_y = diff.y / steps
	var current_pos = start
	for i in range(1,steps):
		current_pos += Vector2(step_x, step_y)
		var x = round(current_pos.x)
		var y = round(current_pos.y)
		data_write(data, x, y, tile.floor)
		data_write(data, x+1, y, tile.floor)
		data_write(data, x-1, y, tile.floor)
		data_write(data, x, y+1, tile.floor)
		data_write(data, x, y-1, tile.floor)
	return
		
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
			data_write(data, room.position.x + room_w, room.position.y + rng_next_int()%int(room_h-2)+1, tile.door) # door
			pos += room_h + 1
		max_y = pos
		# do west rooms
		pos = 0
		for i in ceil(room_count/2):
			var room_w = room_min.x + (rng_next_int()%int(room_rng.x))
			var room_h = room_min.y + (rng_next_int()%int(room_rng.y))
			var room = Rect2(start.x + hall_width + 1, start.y + pos, room_w, room_h)
			level_carve_rect(data, room)
			data_write(data, room.position.x - 1, room.position.y + rng_next_int()%int(room_h-2)+1, tile.door) # door
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
			data_write(data, room.position.x + rng_next_int()%int(room_w-2)+1, room.position.y + room_h, tile.door) # door
			pos += room_w + 1
		max_x = pos
		# do south rooms
		pos = 0
		for i in ceil(room_count/2):
			var room_w = room_min.x + (rng_next_int()%int(room_rng.x))
			var room_h = room_min.y + (rng_next_int()%int(room_rng.y))
			var room = Rect2(start.x + pos, start.y + hall_width + 1, room_w, room_h)
			level_carve_rect(data, room)
			data_write(data, room.position.x + rng_next_int()%int(room_w-2)+1, room.position.y - 1, tile.door) # door
			pos += room_w + 1
		# tie them together
		if (max_x < pos):
				max_x = pos
		level_carve_rect(data, Rect2(start.x, start.y, max_x-1, hall_width))
		pass
