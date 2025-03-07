class_name Knight
extends Baddy


func _init(pos: Vector2, baddy_type: Baddy.BaddyType = Baddy.BaddyType.KNIGHT):
	super(pos, baddy_type)
	self.num_variations = 5
	self.variation_coords = [Vector2(0,2),Vector2(1,2),Vector2(2,2),Vector2(3,2),Vector2(4,2)]
	self.variation = (GameState.rng_next_int())%self.num_variations


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
