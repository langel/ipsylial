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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
