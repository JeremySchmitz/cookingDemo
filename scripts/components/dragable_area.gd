class_name DraggableArea

extends Area2D

var draggable: bool = true
var lifted = false
var mouse_over = false

signal dragging()

func _ready():
	Signals.modeChange.connect(_on_mode_change)
	connect("mouse_entered", _mouse_over.bind(true))
	connect("mouse_exited", _mouse_over.bind(false))

	set_process_unhandled_input(true)

func _unhandled_input(event):
	if draggable:
		if (mouse_over 
			and event is InputEventMouseButton 
			and event.button_index == MOUSE_BUTTON_LEFT 
			and event.pressed
		):
			lifted = true
			
		if event is InputEventMouseButton and not event.pressed:
			lifted = false
			
		if lifted and event is InputEventMouseMotion:
			get_parent().position += event.relative
			dragging.emit()
			get_viewport().set_input_as_handled()

func _mouse_over(value):
	mouse_over = value

func _on_mode_change(m: GlobalEnums.Mode):
	match m:
		GlobalEnums.Mode.GRAB:
			draggable = true
		_:
			draggable = false
