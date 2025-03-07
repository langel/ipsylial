class_name Barbarian
extends Baddy

func _init(pos: Vector2, baddy_type: Baddy.BaddyType = Baddy.BaddyType.BARB):
	super(pos, baddy_type)
	self.num_variations = 6
	self.variation_coords = [Vector2(0,3),Vector2(1,3),Vector2(2,3),Vector2(3,3),Vector2(4,3),Vector2(5,3)]
	self.variation = (GameState.rng_next_int())%self.num_variations

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
