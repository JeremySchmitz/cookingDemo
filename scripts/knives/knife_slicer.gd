class_name KnifeSlicer
extends Knife

var active: bool = false
var cutting: bool = false


func _process(_delta):
	if(active):
		global_position = get_global_mouse_position()
		if inCuttingBoard && Input.is_action_just_pressed("left_click"):
			cutting = true
			Utils.startSlice.emit(global_position)
		elif inCuttingBoard && Input.is_action_just_released("left_click"):
			cutting = false
			Utils.endSlice.emit(global_position)
	else:
		global_position = Vector2(-10, -10)
		
func _on_mode_change(m: GlobalEnums.Mode):
	match m:
		GlobalEnums.Mode.SLICE:
			active = true
		_:
			active = false
