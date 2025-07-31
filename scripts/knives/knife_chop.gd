extends Line2D

signal strokeFinished(line: PackedVector2Array)

var _active = false
var _started = false
var _complete = false

func action(_event) -> void:
	if !_active: return
	
	if Input.is_action_just_pressed("right_click"):
		reset()
	elif Input.is_action_just_pressed("left_click") && points.size() == 2:
		_complete = true
		emit_signal("strokeFinished", points.duplicate())
		reset()
		
	elif (not _complete):
		if _started:
			set_point_position(1, get_local_mouse_position())
			
		if Input.is_action_just_pressed("left_click"):
			add_point(get_local_mouse_position())
			if (points.size() == 1):
				add_point(get_local_mouse_position())
				_started = true
		
func reset() -> void:
	_complete = false
	_started = false
	clear_points()

func _on_mode_change(m: GlobalEnums.Mode):
	match m:
		GlobalEnums.Mode.CHOP:
			_active = true
		_:
			_active = false
