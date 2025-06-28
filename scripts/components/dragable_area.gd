class_name DraggableArea

extends Area2D

var draggable: bool = true
var lifted = false
var mouse_over = false
var offset := Vector2(0,0)
var camMoving = false
signal dragging()

func _ready():
	Signals.modeChange.connect(_on_mode_change)
	Signals.cameraMove.connect(_on_camera_move)
	Signals.cameraStop.connect(_on_camera_stop)
	
	connect("mouse_entered", _mouse_over.bind(true))
	connect("mouse_exited", _mouse_over.bind(false))

	set_process_unhandled_input(true)
	
func _process(delta: float) -> void:
	if camMoving and lifted:
		_set_position()

func _unhandled_input(event):
	if draggable:
		if (mouse_over 
			and event is InputEventMouseButton 
			and event.button_index == MOUSE_BUTTON_LEFT 
			and event.pressed
		):
			lifted = true
			offset = get_global_mouse_position() - get_parent().position
			
		if event is InputEventMouseButton and not event.pressed:
			lifted = false
			
		if lifted and event is InputEventMouseMotion:
			_set_position()
			get_viewport().set_input_as_handled()

func _set_position():
	get_parent().position = get_global_mouse_position() - offset
	dragging.emit()
	
func _mouse_over(value):
	mouse_over = value

func _on_mode_change(m: GlobalEnums.Mode):
	match m:
		GlobalEnums.Mode.GRAB:
			draggable = true
		_:
			draggable = false

func _on_camera_move():
	camMoving = true

func _on_camera_stop():
	camMoving = false
