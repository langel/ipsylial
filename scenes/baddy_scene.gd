extends Node

var baddy : Baddy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func update_baddy(baddy: Baddy):
	var sprite: Sprite2D = $Sprite2D
	self.baddy = baddy
	sprite.texture = baddy.get_texture_for_type(baddy.baddy_type)
