class_name Farmer
extends Baddy



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _init(pos: Vector2, baddy_type: Baddy.BaddyType = Baddy.BaddyType.FARMER):
	super(pos, baddy_type)
	self.num_variations = 5
	self.variation_coords = [Vector2(0,5),Vector2(1,5),Vector2(2,5),Vector2(3,5),Vector2(4,5)]
	self.variation = (GameState.rng_next_int())%self.num_variations
	self.attack_frequency = 3
	self.aggression_area = 5
	self.behavior_change_freq = 3
	self.damage = 1

func more_behavior(is_player, is_item):
	if behavior == BaddyBehavior.CHILL:
		if is_player:
			set_behavior(BaddyBehavior.STARTLED)
	elif behavior == BaddyBehavior.STARTLED:
		if is_item:
			set_behavior(BaddyBehavior.SEEKING)
		elif is_player:
			set_behavior(BaddyBehavior.CONFIDENT)
	elif behavior == BaddyBehavior.SEEKING:
		if not is_item:
			if is_player:
				set_behavior(BaddyBehavior.STARTLED)
			else:
				set_behavior(BaddyBehavior.CHILL)
	elif behavior == BaddyBehavior.CONFIDENT:
		if not is_player:
			if not is_item:
				set_behavior(BaddyBehavior.CHILL)
			else:
				set_behavior(BaddyBehavior.SEEKING)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
