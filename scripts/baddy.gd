class_name Baddy
extends Node

var x: int = 0
var y: int = 0
enum BaddyType { BLORX, FURD, DRAKE }
var type: BaddyType = BaddyType.BLORX  # Default type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
