class_name Item
extends Node

var grid_position: Vector2 = Vector2(0,0)
var interactable: bool = false
var traversable: bool = true
enum ItemType { STONE, BEER, DUCK_FOOD }
var type: ItemType = ItemType.STONE  # Default type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
