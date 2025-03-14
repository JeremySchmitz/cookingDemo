class_name KnifeSlicer
extends Area2D

var active: bool = true
var cutting: bool = false


func _process(_delta):
	if(active):
		global_position = get_global_mouse_position()
		if Input.is_action_just_pressed("left_click"):
			cutting = true
			Signals.startSlice.emit(global_position)
		elif  Input.is_action_just_released("left_click"):
			cutting = false
			Signals.endSlice.emit(global_position)
	else:
		global_position = Vector2(-10, -10)
		
