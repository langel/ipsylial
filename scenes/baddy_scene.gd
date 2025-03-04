extends Node

var baddy : Baddy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func update_baddy(baddy: Baddy):
	var sprite: Sprite2D = $Sprite2D
	self.baddy = baddy
	self.baddy.scene = self
	sprite.texture = baddy.get_texture_for_type(baddy.baddy_type)

func update_state():
	var label = $Label
	if self.baddy.behavior == Baddy.BaddyBehavior.CHILL:
		label.text = ".."
	elif self.baddy.behavior == Baddy.BaddyBehavior.SEEKING:
		label.text = "+"
	elif self.baddy.behavior == Baddy.BaddyBehavior.CONFIDENT:
		label.text = "*"
	elif self.baddy.behavior == Baddy.BaddyBehavior.STARTLED:
		label.text = "!"
