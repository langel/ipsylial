extends Node

var display_hp = 15
var display_turn = 1
var display_floor = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_labels()
	pass # Replace with function body.

func update_labels() -> void:
	var hp_label = $VBoxContainer/HpLabel
	var floor_label = $VBoxContainer/FloorLabel
	var turn_label = $VBoxContainer/TurnLabel
	hp_label.text = "Health: " + str(display_hp)
	floor_label.text = "Floor: " + str(display_floor)
	turn_label.text = "Turn: " + str(display_turn)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
