extends Node

var baddy: Baddy
var max_hp: int = 1  # Will be set when update_baddy() is called

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	pass # Replace with function body.

func update_baddy(baddy: Baddy):
	var sprite: Sprite2D = $Sprite2D
	var hp_bar: ColorRect = $HPBar  # Ensure HPBar exists in the scene

	self.baddy = baddy
	self.baddy.scene = self
	sprite.texture = baddy.get_texture_for_type()

	# Set max HP based on the baddy's initial HP
	max_hp = baddy.hp

	# Set HP bar size and color
	hp_bar.color = Color(0, 1, 0, 1)  # Green for full health
	hp_bar.visible = false  # Ensure the HP bar is visible
	hp_bar.position.y = 26	
	hp_bar.position.x = 0
	#hp_bar.size.x = 32

	# Connect signals to their handlers
	if not self.baddy.baddy_attacks.is_connected(_on_baddy_attacks):
		self.baddy.baddy_attacks.connect(_on_baddy_attacks)
	
	if not self.baddy.baddy_damaged.is_connected(_on_baddy_damaged):
		self.baddy.baddy_damaged.connect(_on_baddy_damaged)
	
	if not self.baddy.died.is_connected(_on_baddy_died):
		self.baddy.died.connect(_on_baddy_died)
	

func update_state():
	var label = $Label
	match self.baddy.behavior:
		Baddy.BaddyBehavior.CHILL:
			label.text = ".."
		Baddy.BaddyBehavior.SEEKING:
			label.text = "+"
		Baddy.BaddyBehavior.CONFIDENT:
			label.text = "*"
		Baddy.BaddyBehavior.STARTLED:
			label.text = "!"
		Baddy.BaddyBehavior.ATTACKING:
			label.text = "#"
		Baddy.BaddyBehavior.FRIGHTENED:
			label.text = "@"

# Signal Handlers with Scale Animations and HP Bar Updates
func _on_baddy_attacks(direction: Vector2):
	var sprite: Sprite2D = $Sprite2D
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.1).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(sprite, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_ELASTIC)

func _on_baddy_damaged():
	var sprite: Sprite2D = $Sprite2D
	var hp_bar: ColorRect = $HPBar  # Reference the HP bar
	hp_bar.visible = true
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(0.8, 0.8), 0.1).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(sprite, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_ELASTIC)

	# Update HP bar width
	var new_width = 32 * (float(baddy.hp) / max_hp)
	hp_bar.size.x = max(0, new_width)
	hp_bar.position.y = 26
	hp_bar.position.x = 0

	# Change HP bar color based on health percentage
	if baddy.hp > max_hp * 0.5:
		hp_bar.color = Color(0, 1, 0, 1)  # Green
	elif baddy.hp > max_hp * 0.25:
		hp_bar.color = Color(1, 1, 0, 1)  # Yellow
	else:
		hp_bar.color = Color(1, 0, 0, 1)  # Red

func _on_baddy_died():
	var sprite: Sprite2D = $Sprite2D
	var hp_bar: ColorRect = $HPBar

	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(0, 0), 0.5).set_trans(Tween.TRANS_BACK)
	await tween.finished

	hp_bar.hide()  # Hide the HP bar on death

	queue_free()  # Remove the node after the animation completes
