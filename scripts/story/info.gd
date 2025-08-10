extends Node2D
class_name Info

@onready var label: Label = $Label
@export var labelText := ""

var text: String: set = _setText

# TODO Flip if not visible

func _ready() -> void:
	if Engine.is_editor_hint(): return
	text = "This \n test text"

func _setText(val: String) -> void:
	text = val;
	label.text = val
