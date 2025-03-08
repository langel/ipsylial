class_name Barbarian
extends Baddy

func _init(pos: Vector2, baddy_type: Baddy.BaddyType = Baddy.BaddyType.BARB):
	super(pos, baddy_type)
	self.num_variations = 6
	self.variation_coords = [Vector2(0,3),Vector2(1,3),Vector2(2,3),Vector2(3,3),Vector2(4,3),Vector2(5,3)]
	self.variation = (GameState.rng_next_int())%self.num_variations
	self.attack_frequency = 2
	self.aggression_area = 10
	self.behavior_change_freq = 2
	self.damage = 2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func more_behavior(is_player, is_item):
	if behavior == BaddyBehavior.STARTLED:
		if is_player:
			set_behavior(BaddyBehavior.CONFIDENT)
	if behavior == BaddyBehavior.SEEKING:
		if is_player:
			set_behavior(BaddyBehavior.CONFIDENT)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
