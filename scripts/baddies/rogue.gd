class_name Rogue
extends Baddy

func _init(pos: Vector2, baddy_type: Baddy.BaddyType = Baddy.BaddyType.ROGUE):
	super(pos, baddy_type)
	self.num_variations = 5
	self.variation_coords = [Vector2(0,0),Vector2(1,0),Vector2(2,0),Vector2(3,0),Vector2(4,0)]
	self.variation = self.num_variations%GameState.rng_next_int()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
