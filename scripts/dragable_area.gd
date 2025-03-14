class_name DraggableArea

extends Area2D

var draggable: bool = true
var lifted = false

func _ready() -> void:
	Signals.modeChange.connect(_on_mode_change)

func _unhandled_input(event):
	if draggable:
		if event is InputEventMouseButton and not event.pressed:
			lifted = false
		if lifted and event is InputEventMouseMotion:
			get_parent().position += event.relative

func _input_event(_viewport, event, _shape_idx):
	if draggable:
		if event is InputEventMouseButton and event.pressed:
			lifted = true

func _on_mode_change(m: GlobalEnums.Mode):
	match m:
		GlobalEnums.Mode.GRAB:
			draggable = true
		_:
			draggable = false
