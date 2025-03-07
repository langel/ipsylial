class_name BaddyFactory


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func new_baddy(type: Baddy.BaddyType) -> Baddy:
	var baddy = Farmer.new(Vector2(0,0))
	match type:
		Baddy.BaddyType.ROGUE:
			return Rogue.new(Vector2(0,0), Baddy.BaddyType.ROGUE)
		Baddy.BaddyType.KNIGHT:
			return Knight.new(Vector2(0,0), Baddy.BaddyType.KNIGHT)
		Baddy.BaddyType.MAGE:
			return Wizard.new(Vector2(0,0), Baddy.BaddyType.MAGE)
		Baddy.BaddyType.BARB:
			return Barbarian.new(Vector2(0,0), Baddy.BaddyType.BARB)
	return baddy

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_random_baddy_type() -> Baddy.BaddyType:
	var enum_values = Baddy.BaddyType.values() 
	return enum_values[GameState.rng_next_int() % enum_values.size()]
