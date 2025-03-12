class_name KnifeChopper
extends Area2D

var active: bool = true
var cutting: bool = false

func _process(_delta):
	if(active):
		global_position = get_global_mouse_position()
		if Input.is_action_just_pressed("left_click"):
			cutting = true
		elif  Input.is_action_just_released("left_click"):
			cutting = false
