extends Node

var display_hp = 15
var display_hp_max = 15
var display_damage = 1
var display_depth = 1
var display_turn = 0

var right_label
var left_label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var width = ProjectSettings.get("display/window/size/viewport_width")/2
	var hbox1 = $VBoxLeft
	hbox1.position = Vector2(-width+30, 10)  
	hbox1.size = Vector2(200,100)
	var hbox2 = $VBoxRight
	hbox2.position = Vector2(width+103, 0)  
	hbox2.size = Vector2(200,100)
	update_labels()
	pass # Replace with function body.

func update_labels() -> void:
	var hp_label = $VBoxLeft/HpLabel
	var dmg_label = $VBoxLeft/DamageLabel
	hp_label.text = "Health: " + str(display_hp) + "/" + str(display_hp_max)
	dmg_label.text = "Damage: " + str(display_damage)	
	var depth_label = $VBoxRight/DepthLabel
	var turn_label = $VBoxRight/TurnLabel
	depth_label.text = "Dungeon Depth " + str(display_depth)
	turn_label.text = str(display_turn) + " Turns"
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
