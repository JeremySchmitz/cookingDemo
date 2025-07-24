extends Node2D

@onready var label: Label = $Label

@export var labelName := ''

var mouse_over
			
func _ready() -> void:
	label.text = labelName
	
	connect("mouse_entered", _mouse_over.bind(true))
	connect("mouse_exited", _mouse_over.bind(false))

func _unhandled_input(event: InputEvent):
	if (event is InputEventMouseButton and
		mouse_over and
		event.pressed):
		Utils.dockSelected.emit(global_position)
		
func _mouse_over(value):
	mouse_over = value
