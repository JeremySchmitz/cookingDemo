extends Camera2D

@export var limitLeft = 0
@export var limitUp = 0
@export var limitRight = 100000
@export var limitDown = 100000


@export var zoomRate = .02
@export var zoomMin = .25
@export var zoomMax = 1

var dragging = false
var mouseStartPos

func _unhandled_input(event):
		var handled = false
		if event is InputEventMouseButton:
			if (event.button_index == MOUSE_BUTTON_LEFT
				and event.pressed
			):
				dragging = true
				handled = true
				mouseStartPos = get_global_mouse_position()
				
			if not event.pressed:
				dragging = false
				handled = true
				get_viewport().set_input_as_handled()

			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				_setZoom()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				_setZoom(true)
			
		if dragging and event is InputEventMouseMotion:
			_set_position()
			handled = true
			
		if handled: get_viewport().set_input_as_handled()

func _setZoom(subtract = false):
	var val
	if subtract: val = zoom - Vector2(zoomRate, zoomRate)
	else: val = zoom + Vector2(zoomRate, zoomRate)
	val = clamp(val, Vector2(zoomMin, zoomMin), Vector2(zoomMax, zoomMax))
	zoom = val


func _set_position():
	var newPos = global_position + (mouseStartPos - get_global_mouse_position())
	if newPos.x < limitLeft: newPos.x = limitLeft
	elif newPos.x > limitRight: newPos.x = limitRight

	if newPos.y < limitUp: newPos.y = limitUp
	elif newPos.y > limitDown: newPos.y = limitDown

	global_position = newPos
