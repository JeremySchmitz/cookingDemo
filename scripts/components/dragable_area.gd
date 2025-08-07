class_name DraggableArea

extends Area2D

var draggable: bool = true
var lifted = false
var mouse_over = false
var offset := Vector2(0, 0)
var camMoving = false
var parented = true;

@export var weight := 1.0

func _ready():
	SignalBus.modeChange.connect(_on_mode_change)
	SignalBus.stopDrag.connect(_drop)
	SignalBus.cameraMove.connect(_on_camera_move)
	SignalBus.cameraStop.connect(_on_camera_stop)
	
	connect("mouse_entered", _mouse_over.bind(true))
	connect("mouse_exited", _mouse_over.bind(false))


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
			offset = get_global_mouse_position() - get_parent().global_position
			
		if event is InputEventMouseButton and not event.pressed:
			lifted = false
			SignalBus.drop.emit()
			
		if lifted and event is InputEventMouseMotion:
			_set_position()
			get_viewport().set_input_as_handled()

func _set_position():
	get_parent().global_position = get_global_mouse_position() - offset
	get_local_mouse_position()
	_dragging()
	SignalBus.dragging.emit(weight)
	
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

func _dragging() -> void:
	if Engine.is_editor_hint() || !parented: return
	var kitchen = get_node("/root/Kitchen")
	get_parent().reparent(kitchen)
	parented = false

	var parent = get_parent()
	for sibling in parent.get_children():
		if sibling is Nutrition:
			sibling.parented = false

func _drop():
	lifted = false
	SignalBus.drop.emit()
