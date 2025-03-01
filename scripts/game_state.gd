extends Node

const DEFAULT_RNG_POS = 0x13371ee7

var start_time: float = 0.0

var hp = 15
var x: int = 0
var y: int = 0

var map: Array[Array] = []
var baddies: Array[Baddy] = []
var items: Array[Array] = []

#rng args for each game / seed
var pos: int = 0x13371ee7
var seedval: int = DEFAULT_RNG_POS
var rng = load("res://scripts/rng.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func start_game() -> void:
	x = 0
	y = 0
	hp = 15
	map = new_map()
	#reset_rng()

func reset_rng() -> void:
	seedval = randi()
	pos = DEFAULT_RNG_POS

func rng_next_int() -> int:
	pos+=1
	return rng.rng(pos,seedval)

func new_map() -> Array[Array]:
	return []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
