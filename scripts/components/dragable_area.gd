class_name DraggableArea

extends Area2D

var draggable: bool = true
var lifted = false
var mouse_over = false
var offset := Vector2(0, 0)
var camMoving = false
var parented = true;

@export var weight := 1.0
@export var disabledTillCut = false
var hasBeenCut = false

func _ready():
	if disabledTillCut:
		$CollisionPolygon2D.disabled = true

	SignalBus.modeChange.connect(_on_mode_change)
	SignalBus.stopDrag.connect(_drop)
	SignalBus.cameraMove.connect(_on_camera_move)
	SignalBus.cameraStop.connect(_on_camera_stop)
	
	connect("mouse_entered", _mouse_over.bind(true))
	connect("mouse_exited", _mouse_over.bind(false))


func _process(delta: float) -> void:
	if camMoving and lifted:
		_set_position()

func chopped():
	if !hasBeenCut: hasBeenCut = true

func _unhandled_input(event):
	# we stop listening cause if we disable the collider we cant cut
	if disabledTillCut and !hasBeenCut: return

	if draggable:
		var handled = false
		if (mouse_over
			and event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			lifted = true
			offset = get_global_mouse_position() - get_parent().global_position
			handled = true
			
		if event is InputEventMouseButton and not event.pressed:
			lifted = false
			_stopDragging()
			SignalBus.drop.emit()
			handled = true
			get_viewport().set_input_as_handled()
			
		if lifted and event is InputEventMouseMotion:
			_set_position()
			handled = true

		if handled: get_viewport().set_input_as_handled()

func _set_position():
	get_parent().global_position = get_global_mouse_position() - offset
	get_local_mouse_position()
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

func _stopDragging():
	if Engine.is_editor_hint() || !parented: return
	var kitchen = get_node("/root/Kitchen")
	get_parent().reparent(kitchen)
	parented = false

	var parent = get_parent()
	for sibling in parent.get_children():
		if sibling is Nutrition:
			sibling.parented = false

func _drop():
	if !lifted: return
	_stopDragging()
	lifted = false
	SignalBus.drop.emit()
