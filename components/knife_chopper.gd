class_name KnifeChopper
extends Area2D

var active: bool = false
var cutting: bool = false

func _ready() -> void:
	Signals.modeChange.connect(_on_mode_change)


func _process(_delta):
	if(active):
		global_position = get_global_mouse_position()
		if Input.is_action_just_pressed("left_click"):
			cutting = true
		elif  Input.is_action_just_released("left_click"):
			cutting = false
	else:
		global_position = Vector2(-10, -10)
		
func _on_mode_change(m: GlobalEnums.Mode):
	match m:
		GlobalEnums.Mode.CHOP:
			active = true
		_:
			active = false
