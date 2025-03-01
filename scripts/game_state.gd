extends Node

signal player_moved(new_position: Vector2i)
signal turn_ended

const DEFAULT_RNG_POS = 0x13371ee7
const TILE_SIZE: int = 32

var hp = 15
var player_position: Vector2i = Vector2i(0, 0)

var map: Map
var baddies: Array[Baddy] = []
var items: Array[Item] = []

var pos: int = DEFAULT_RNG_POS
var seedval: int = 0x1ee71337
var rng = load("res://scripts/rng.gd").new()

var turn_active: bool = true

func start_game() -> void:
	player_position = Vector2i(0, 0)
	hp = 15
	map = new_map()
	baddies = new_baddies()

func new_baddies():
	var baddies: Array[Baddy] = []
	var num_baddies = 5 + rng_next_int()%10
	for i in range(0,num_baddies):
		baddies.append(Baddy.new(Vector2i(rng_next_int()%map.width,rng_next_int()%map.height)))
		baddies[i].baddy_type = baddies[i].get_random_baddy_type()
	return baddies

func rng_next_int() -> int:
	pos += 1
	return rng.rng(pos, seedval)

func new_map() -> Map:
	return Map.new(40, 40)

func move_player(direction: Vector2i):
	if !turn_active:
		return  

	var new_pos = player_position + direction

	if new_pos.x < 0 or new_pos.x >= map.width or new_pos.y < 0 or new_pos.y >= map.height:
		return
	if map.tiles[new_pos.x][new_pos.y].type != Tile.TileType.FLOOR:
		return

	player_position = new_pos
	player_moved.emit(new_pos)

	end_turn()

func end_turn():
	turn_active = false
	turn_ended.emit()
